#
# Cookbook Name:: redash
# Recipe:: redash_pg_schema
#

require "digest/md5"

# check for required attributes
require_attribute ['redash','db','user']
require_attribute ['redash','db','password']
require_attribute ['redash','db','host']


# workaround for encoding errors with remote_file
Encoding.default_external = Encoding::ASCII_8BIT

include_recipe "postgresql::client"
include_recipe "database::postgresql"

# setup pg database(s)
pg_db_connection = {
  :host     => node['redash']['db']['host'],
  :port     => node['redash']['db']['port'],
  :username => node['redash']['db']['user'],
  :password => Digest::MD5.hexdigest(node['redash']['db']['password'])
}
pg_cfg_connection = {
  :host     => node['redash']['cfg_db']['host'],
  :port     => node['redash']['cfg_db']['port'],
  :username => node['redash']['cfg_db']['user'],
  :password => Digest::MD5.hexdigest(node['redash']['cfg_db']['password'])
}

# configuration db
postgresql_database node['redash']['cfg_db']['dbname'] do
  connection  pg_cfg_connection
  action      :create
  notifies    :cherry_pick, "ark[redash_sql]", :immediately
  notifies    :run,         "bash[initialize_cfg_db]", :immediately
end

# data db
postgresql_database node['redash']['db']['dbname'] do
  connection  pg_db_connection
  action      :create  
end

# get the initialization SQL
tmp_path   = "/tmp/redash_tarball"
sql_cherry = "rd_service/data/tables.sql"
sql_path   = "#{tmp_path}/#{sql_cherry}"
ark "redash_sql" do
  url     node["redash"]["tarball_url"]
  action  :nothing
  path    tmp_path
  creates sql_cherry
  
  # due to a peculiarity of the way the archive gets created
  strip_leading_dir false
end

# initialize the query DB, connecting as normal user
pg_db_constr_hash = {
  :host     => node['redash']['cfg_db']['host'],
  :port     => node['redash']['cfg_db']['port'],
  :user     => node['redash']['cfg_db']['user'],
  :password => Digest::MD5.hexdigest(node['redash']['cfg_db']['password']),
  :dbname   => node['redash']['cfg_db']['dbname']
}
constr = pg_db_constr_hash.map{ |(k,v)| "#{k}=#{v}" }.join(" ")
bash "initialize_cfg_db" do
  action :nothing
  code <<-EOS
    set -e
    psql "#{constr}" < "#{sql_path}"
  EOS
end
