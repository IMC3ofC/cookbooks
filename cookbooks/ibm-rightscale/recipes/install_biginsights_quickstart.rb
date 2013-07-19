rightscale_marker :begin

log "Setting up Download API"

## Require libraries

class Chef::Recipe
  include IMCloudClient
end

require "rightscale_tools"

log "Provider: #{node[:cloud][:provider]}"

log "Download Attachments"

IMCloudClient.configure do |config|
  config.api_key = node[:api][:key]
  config.api_url = node[:api][:url]
end

to_download = IMCloudClient.download_url('BigInsights Quickstart 2.1', { :cloud => "http" })

install_media_location = File.join("/tmp", to_download.first["download"]["url"].split("/").last)

remote_file install_media_location do
  source to_download.first["download"]["url"]
end

log "Installing BigInsights Quickstart 2.1"

#########
#TODO: CHANGE CODE BELOW - Testing ryan
#########
#not sure what is needed for ubuntu
case node[:platform]
when "debian", "ubuntu"
  execute "install-required-packages" do
    command "apt-get install -y libgd2-xpm:i386 libgphoto2-2:i386 ia32-libs-multiarch ia32-libs"
  end
  %w{libstdc++6 lib32stdc++6 libaio1 libpam0g:i386}.each do |pkg|
    package pkg
  end
  
  link "/lib/i386-linux-gnu/libpam.so.0" do
    to "/lib/libpam.so.0"
  end
else
  %w{expect nc}.each do |pkg|
    package pkg
  end
  #yum_package "pam.i686" do
  #  version "1.1.1-13.el6"
	#action :install
  #end
end


%w{some folders}.each do |dir|
  directory File.join("/tmp", dir) do
    mode 0755
    action :create
  end
end

execute "extract-biginsights-media" do
  command "tar --index-file /tmp/biginsights.tar.log -xvvf /tmp/biginsights-quickstart-linux64_*.tar.gz -C /mnt/"
  action :nothing
end

execute "install-biginsights" do
  command "/mnt/expc/db2setup -r /tmp/db2.rsp"
  action :nothing
end
  
bash "setup-ibm-java" do
  code <<-EOH
  update-alternatives --install "/usr/bin/java" "java" "/opt/ibm/db2/V10.5/java/jdk64/jre/bin/java" 0
  update-alternatives --set "java" "/opt/ibm/db2/V10.5/java/jdk64/jre/bin/java"
  EOH
  action :nothing
end

log "  Configure BigInsights Install Response file - /tmp/install.xml"
template "/tmp/install.xml" do
  source "install.xml.erb"
  notifies :run, "execute[extract-biginsights-media]", :immediately
  notifies :run, "execute[install-biginsights]", :immediately
  #notifies :run, "bash[setup-ibm-java]", :immediately
end
  
#file install_media_location do
#  action :delete
#end

rightscale_marker :end