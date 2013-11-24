#
# Cookbook Name:: redash
# Recipe:: redash_pg_schema
#

# workaround for encoding errors with remote_file
Encoding.default_external = Encoding::ASCII_8BIT

include_recipe "postgresql::client"
include_recipe "database::postgresql"

# setup pg user(s) and database(s)
pg_db_connection = {
  :host     => node['redash']['db']['host'],
  :port     => node['redash']['db']['port'],
  :username => node['redash']['db']['user'],
  :password => node['redash']['db']['password']
}
pg_cfg_connection = {
  :host     => node['redash']['cfg_db']['host'],
  :port     => node['redash']['cfg_db']['port'],
  :username => node['redash']['cfg_db']['user'],
  :password => node['redash']['cfg_db']['password']
}

# configuration db
postgresql_database node['redash']['cfg_db']['dbname'] do
  connection  pg_cfg_connection
  action      :create
end

# data db
postgresql_database node['redash']['db']['dbname'] do
  connection  pg_db_connection
  action      :create
  notifies    :cherry_pick, "ark[redash_tarball]", :immediately
  notifies    :run,         "bash[initialize_db]", :immediately
end

# get the initialization SQL
tmp_path   = "/tmp/redash_sql"
sql_cherry = "rd_service/data/tables.sql"
sql_path   = "#{tmp_path}/#{sql_cherry}"
ark "redash_tarball" do
  url     node["redash"]["tarball_url"]
  action  :nothing
  path    tmp_path
  creates sql_cherry
  
  
  # due to peculiarity of the way the archive gets created
  strip_leading_dir false
end

# initialize the DB, connecting as normal user:
# setup pg user(s) and database(s)
pg_db_constr_hash = {
  :host     => node['redash']['db']['host'],
  :port     => node['redash']['db']['port'],
  :user     => node['redash']['db']['user'],
  :password => node['redash']['db']['password'],
  :dbname   => node['redash']['db']['dbname']
}
constr = pg_db_constr_hash.map{ |(k,v)| "#{k}=#{v}" }.join(" ")
bash "initialize_db" do
  action :nothing
  code <<-EOS
    set -e
    psql "#{constr}" < "#{sql_path}"
  EOS
end
