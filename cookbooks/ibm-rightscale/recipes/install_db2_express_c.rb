rightscale_marker :begin

log "Setting up DB2 Download API"

## Require libraries

class Chef::Recipe
  include IMCloudClient
end

rightscale_tools_gem = `ls /var/cache/rightscale/cookbooks/default/*/cookbooks/rightscale/files/default/rightscale_tools-*.gem`.strip

gem_package "rightscale_tools" do
  source rightscale_tools_gem
  action :install
end

#Gem.clear_paths
require "rightscale_tools"

log "Provider: #{node[:cloud][:provider]}"

log "Download Attachments"
storage_cloud = "aws"
geo           = "us-east-1"

IMCloudClient.configure do |config|
  config.api_key = node[:api][:key]
  config.api_url = node[:api][:url]
end

to_download = IMCloudClient.download_url('DB2 Express-C 10.5', { :cloud => storage_cloud, :geography => geo })
files       = to_download.first["download"]["url"][5..-1].split("/",2)

@ros = RightScale::Tools::ROS.factory("s3", to_download.first["download"]["key"], to_download.first["download"]["secret"])

install_media_location = File.join("/tmp", files.last.split("/").last)

log "Need to download: #{files.first} / #{files.last}"
log "To: #{install_media_location}"

begin
  @ros.get_object_to_file(files.first, files.last, install_media_location)
rescue Exception => msg  
  log msg
  log msg.backtrace
  log msg.class
end

log "Installing DB2 Express-C 10.5"

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
  %w{compat-libstdc++-33 libstdc++-devel dapl dapl-devel libibverbs-devel}.each do |pkg|
    package pkg
  end
  yum_package "pam.i686" do
    version "1.1.1-13.el6"
	action :install
  end
end


if File.exists?("/opt/ibm/db2.lock")
  log "DB2 ALREADY INSTALLED"

  execute "install-db2" do
    command "echo '0 #{`hostname -f`.strip} 0' > /home/#{node[:db2][:instance][:username]}/sqllib/db2nodes.cfg"
    user "root"
	action :run
  end
  
else
  directory node[:db2][:data_path] do
    mode 0755
    action :create
  end
	
  %w{backups log}.each do |dir|
    directory File.join(node[:db2][:data_path], dir) do
      mode 0755
      action :create
    end
  end

  execute "extract-db2-media" do
    command "tar --index-file /tmp/db2exc.tar.log -xvvf /tmp/v10.5_linuxx64_expc.tar.gz -C /mnt/"
    user "root"
	action :nothing
  end

  execute "install-db2" do
    command "/mnt/expc/db2setup -r /tmp/db2.rsp"
    user "root"
	action :nothing
  end
  
  bash "setup-ibm-java" do
    code <<-EOH
	update-alternatives --install "/usr/bin/java" "java" "/opt/ibm/db2/V10.5/java/jdk64/jre/bin/java" 0
	update-alternatives --set "java" "/opt/ibm/db2/V10.5/java/jdk64/jre/bin/java"
	EOH
	action :nothing
  end

  log "  Configure DB2 Install Response file - /tmp/db2.rsp"
  template "/tmp/db2.rsp" do
    source "db2.rsp.erb"
	notifies :run, "execute[extract-db2-media]", :immediately
	notifies :run, "execute[install-db2]", :immediately
	notifies :run, "script[setup-ibm-java]", :immediately
  end
  
  file install_media_location do
    action :delete
  end
  
  directory File.join(node[:db2][:data_path], "log") do
    mode 2777
  end

  directory node[:db2][:data_path] do
    owner node[:db2][:instance][:username]
	group node[:db2][:instance][:group]
	recursive true
  end
  
  cookbook_file File.join("/home", node[:db2][:instance][:username], ".bashrc") do
    owner node[:db2][:instance][:username]
    group node[:db2][:instance][:group]
  end
end


rightscale_marker :end