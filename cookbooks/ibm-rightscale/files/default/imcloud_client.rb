#!/usr/bin/env ruby

require 'rubygems'
require 'rest_client'
require 'json'
require 'yaml'
require 'erb'
DEFAULT_CONFIGURATION_YML = '/var/imcloud/imcloud_client.yml'

module IMCloudClient
  class << self
    attr_writer :configuration

    def configuration
       @configuration ||= Configuration.new
    end

    #########################
    # Product downloads API #
    #########################

    def download_url(product_name, args={})
      configure if @configuration.nil?

      product_name = ERB::Util.url_encode(product_name)
      format = args[:format] || "json"
      response = RestClient.get("#{configuration.download_url}/#{product_name}.#{format}",
                                :params => args.merge(:api_key => configuration.api_key))
      format.to_s == "json" ? JSON.parse(response.to_str) : response.to_str
    end

    # Dynamically generates methods such as
    # aws_us_east_1 and aws_ap_northeast_1 on the fly.
    def method_missing(m, *args, &block)
      product = args.shift
      format = args.shift
      tokens = m.to_s.split("_")

      cloud = tokens.shift
      geography = tokens.join("-")

      if format
        download_url(product, {:cloud => cloud, :geography => geography, :format => format})
      else
        download_url(product, {:cloud => cloud, :geography => geography})
      end
    end
  end

  def self.configure(config_file = nil)
    self.configuration ||= Configuration.new

    if config_file
      if File.exists?(config_file)
        config = YAML::load_file(config_file)
        configuration.api_key = config["api_key"]
        configuration.api_url = config["api_url"]
      else
        # The specified file doesn't exist
        raise Errno::ENOENT
      end
    elsif !block_given?
      configure(DEFAULT_CONFIGURATION_YML) if File.exists?(DEFAULT_CONFIGURATION_YML)
    end

    if block_given?
      # Handles the block format
      yield(configuration)
    end

    configuration.api_url ||= "https://my.imdemocloud.com/api"
    configuration.download_url = "#{configuration.api_url}/products/search"
    configuration
  end

  class Configuration
    attr_accessor :download_url, :api_url, :api_key
  end
end