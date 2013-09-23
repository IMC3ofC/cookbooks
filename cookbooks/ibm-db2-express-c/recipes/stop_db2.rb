rightscale_marker :begin

log "Stopping DB2"

execute_as_user "db2stop" do
  command "db2stop #{node[:db2][:force] == 'yes' ? 'force' : ''}"
  user node[:db2][:instance][:username]
  action :run
end

rightscale_marker :end