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
  :host     => node['redash']['cfg']['host'],
  :port     => node['redash']['cfg']['port'],
  :username => node['redash']['cfg']['user'],
  :password => node['redash']['cfg']['password']
}

# configuration db
postgresql_database node['redash']['cfg']['dbname'] do
  connection  pg_cfg_connection
  action      :create
end

# data db
postgresql_database node['redash']['db']['dbname'] do
  connection  pg_db_connection
  action      :create
  notifies    :run, "bash[initialize_db]", :immediately
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

    cd "#{node['redash']['install_path']}/redash"
    psql "#{constr}" < ./rd_service/data/tables.sql
  EOS
end
