rightscale_marker :begin

log "Stopping DB2"

execute_as_user "db2stop" do
  user node[:db2][:instance][:username]
  command "db2stop #{node[:db2][:force] == 'yes' ? 'force' : ''}"
  action :run
end

#execute "db2stop" do
#  command "su - #{node[:db2][:instance][:username]} -c \"db2stop #{node[:db2][:force] == 'yes' ? 'force' : ''}\""
#  action :run
#end

rightscale_marker :end