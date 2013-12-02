#
# Cookbook Name:: redash
# Recipe:: redash
#

# check for required attributes
require_attribute ['redash','db','user']
require_attribute ['redash','db','password']
require_attribute ['redash','db','host']

cookie_secret_path   = ::File.join(node['redash']['path'], "rd_service", "cookie_secret.lock")
cookie_secret_action = :nothing
new_secret           = nil
if node['redash']['cookie_secret'].nil?
  old_secret      = ""
  begin
    File.open(cookie_secret_path, "rb") do |file|
      old_secret  = file.read.strip
    end
  rescue SystemCallError
  rescue IOError
    # File did not exist (keep old_secret "")
  end
  
  if old_secret == ""
    require 'securerandom'
    new_secret           = SecureRandom.hex(n=16)
    cookie_secret_action = :create
    node.set['redash']['cookie_secret'] = new_secret
  else
    node.set['redash']['cookie_secret'] = old_secret
  end
end


# workaround for encoding errors with remote_file:
# (ref: https://tickets.opscode.com/browse/CHEF-4798)
Encoding.default_external = Encoding::ASCII_8BIT

include_recipe "python"
include_recipe "runit"

user node['redash']['user'] do
  system true
end


# download and deploy the redash release
ark "redash" do
  url         node["redash"]["tarball_url"]
  version     node["redash"]["version"]
  checksum    node["redash"]["checksum"]
  action      :install
  prefix_root node['redash']['prefix']
  prefix_home node['redash']['prefix']
  
  # due to peculiarity of the way the archive gets created
  strip_leading_dir false
  
  # skip if asked not to install
  # (eg: vagrant box with a mount of a dev's dir @ /opt/redash )
  only_if { node['redash']['install_tarball'] }
end

# install dependencies acc. to file:
execute "install pip dependencies" do 
  cwd     node['redash']['path']
  command "pip install -r ./rd_service/requirements.txt"
end

# configure
settings_path   = ::File.join(node['redash']['path'], "rd_service", "settings.py")

# Create cookie_secret.lock if we've generated a new secret
file cookie_secret_path do
  action  cookie_secret_action
  content "#{new_secret}\n"
  mode    '0600'
end

template settings_path do
  mode  '0600'
  owner node['redash']['user']
end

runit_service "redash-server" do
  subscribes :restart, "template[#{settings_path}]"
  subscribes :restart, "ark[redash]"
end

runit_service "redash-worker" do
  subscribes :restart, "template[#{settings_path}]"
  subscribes :restart, "ark[redash]"
end
