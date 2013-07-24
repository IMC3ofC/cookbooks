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
  not_if { ::File.exists?(install_media_location) }
end

log "Installing BigInsights Quickstart 2.1"

#########
#TODO: CHANGE CODE BELOW - Testing ryan
#########


### Samples ####

# * bash resource... alias/shortcut of execute
# bash "Setup the hosts file" do
#   user "root"
#   code <<-EOH
#   sudo sh -c "echo \\"127.0.0.1 api.#{domain}\\" >> /etc/hosts"
#   sudo sh -c "echo \\"127.0.0.1 uaa.#{domain}\\" >> /etc/hosts"
#   sudo sh -c "echo \\"127.0.0.1 service-broker.#{domain}\\" >> /etc/hosts"
#   EOH
# end

# * service resource (if already installed)... start is the default
# service "nats_server" do
#   action :start
# end

# * execute a command
# execute "restart postgresql 8.4" do
#   user "root"
#   command "/etc/init.d/postgresql-8.4 restart"
# end

# * start a daemon
# execute "Restart admin_ui" do
#   user "root"
#   command "nohup /etc/init.d/admin_ui restart >/dev/null 2>&1 &"
# end

# * group resource (http://docs.opscode.com/resource_group.html)
# group "name" do
  #   some_attribute "value" # see attributes section below
  #   action :action # see actions section below
  # end

# * user resource (http://docs.opscode.com/resource_user.html)
# user "random" do
#   comment "Random User"
#   uid 1234
#   gid "users"
#   home "/home/random"
#  shell "/bin/bash"
#   password "$1$JJsvHslV$szsCjVEroftprNn4JHtDi."
# end

# * directory resource
# %w{some folders}.each do |dir|
#   directory File.join("/tmp", dir) do
#     mode 0755
#     action :create
#   end
# end

### ###

log "  Install prerequisites."

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

# TODO make this survive the shell (at init time?)
`

bash "create-directories" do
  code <<-EOH
  mkdir /mnt/hadoop
  ln -s /mnt/hadoop /hadoop
  
  if [ -d "/var/ibm" ]; then
    mv /var/ibm /mnt/ibm
  else
    mkdir /mnt/ibm
  fi
  
  ln -s /mnt/ibm /var/ibm
  EOH
end

execute_as_user "echo-password" do
  command "echo #{node[:biginsights][:biadmin][:password]}"
  user "root"
  action :run
end

cookbook_file "/tmp/setup_biadmin.sh" do
  mode 00777
end

execute "/tmp/setup_biadmin.sh #{node[:biginsights][:biadmin][:password]}"

bash "install-biginsights" do
  code <<-EOH
  bidir=/mnt/biginsights-quickstart-linux64_*/
  
  response_file_erb="hdfs_install.xml.erb"
  
  $bidir/silent-install/silent-install.sh /tmp/install.xml
  
  sed -i 's/guardiumproxy,//' /opt/ibm/biginsights/conf/biginsights.properties
  
  echo "export PATH=\$PATH:\${PIG_HOME}/bin:\${HIVE_HOME}/bin:\${JAQL_HOME}/bin:\${FLUME_HOME}/bin:\${HBASE_HOME}/bin" >> /home/biadmin/.bashrc    
  
  EOH
end
  


log "  Configure BigInsights Install Response file - /tmp/install.xml"
template "/tmp/hdfs_install.xml" do
  source "hdfs_install.xml.erb
  notifies :run, "execute[extract-biginsights-media]", :immediately
  notifies :run, "execute[install-biginsights]", :immediately
  notifies :run, "bash[setup-ibm-java]", :immediately
end

execute "extract-biginsights-media" do
  command "tar --index-file /tmp/biginsights.tar.log -xvvf /tmp/biginsights-quickstart-linux64_*.tar.gz -C /mnt/"
  action :nothing
end
  
bash "install-biginsights" do
  code <<-EOH
  /mnt/biginsights-quickstart-linux64_*/silent-install/silent-install.sh /tmp/install.xml
  sed -i 's/guardiumproxy,//' /opt/ibm/biginsights/conf/biginsights.properties
  echo "export PATH=\$PATH:\${PIG_HOME}/bin:\${HIVE_HOME}/bin:\${JAQL_HOME}/bin:\${FLUME_HOME}/bin:\${HBASE_HOME}/bin" >> /home/biadmin/.bashrc 
  EOH
  action :nothing
end

bash "setup-ibm-java" do
  code <<-EOH
  update-alternatives --install "/usr/bin/java" "java" "/opt/ibm/db2/V10.5/java/jdk64/jre/bin/java" 0
  update-alternatives --set "java" "/opt/ibm/db2/V10.5/java/jdk64/jre/bin/java"
  EOH
  action :nothing
end


bash "copy-jaql-excercises" do
  code <<-EOH
  echo "Copy the Jaql Exercises file"
  EOH
end

bash "setup-sample-data" do
  code <<-EOH
  echo "Setup Sample Data"
  EOH
end
  
bash "sync-hadoop-config" do
  code <<-EOH
  su - biadmin -c "echo 'y' | syncconf.sh hadoop force"
  EOH
end
  
#file install_media_location do
#  action :delete
#end


rightscale_marker :end
