name             'redash'
maintainer       'Everything.me'
maintainer_email 'devops@everything.me'
license          'All rights reserved'
description      'Installs/Configures redash'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.4'

depends "postgresql"
depends "python"
depends "ark"
depends "database"

depends 'runit', '>= 1.1.0'
