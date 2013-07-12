rightscale_marker :begin

log "Restore DB2 Database"

if node[:backup][:download_from_cloud] == "yes"
  rightscale_tools_gem = `ls /var/cache/rightscale/cookbooks/default/*/cookbooks/rightscale/files/default/rightscale_tools-*.gem`.strip
    
  gem_package "rightscale_tools" do
    source rightscale_tools_gem
    action :install
  end
    
  require "rightscale_tools"


  log "Download Database Backup"
  
  @ros = RightScale::Tools::ROS.factory(node[:backup][:cloud][:name], node[:backup][:cloud][:key], node[:backup][:cloud][:secret])
  
  backup_path = "#{node[:backup][:path]}/#{node[:db2][:database][:name]}"
  users_home_dir = File.join("/home", node[:db2][:instance][:username])
  latest_backup = @ros.get_latest_object_name node[:backup][:bucket], backup_path
  local_path = File.join(users_home_dir, latest_backup.split("/").last)
  
  begin
    @ros.get_object_to_file(node[:backup][:bucket], latest_backup, local_path)
  rescue Exception => msg  
    log msg
    log msg.backtrace
    log msg.class
  end
end


log "Running Database Backup"

execute_as_user "restore-database" do
  command "db2 restore DB #{node[:db2][:database][:name]} #{node[:db2][:database][:options]}"
  user node[:db2][:instance][:username]
  action :run
end

rightscale_marker :end