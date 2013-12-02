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
The following attributes are required to be set by user of the cookbook

* `node['redash']['db']['host']` - Host name of machine running the postgresql backend
* `node['redash']['db']['user']` - User to connect to DB with. In case the redash_pg_schema
recipe is being instantiated, this user must have the CREATE_DB rights
* `node['redash']['db']['password']` - *Plaintext* password of the above database user
* `node['redash']['allow']['admins']` - List of emails (OIDs) of users allowed to administer
redash (eg: ['yourname@gmail.com'])


The rest of the attributes have sensible defaults. See `attributes/default.rb`.
The following are of particular interest:
* `node['redash']['tarball_url']` - URL to download redash tarball from
* `node['redash']['version']` - version of this tarball (/opt/redash will be a symlink to /opt/redash-`version`)
* `node['redash']['checksum']` - sha256 checksum of the tarball obtained by `sha256sum redash-xx.tar.gz`
* `node['redash']['allow']['google_app_domain']` - Google app domain for access control (eg: 'gmail.com')

* `node['redash']['cookie_secret']` - Set this to force a specific cookie_secret. If unset, a new secret will be generated (and remembered through a cookie_secret.lock file)

* `node['redash']['install_tarball']` - True by default. Set this to false when you don't want the tarball downloaded / extracted. Rather, you are expected to make /opt/redash (or `node['redash']['path']`) available by other means, such as a graft of a developer's local workspace. Note that the directory must contain pre-generated static content, built as per redash Readme.


Usage
-----
#### redash::default
Include the redash recipe

#### redash::redash
Installs the redash daemon

#### redash::redash_pg_schema
Creates a postgres database and tables required for redash. 
In order to run this recipe, the postgres user `node['redash']['db']['user']` must exist and must have CREATE_DB rights.
Note that if run on the same node as redash::redash, this will be one and the same user that redash engine will connect to the database as.
In the example Vagrantfile in redash we specify the super-user `postgres`. Obviously, this is to be avoided in production environment. We also intentionally left out user creation from this recipe, as we believe postgres users should be managed centrally. (Also, creating the user here would require specifying super-user credentials in the attributes of this cookbook, which is insecure in most cases).

Contributing
------------

1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write your change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

License and Authors
-------------------
TODO: List authors
TODO: Licence (GPL?)
