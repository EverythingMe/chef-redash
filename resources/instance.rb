actions :create
default_action :create

attribute :name, kind_of: String, name_attribute: true, required: true
attribute :tarball_url, kind_of: String, default: 'https://github.com/EverythingMe/redash/releases/download/v0.4.0%2Bb420/redash.0.4.0.b420.tar.gz', required: true
attribute :checksum, kind_of: String, default: '50dca9b034da69a7280fd9b7e04fbad261792f97aecdd30ed1f7cd73987676e6', required: true
attribute :basepath, kind_of: String, default: '/opt'
attribute :user, kind_of: String, default: 'redash'

attribute :port, kind_of: Integer, default: 5000
attribute :web_workers, kind_of: Integer, default: 4
attribute :celery_workers, kind_of: Integer, default: 4
attribute :celery_queues, kind_of: String, default: ''
attribute :celery_flower_port, kind_of: Integer, default: 5555
attribute :celery_flower_prefix, kind_of: String, default: 'flower'
attribute :celery_flower_options, kind_of: String, default: ''
attribute :config, kind_of: Hash, required: true
attribute :create_tables, kind_of: [TrueClass, FalseClass], default: true

attr_accessor :current_path, :env_path, :virtualenv_path