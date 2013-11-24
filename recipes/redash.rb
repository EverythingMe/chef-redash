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
ark "redash" do
  url     node["redash"]["tarball_url"]
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
settings_path = File.join(node['redash']['path'], "rd_service", "settings.py")

template settings_path

runit_service "redash-server" do
  subscribes :restart, "template[#{settings_path}]"
end

runit_service "redash-worker" do
  subscribes :restart, "template[#{settings_path}]"
end
