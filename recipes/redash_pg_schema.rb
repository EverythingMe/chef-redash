#
# Cookbook Name:: redash
# Recipe:: redash_pg_schema
#

# workaround for encoding errors with remote_file
Encoding.default_external = Encoding::ASCII_8BIT

include_recipe "postgresql::client"
include_recipe "database::postgresql"


# for cheking the db @ compile time:
g = chef_gem "pg" do
  action    :nothing
end
g.run_action(:install)

require 'pg'

# setup pg user(s) and database(s)
__pg_connection = {
  :host     => node['redash']['db']['host'],
  :user     => node['redash']['db']['user'],
  :password => node['redash']['db']['password']
}
__db_conn  = PGconn.new(__pg_connection)
__r        = __db_conn.exec("SELECT datname FROM pg_database WHERE datistemplate = false;")

db_exists  = __r.column_values(0).include? node['redash']['db']['dbname']
cfg_exists = __r.column_values(0).include? node['redash']['cfg']['dbname']

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
if cfg_exists
  log "Not touching existing database #{node['redash']['cfg']['dbname']}"
else
  postgresql_database node['redash']['cfg']['dbname'] do
    connection  pg_cfg_connection
    action      :create
  end
end



# data db
if db_exists
  log "Not touching existing database #{node['redash']['db']['dbname']}"
else
  postgresql_database node['redash']['db']['dbname'] do
    connection  pg_db_connection
    action      :create
  end

  # initialize the DB, connecting as normal user:
  # setup pg user(s) and database(s)
  pg_db_connection = {
    :host     => node['redash']['db']['host'],
    :port     => node['redash']['db']['port'],
    :user     => node['redash']['db']['user'],
    :password => node['redash']['db']['password'],
    :dbname   => node['redash']['db']['dbname']
  }
  constr = pg_db_connection.map{ |(k,v)| "#{k}=#{v}" }.join(" ")
  bash "initialize db" do
    code <<-EOS
      set -e

      cd "#{node['redash']['install_path']}/redash"
      psql "#{constr}" < ./rd_service/data/tables.sql
    EOS
  end
end
