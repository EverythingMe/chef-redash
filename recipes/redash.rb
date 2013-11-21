#
# Cookbook Name:: redash
# Recipe:: redash
#

# workaround for encoding errors with remote_file:
Encoding.default_external = Encoding::ASCII_8BIT

include_recipe "python"
include_recipe "runit"

user node['redash']['user'] do
  system true
end

# download and deploy the redash release
# TODO: version should be acc. to what's in metadata.rb
# TODO: install path should be a configurable attribute
ark "redash" do
  url     "http://github.com/EverythingMe/redash/releases/download/v0.1.35/redash.35.tar.gz"
  action  :put
  path    node['redash']['prefix']

  # due to peculiarity of the way the archive gets created
  strip_leading_dir false
end

# install dependencies acc. to file:
bash ":install pip dependencies" do 
  code <<-EOS
    cd #{node['redash']['path']}
    pip install -r ./rd_service/requirements.txt
  EOS
end

# configure
template "#{node['redash']['path']}/rd_service/settings.py" do
  source "settings.py.erb"
end

runit_service "redash-server" do
  subscribes :restart, "template[#{node['redash']['path']}/rd_service/settings.py"
end

runit_service "redash-worker" do
  subscribes :restart, "template[#{node['redash']['path']}/rd_service/settings.py"
end
