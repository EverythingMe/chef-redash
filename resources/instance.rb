actions :create
default_action :create

attribute :name, kind_of: String, name_attribute: true, required: true
attribute :tarball_url, kind_of: String, default: 'https://github.com/EverythingMe/redash/releases/download/v0.3.5%2Bb175/redash.0.3.5.b175.tar.gz', required: true
attribute :checksum, kind_of: String, default: '5c3da9fde86bbe500b9c04cab8465e26a5e8d8ba8ee33bb8cb8147e7bed300f6', required: true
attribute :basepath, kind_of: String, default: '/opt'
attribute :user, kind_of: String, default: 'redash'

attribute :port, kind_of: Integer, default: 5000
attribute :web_workers, kind_of: Integer, default: 4
attribute :config, kind_of: Hash, required: true
attribute :create_tables, kind_of: [TrueClass, FalseClass], default: true

attr_accessor :current_path, :env_path, :virtualenv_path