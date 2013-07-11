rightscale_marker :begin

log "Stopping DB2 Administration Server"

execute "db2admin stop" do
  user node[:db2][:instance][:username]
  action :run
end

rightscale_marker :end