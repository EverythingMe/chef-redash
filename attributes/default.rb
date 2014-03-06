default['redash']['path']            = '/opt/redash'

default['redash']['install_tarball'] = true
default['redash']['tarball_url']     = 'https://github.com/EverythingMe/redash/releases/download/v0.3.5%2Bb175/redash.0.3.5.b175.tar.gz'
default['redash']['version']         = /redash\.([0-9a-z\.]*).tar.gz/.match(node['redash']['tarball_url'].split("/")[-1])[1]
default['redash']['checksum']        = '5c3da9fde86bbe500b9c04cab8465e26a5e8d8ba8ee33bb8cb8147e7bed300f6'

default['redash']['user']            = 'redash'

default['redash']['db'] = {
  :host     => 'localhost',
  :port     => node['postgresql']['config']['port'],
  :username => 'postgres',
  :password => node['postgresql']['password']['postgres']
}

default['redash']['config']['database_url'] = 'postgresql://redash:super_secret@localhost/redash'

default['redash']['config']['redis_url']       = 'redis://localhost:6379'
default['redash']['config']['connection_adapter'] = 'pg'
default['redash']['config']['connection_string'] = 'user=redash password=super_secret host=localhost dbname=redash'
default['redash']['config']['google_apps_domain'] = nil
default['redash']['config']['admins']            = nil
default['redash']['config']['default_assets_path'] = "../rd_ui/dist/"
default['redash']['config']['workers_count']   = 2
default['redash']['config']['cookie_secret'] = 'c292a0a3aa32397cdb050e233733900f'
default['redash']['config']['log_level'] = 'INFO'  

default['redash']['server']['log']   = './main'
default['redash']['worker']['log']   = './main'

default['redash']['server']['py']    = ::File.join(node['redash']['path'], 'rd_service', 'server.py')
default['redash']['worker']['py']    = ::File.join(node['redash']['path'], 'rd_service', 'cli.py') + ' worker'

default['redash']['svlog_opt']       = '-tt'
