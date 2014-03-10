include_recipe "redash::configuration"
include_recipe "python"

version = /redash\.([0-9a-z\.]*).tar.gz/.match(node['redash']['tarball_url'].split("/")[-1])[1]
# download and deploy the redash release
ark "redash" do
  url         node["redash"]["tarball_url"]
  version     version
  checksum    node["redash"]["checksum"]
  action      :install
  prefix_root node['redash']['path']
  prefix_home node['redash']['path']
  home_dir ::File.join(node['redash']['path'], 'current')
  owner node['redash']['user']
  
  # due to peculiarity of the way the archive gets created
  strip_leading_dir false
  
  # skip if asked not to install
  # (eg: vagrant box with a mount of a dev's dir @ /opt/redash )
  only_if { node['redash']['install_tarball'] }
end

# packages
package 'postgresql-client'
package 'libpq-dev'

# virtualenv
virtualenv = ::File.join(node['redash']['path'], "virtualenv")
python_virtualenv virtualenv do
  owner node['redash']['user']
  interpreter "python2.7"
end

pip_cmd = ::File.join(virtualenv, 'bin', 'pip')
requirements_path = ::File.join(node['redash']['path'], 'current', 'requirements.txt')
execute "install pip dependencies" do 
  cwd     node['redash']['path']
  command "#{pip_cmd} install -r #{requirements_path} --allow-external atfork --allow-unverified atfork"
end

python_pip "gunicorn" do
  virtualenv virtualenv
  action :install
end

# TODO: this needs to replaced by migrate 
python_cmd = ::File.join(virtualenv, 'bin', 'python')
env = ::File.join(node['redash']['path'], 'shared', 'env.sh')
execute "create database" do
  cwd ::File.join(node['redash']['path'], 'current')
  command ". #{env} && #{python_cmd} manage.py database create_tables"
end
