rightscale_marker :begin


unless File.exists? "/opt/ibm/biginsights/conf/biginsights.properties"

  ## Require libraries 
  
  class Chef::Recipe
    include IMCloudClient
  end
  
  require "rightscale_tools"
  
  
  log "Provider: #{node[:cloud][:provider]}"
  
  
  ## Download Attachments
  
  log "Download Attachments"
  
  IMCloudClient.configure do |config|
    config.api_key = node[:api][:key]
    config.api_url = node[:api][:url]
  end
  
  IMCloudClient.download('/tmp', 'BigInsights Quickstart 2.1', { :cloud => "http" })
    
  
  ## Installing BigInsights Quickstart 2.1
  
  log "Installing BigInsights Quickstart 2.1"
  
  log "  Install prerequisites."
  
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
  
  log "  Set open files limits."
  
  bash "set-ulimits" do
    code <<-EOH
    echo "root hard nofile 16384" >> /etc/security/limits.conf
    echo "root soft nofile 16384" >> /etc/security/limits.conf
    EOH
  end
  
  bash "update firewall" do
    code <<-EOH
    yum install policycoreutils -y
    echo "-A FWR --protocol tcp --dport 8080 -j ACCEPT" >> /etc/iptables.d/port_8080_any_tcp
    iptables -D FWR -p tcp -m tcp --tcp-flags SYN,RST,ACK SYN -j REJECT --reject-with icmp-port-unreachable 
    iptables -A FWR -s #{node[:cloud][:public_ipv4]} -j ACCEPT 
    iptables -A FWR -p tcp -m tcp --dport  9443 -j ACCEPT
    iptables -A FWR -p tcp -m tcp --tcp-flags SYN,RST,ACK SYN -j REJECT --reject-with icmp-port-unreachable 
    service iptables save
    EOH
  end
  
  
  
  log "  Create directories."
  
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
  
  log "  Run the BI admin setup script."
    
  cookbook_file "/tmp/setup_biadmin.sh" do
    mode 00777
  end
  
  execute "/tmp/setup_biadmin.sh #{node[:biginsights][:biadmin][:password]}"
  
  log "  Run BI installation script."
  
  execute "extract-biginsights-media" do
    command "tar --index-file /tmp/biginsights.tar.log -xvvf /tmp/biginsights-quickstart-linux64_*.tar.gz -C /mnt/"
    action :nothing
  end
    
  bash "install-biginsights" do
    code <<-EOH
    ulimit -n 16384
    /mnt/biginsights-quickstart-linux64_*/silent-install/silent-install.sh /tmp/install.xml
    sed -i 's/guardiumproxy,//' /opt/ibm/biginsights/conf/biginsights.properties
    echo 'export PATH=\$PATH:\${PIG_HOME}/bin:\${HIVE_HOME}/bin:\${JAQL_HOME}/bin:\${FLUME_HOME}/bin:\${HBASE_HOME}/bin' >> /home/biadmin/.bashrc 
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
  
  log "  Configure BigInsights Install Response file - /tmp/install.xml"
  template "/tmp/install.xml" do
    source "install.xml.erb"
    variables(
      :biadmin_password => node[:biginsights][:biadmin][:password],
      :master_hostname => node[:cloud][:public_ipv4],
      :bi_directory_prefix => node[:biginsights][:bi_directory_prefix],
      :hadoop_distribution => node[:biginsights][:hadoop_distribution],
      :data_node_unique_hostnames => node[:biginsights][:data_node_unique_hostnames]
    )
    notifies :run, "execute[extract-biginsights-media]", :immediately
    notifies :run, "bash[install-biginsights]", :immediately
    notifies :run, "bash[setup-ibm-java]", :immediately
  end
  
  log "  Stubs for the JAQL exercises and sample apps."
  
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
    
  log "  Sync the Hadoop configuration."
  
  bash "sync-hadoop-config" do
    code <<-EOH
    su - biadmin -c "echo 'y' | syncconf.sh hadoop force"
    EOH
  end
  
end  
  
rightscale_marker :end
