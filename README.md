redash Cookbook
=================
This cookbook installs redash from github release (by default https://github.com/EverythingMe/redash/releases/tag/v0.1.35).

Requirements
------------
Tested with latest Chef version 11.8.0

### Tested With Platforms
* Ubuntu 12.04 LTS

### Cookbooks
The following cookbooks are dependencies (through metadata.rb and Berkshelf):
* postgresql
* python
* ark
* database


Attributes
----------

### Default

- `node['redash']['path']` - base path for re:dash related directories (install directory, virtualenv, etc) (default: `'/opt/redash'`)
- `node['redash']['tarball_url']` - URL of re:dash tarball to install (default: url of version v0.3.5b175)
- `node['redash']['version']` - re:dash version (default: extracted from tarball filename)
- `node['redash']['checksum']` - SHA256 checksum of the tarball.
- `node['redash']['install_tarball']` - True by default. Set this to false when you don't want the tarball downloaded / extracted. Rather, you are expected to make `/opt/redash/curernt` (or `node['redash']['path']/current`) available by other means, such as a graft of a developer's local workspace. Note that the directory must contain the bower packages and you need to update `node['redash']['config']['static_assets_path']` if you're using uncompiled version.
- `node['redash']['user']` - user for re:dash (both system user & PostgreSQL user).

The following properties define the PostgreSQL database re:dash uses for its metadata. This is only needed if you want to use the `redash::database` recipe to create the user and database. The default values use assume PostgreSQL runs locally and use attributes to determine username and password:

- `node['redash']['db']['host]`
- `node['redash']['db']['port]`
- `node['redash']['db']['username]`
- `node['redash']['db']['password]`

The following define gunicorn configuration:

- `node['redash']['web']['workers_count']` -  number of gunicorn workers to use (defualt: 4).
- `node['redash']['web']['port']` - port to bind gunicorn on (default: 5000).

The following are used to write the configuration file:

- `node['redash']['config']['database_url']` - database URL of the metadata database (default:  'postgresql://redash:super_secret@localhost/redash')
- `node['redash']['config']['redis_url']` - URL of the Redis server (default: 'redis://localhost:6379')
- `node['redash']['config']['google_apps_domain']` - Google Apps domain to authenticate with. **If left nil/blank, it will accept any Google Apps (or Gmail) domain.** (default: nil)
- `node['redash']['config']['admins']` - comma separated list of emails of users with admin privilliges (it doesn't create the users, but when they login they will have admin rights) (defualt: nil)
- `node['redash']['config']['static_assets_path']` - path to statis assets (if relative, then relative to code) (default: "../rd_ui/dist/")
- `node['redash']['config']['workers_count']` - updater workers count (default: 2)
- `node['redash']['config']['cookie_secret']` - secret used to encrypt cookies. **Make sure to change; specially on production deployments.** (default: 'c292a0a3aa32397cdb050e233733900f')
- `node['redash']['config']['log_level']` - logging level (default: 'INFO')

Settings for the re:dash datasource:

- `node['redash']['config']['connection_adapter']` = 'pg'
- `node['redash']['config']['connection_string']` = 'user=redash password=super_secret host=localhost dbname=redash'

By default it's configured to query its own meta database (for demo purposes only). See [wiki](https://github.com/EverythingMe/redash/wiki/re:dash-connection-adapter-options) for additional options.

runit related settings:

- `node['redash']['server']['log']` = './main'
- `node['redash']['worker']['log']` = './main'
- `node['redash']['svlog_opt']` = '-tt'


Usage
-----
#### redash::default
Includes the deploy, configuration and services recipes.

#### redash::deploy
Deploys the codebase, configuration (using the `redash::configuration` recipe) and pip packages (requirements.txt and gunicorn).

#### redash::configuration
Created the configuration file (the env.sh executable that exports relevant settings).

#### redash::services
Setups runit services to run the web server and updater.

#### redash::redis

Naive recipe to install Redis server from package.

#### redash::database

Created Postgresql database and user for re:dash.

#### redash::nginx

Installs nginx and setups proxy for re:dash.


Contributing
------------

1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write your change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

License
-------
See [LICENSE](https://github.com/EverythingMe/chef-redash/blob/master/LICENSE) file.

