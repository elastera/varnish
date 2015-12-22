name 'varnish'
maintainer 'Chef Software, Inc.'
maintainer_email 'cookbooks@chef.io'
license 'Apache 2.0'
description 'Installs and configures varnish'
#version '2.1.0'
version '99.0.4'

recipe 'varnish', 'Installs and configures varnish'
recipe 'varnish::repo', 'Adds the official varnish project repository'

%w(ubuntu debian redhat amazon centos).each do |os|
  supports os
end

depends 'apt', '~> 2.4'
depends 'build-essential'
depends 'yum', '~> 3.0'
depends 'yum-epel'

depends 'poise-service', '= 1.0.0'
