define :execute_as_user, :user => "root", :command => nil do
  log params.inspect
  execute params[:name] do
    command "su - #{params[:user]} -c \"#{params[:command]}\""
  end
end