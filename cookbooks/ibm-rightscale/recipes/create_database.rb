rightscale_marker :begin

log "Create DB2 Database"

"db2 CREATE DB $DBNAME $OPTIONS"
execute "create-database" do
  command "db2 CREATE DB #{node[:db2][:database][:name]} #{node[:db2][:database][:options]}"
  user node[:db2][:instance][:username]
  action :run
end

rightscale_marker :end