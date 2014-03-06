include_recipe "runit"

runit_service "redash-server" do
  subscribes :restart, "template[env.sh]"
  subscribes :restart, "ark[redash]"
end

# runit_service "redash-workers" do
  # subscribes :restart, "template[env.sh]"
  # subscribes :restart, "ark[redash]"
# end
