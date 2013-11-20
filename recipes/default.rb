#
# Cookbook Name:: redash
# Recipe:: default
#

#Workaround for encoding errors with remote_file:
Encoding.default_external = Encoding::ASCII_8BIT


######################################################
#  Save section -- doesn't require redash to be down..
######################################################
include_recipe "postgresql::client"
include_recipe "python"
include_recipe "runit"

#Enable cheff to interact with pg:
include_recipe "database::postgresql"

user node['redash']['user'] do
  system true
end

#Setup pg user(s) and database(s):
pg_db_super_connection = {
  :host     => node['redash']['db']['host'],
  :port     => node['redash']['db']['port'],
  :username => 'postgres',
  :password => node['redash']['db']['postgres_pwd']
}
pg_cfg_super_connection = {
  :host     => node['redash']['cfg']['host'],
  :port     => node['redash']['cfg']['port'],
  :username => 'postgres',
  :password => node['redash']['cfg']['postgres_pwd']
}

#The data db:
postgresql_database node['redash']['db']['dbname'] do
  connection  pg_db_super_connection
  action      :create
end

#The configuration db:
postgresql_database node['redash']['cfg']['dbname'] do
  connection  pg_cfg_super_connection
  action      :create
end

postgresql_database_user "redash_db_user" do
  username       node['redash']['db']['user']
  connection     pg_db_super_connection
  password       node['redash']['db']['password']
  database_name  node['redash']['db']['dbname']
  privileges     [:all]
  action         [:create,:grant]
end

postgresql_database_user "redash_cfg_user" do
  username       node['redash']['cfg']['user']
  connection     pg_cfg_super_connection
  password       node['redash']['cfg']['password']
  database_name  node['redash']['cfg']['dbname']
  privileges     [:all]
  action         [:create,:grant]
end



######################################################
#  DOWNTIME section 
#    -- fiddle with stuff that breaks a running server
######################################################

runit_service "redash-server" do
  action  :stop
end

runit_service "redash-worker" do
  action  :stop
end

#Download and deploy the redash release
#TODO: version should be acc. to what's in metadata.rb
#TODO: install path should be a configurable attribute
ark "redash" do
  url     "http://github.com/EverythingMe/redash/releases/download/v0.1.35/redash.35.tar.gz"
  action  :put
  path    node["redash"]["install_path"]
  
  #Due to peculiarity of the way the archive gets created:
  strip_leading_dir false
end

#Install dependencies acc. to file:
bash ":install pip dependencies" do 
  code <<-EOS
  cd #{node["redash"]["install_path"]}/redash
  pip install -r ./rd_service/requirements.txt
  EOS
end

#Configure:
template "#{node["redash"]["install_path"]}/redash/rd_service/settings.py" do
  source "settings.py.erb"
end



#Initialize the DB, connecting as normal user:
#Setup pg user(s) and database(s):
pg_db_connection = {
  :host     => node['redash']['db']['host'],
  :port     => node['redash']['db']['port'],
  :user     => node['redash']['db']['user'],
  :password => node['redash']['db']['password'],
  :dbname   => node['redash']['cfg']['dbname']
}
constr = pg_db_connection.map{|(k,v)| "#{k}=#{v}"}.join(" ")
bash ":initialize db" do 
  code <<-EOS
  cd #{node["redash"]["install_path"]}/redash
  
  psql "#{constr}" < ./rd_service/data/tables.sql
  EOS
end


#Install runit scripts and bring the system up:
runit_service "redash-server" do
  action [:enable, :start]
end

runit_service "redash-worker" do
  action [:enable, :start]
end

