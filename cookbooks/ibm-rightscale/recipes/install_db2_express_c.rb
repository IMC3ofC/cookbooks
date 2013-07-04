rightscale_marker :begin

log "Installing DB2 Express-C 10.5"

case node[:platform]
when "debian", "ubuntu"
  package "libgphoto2-2:i386"
  package "libgd2-xpm:i386"
  package "libgphoto2-2:i386"
  package "ia32-libs-multiarch"
  package "ia32-libs"
  %w{unzip libstdc++6 lib32stdc++6 libaio1 ia32-libs libpam0g:i386}.each do |pkg|
    package pkg
  end
  
  #ln -s /lib/i386-linux-gnu/libpam.so.0 /lib/
else
  %w{compat-libstdc++-33 libstdc++-devel dapl dapl-devel libibverbs-devel}.each do |pkg|
    package pkg
  end
end



if File.exists?("/opt/ibm/db2.lock") do
  log "DB2 ALREADY INSTALLED"

  #echo "0 $(hostname) 0" > ${DB2_CONFIG_PATH}/home/db2inst1/sqllib/db2nodes.cfg
else
  %w{backups log}.each do |dir|
    directory File.join(node[:db2][:data_path], dir) do
      owner "db2inst1"
      group "root"
      mode 0755
      action :create
    end
  end

  execute "extract-db2-media" do
    command "tar --index-file /tmp/db2exc.tar.log -xvvf /tmp/v10.5_linuxx64_*.tar.gz -C /mnt/"
    user "root"
	action :nothing
  end

  execute "install-db2" do
    command "/mnt/expc/db2setup -r /tmp/db2.rsp"
    user "root"
	action :nothing
  end

  log "  Configure DB2 Install Response file - /tmp/db2.rsp"
  template "/tmp/db2.rsp" do
    source "db2.rsp.erb"
	notifies :run, "execute[extract-db2-media]", :immediately
	notifies :run, "execute[install-db2]", :immediately
  end
  
  file "/tmp/v10.5_linuxx64_*.tar.gz" do
    action :delete
  end
  
  directory File.join(node[:db2][:data_path], log) do
    mode 2777
  end

  directory node[:db2][:data_path] do
    owner node[:db2][:instance][:username]
	group node[:db2][:instance][:group]
  end
end


rightscale_marker :end