default['redash']['user'] = 'redash'

default['redash']['db'] = {
  :host     => 'localhost',
  :port     => node['postgresql']['config']['port'],
  :username => 'postgres',
  :password => node['postgresql']['password']['postgres']
}

default['redash']['server']['log'] = './main'
default['redash']['worker']['log'] = './main'
default['redash']['svlog_opt'] = '-tt'
