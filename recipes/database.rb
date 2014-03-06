#
# Cookbook Name:: redash
# Recipe:: redash_pg_schema
#

require "digest/md5"

include_recipe "postgresql::client"
include_recipe "database::postgresql"

db_connection_info = node['redash']['db']

# Create a postgresql user but grant no privileges
postgresql_database_user node['redash']['user'] do
  connection db_connection_info
  password   'super_secret'
  action     :create
end

postgresql_database 'redash' do
  connection db_connection_info
  owner node['redash']['user']
  action :create
end