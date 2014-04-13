def whyrun_supported?
  true
end

use_inline_resources

action :create do
  Chef::Log.info "Creating: #{ new_resource }"
  converge_by("Configure #{ new_resource }") do
    create_redash_instance_configuration
  end
  converge_by("Create #{ new_resource }") do
    create_redash_instance
  end
  converge_by("Create service for #{ new_resource }") do
    create_redash_services
  end
end

def set_attribute(name, value)
  node.default['redash']['instances'][new_resource.name][name] = value
end

def create_redash_instance_configuration
  user new_resource.user do
    system true
  end

  shared_path = ::File.join(new_resource.basepath, new_resource.name, 'shared')
  set_attribute('shared_path', shared_path)
  directory shared_path do
    owner new_resource.user
    recursive true
  end

  env_path = ::File.join(shared_path, 'env.sh')
  template env_path do
    source 'env.sh.erb'
    cookbook 'redash'
    owner new_resource.user
    variables config: new_resource.config
  end 

  set_attribute('env_path', env_path)
  set_attribute('config', new_resource.config)

  new_resource.current_path = ::File.join(new_resource.basepath, new_resource.name, 'current')
  new_resource.virtualenv_path = ::File.join(new_resource.basepath, new_resource.name, 'virtualenv')
  new_resource.env_path = env_path
end

def create_redash_instance
  version = /redash\.([0-9a-z\.]*).tar.gz/.match(new_resource.tarball_url.split("/")[-1])[1]
  basepath = ::File.join(new_resource.basepath, new_resource.name)
  set_attribute('version', version)
  set_attribute('basepath', basepath)
  
  # download and deploy the redash release
  ark new_resource.name do
    url         new_resource.tarball_url
    version     version
    checksum    new_resource.checksum
    action      :install
    prefix_root basepath
    prefix_home basepath
    home_dir new_resource.current_path
    owner new_resource.user
    
    # due to peculiarity of the way the archive gets created
    strip_leading_dir false
  end

  # packages
  package 'postgresql-client'
  package 'libpq-dev'

  # virtualenv
  virtualenv = ::File.join(basepath, "virtualenv")
  python_virtualenv virtualenv do
    owner new_resource.user
    interpreter "python2.7"
  end

  pip_cmd = ::File.join(virtualenv, 'bin', 'pip')
  requirements_path = ::File.join(new_resource.current_path, 'requirements.txt')
  execute "install pip dependencies" do 
    cwd     basepath
    command "#{pip_cmd} install -U -r #{requirements_path} --allow-external atfork --allow-unverified atfork"
  end

  python_pip "gunicorn" do
    virtualenv virtualenv
    action :install
  end

  # TODO: this needs to replaced by migrate 
  python_cmd = ::File.join(virtualenv, 'bin', 'python')
  env = ::File.join(basepath, 'shared', 'env.sh')
  execute "create database" do
    cwd new_resource.current_path
    command ". #{env} && #{python_cmd} manage.py database create_tables"
    only_if { new_resource.create_tables }
  end
end

def create_redash_services
  options = {
    name: new_resource.name,
    user: new_resource.user,
    current_path: new_resource.current_path,
    virtualenv_path: new_resource.virtualenv_path,
    env_path: new_resource.env_path,
    web_port: new_resource.port,
    web_workers: new_resource.web_workers
  }
  set_attribute('web_port', new_resource.port)

  runit_service "redash-#{new_resource.name}-server" do
    subscribes :restart, "template[#{new_resource.env_path}]"
    subscribes :restart, "ark[#{new_resource.name}]"
    run_template_name 'redash-server'
    log_template_name 'redash-server'
    cookbook 'redash'
    options options
  end

  runit_service "redash-#{new_resource.name}-updater" do
    subscribes :restart, "template[#{new_resource.env_path}]"
    subscribes :restart, "ark[#{new_resource.name}]"
    run_template_name 'redash-updater'
    log_template_name 'redash-updater'
    cookbook 'redash'
    options options
  end
end