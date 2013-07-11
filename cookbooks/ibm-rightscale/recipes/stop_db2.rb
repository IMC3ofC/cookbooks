rightscale_marker :begin

log "Stopping DB2"

bash "stop-db2" do
  user node[:db2][:instance][:username]
  code <<-EOH
  db2stop #{node[:db2][:force] == 'yes' ? 'force' : ''}
  EOH
end

#execute "db2stop" do
#  command ""
#  user node[:db2][:instance][:username]
#  action :run
#end

rightscale_marker :end