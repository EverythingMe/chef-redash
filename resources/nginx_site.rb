actions :create
default_action :create

attribute :name, kind_of: String, name_attribute: true, required: true
attribute :server_name, kind_of: String, required: true
attribute :ssl_certificate, kind_of: String
attribute :ssl_certificate_key, kind_of: String
attribute :ssl_enabled, kind_of: [TrueClass, FalseClass], default: false
attribute :enforce_ssl, kind_of: [TrueClass, FalseClass], default: false
attribute :redash_port, kind_of: Integer
