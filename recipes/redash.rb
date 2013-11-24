#
# Cookbook Name:: redash
# Recipe:: redash
#

def require_attribute(attr_lst)
  if ! _require_attribute(attr_lst, node)
    Chef::Application.fatal! "You must set the attribute #{attr_lst.join('.')}"
  end
  return true
end

# Given an attribute path expressed as a list,
# recursively check for all items on the path being defined
def _require_attribute(attr_lst, base)
  if attr_lst.nil? || attr_lst.empty?
    return true
  end
  
  if ! base.attribute? attr_lst.first || base[attr_lst.first].nil?
    return false
  end
  
  return _require_attribute(attr_lst[1..-1], base[attr_lst.first])
end


# check for required attributes
require_attribute ['redash','db','user']
require_attribute ['redash','db','password']
require_attribute ['redash','db','host']


# workaround for encoding errors with remote_file:
# (ref: https://tickets.opscode.com/browse/CHEF-4798)
Encoding.default_external = Encoding::ASCII_8BIT

include_recipe "python"
include_recipe "runit"

user node['redash']['user'] do
  system true
end

# download and deploy the redash release
ark "redash_tarball" do
  url     node["redash"]["tarball_url"]
  action  :put
  path    node['redash']['prefix']

  # due to peculiarity of the way the archive gets created
  strip_leading_dir false
end

# install dependencies acc. to file:
bash "install pip dependencies" do 
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
