rightscale_marker :begin

log "Starting DB2"

execute "db2start" do
  user node[:db2][:instance][:username]
  action :run
end

rightscale_marker :end