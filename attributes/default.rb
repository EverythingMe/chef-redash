
default["redash"]["install_path"]    = "/opt"
default["redash"]["prefix"]          = "/opt"
default["redash"]["path"]            = File.join(node["redash"]["prefix"], "redash")

default["redash"]["user"]            = "redash"

default['redash']['redis_url']       = "redis://localhost:6379"

default['redash']['db']['user']      = nil
default['redash']['db']['password']  = nil
default['redash']['db']['host']      = nil
default['redash']['db']['port']      = 5432
default['redash']['db']['dbname']    = "redash_db0"
default['redash']['cfg_db']['user']     = node['redash']['db']['user']
default['redash']['cfg_db']['password'] = node['redash']['db']['password']
default['redash']['cfg_db']['host']     = node['redash']['db']['host']
default['redash']['cfg_db']['port']     = node['redash']['db']['port']
default['redash']['cfg_db']['dbname']   = "redash_cfgdb0"


# accept logins from open id's verified by google accounts
default['redash']['allow']['google_app_domain'] = "gmail.com"
default['redash']['allow']['google_app_users']  = ['joe@gmail.com','max@gmail.com']
default['redash']['allow']['admins']            = ['timor@everything.me','arik@everything.me']

default['redash']['workers_count']   = 2
default['redash']['max_connections'] = 3

default['redash']['cookie_secret']   = "c292a0a3aa32397cdb050e233733900f"

default['redash']['server']['log']   = "./main"
default['redash']['worker']['log']   = "./main"

default['redash']['server']['py']    = File.join(node['redash']['path'], "rd_service", "server.py")
default['redash']['worker']['py']    = File.join(node['redash']['path'], "rd_service", "cli.py") + " worker"

default['redash']['svlog_opt']       = "-tt"
