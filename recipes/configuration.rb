user node['redash']['user'] do
  system true
end

shared_path = ::File.join(node['redash']['path'], 'shared')
directory shared_path do
  owner node['redash']['user']
  recursive true
end

env_path = ::File.join(shared_path, 'env.sh')
template 'env.sh' do
  path env_path  
  owner node['redash']['user']
end 