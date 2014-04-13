# include_recipe "python"

config = {}
config['database_url'] = 'postgresql://redash:super_secret@localhost/redash'
config['redis_url'] = 'redis://localhost:6379'
config['connection_adapter'] = 'pg'
config['connection_string'] = 'user=redash password=super_secret host=localhost dbname=redash'
config['google_apps_domain'] = nil
config['admins'] = nil
config['static_assets_path'] = "../rd_ui/dist/"
config['workers_count'] = 2
config['cookie_secret'] = 'c292a0a3aa32397cdb050e233733900f'
config['log_level'] = 'INFO'  
config['statsd_host'] = "127.0.0.1"
config['statsd_port'] = 8125
config['statsd_prefix'] = "redash"
config['google_openid_enabled'] = true
config['password_login_enabled'] = false

redash_instance 'redash' do
  config config
end

redash_nginx_site 'redash' do
  server_name 'localhost'
  redash_port 5000
end