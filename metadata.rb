name             'redash'
maintainer       'EverythingMe'
maintainer_email 'devops@everything.me'
license          'All rights reserved'
description      'Installs/Configures re:dash'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.4'

depends "postgresql"
depends "python"
depends "ark", '= 0.6.0'
depends "database"
depends "nginx"

depends 'runit', '>= 1.1.0'
