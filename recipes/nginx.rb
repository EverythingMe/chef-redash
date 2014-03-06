include_recipe "nginx"

template "#{node['nginx']['dir']}/sites-available/redash" do
  mode 0777
  owner node['nginx']['user']
  group node['nginx']['user']
end

nginx_site 'default' do
  enable false
end

nginx_site "redash"

# TODO: restart nginx