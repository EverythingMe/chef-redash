actions :create
default_action :create

attribute :name, kind_of: String, name_attribute: true, required: true
attribute :tarball_url, kind_of: String, default: 'https://github.com/EverythingMe/redash/releases/download/v0.3.6%2Bb328/redash.0.3.6.b328.tar.gz', required: true
attribute :checksum, kind_of: String, default: 'f60d15640413b5d715b3787f8a81495a8faee9a05b0f679a7216c465503b7f92', required: true
attribute :basepath, kind_of: String, default: '/opt'
attribute :user, kind_of: String, default: 'redash'

attribute :port, kind_of: Integer, default: 5000
attribute :web_workers, kind_of: Integer, default: 4
attribute :config, kind_of: Hash, required: true
attribute :create_tables, kind_of: [TrueClass, FalseClass], default: true

attr_accessor :current_path, :env_path, :virtualenv_path