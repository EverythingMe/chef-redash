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
              behind_proxy: new_resource.behind_proxy,
              redash_port: new_resource.redash_port,
              name: new_resource.name,
              default_server: new_resource.default_server
  end

  # TODO: understand why it doesn't recognize the service defined in nginx's 
  # recipe, despite using use_inline_resources.
  service "nginx" do
    action :nothing
  end

  nginx_site "#{new_resource.name}"
end
