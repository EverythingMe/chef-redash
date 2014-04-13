def whyrun_supported?
  true
end

use_inline_resources

action :create do
  Chef::Log.info "Creating: #{ new_resource }"
  converge_by("Configure #{ new_resource }") do
    create_nginx_site
  end
end

def create_nginx_site
  template "#{node['nginx']['dir']}/sites-available/#{new_resource.name}" do
    source 'redash.erb'
    cookbook 'redash'
    mode 0777
    owner node['nginx']['user']
    group node['nginx']['user']
    variables server_name: new_resource.server_name,
              ssl_certificate: new_resource.ssl_certificate,
              ssl_certificate_key: new_resource.ssl_certificate_key,
              ssl_enabled: new_resource.ssl_enabled,
              enforce_ssl: new_resource.enforce_ssl,
              redash_port: new_resource.redash_port,
              name: new_resource.name
  end

  nginx_site "#{new_resource.name}"

  # TODO: restart nginx only when needed
  service 'nginx' do
    action :restart
  end
end
