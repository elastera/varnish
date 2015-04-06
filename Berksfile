source "https://supermarket.chef.io"

extension 'halite'
cookbook 'poise', gem: 'poise'
cookbook 'poise-service', gem: 'poise-service'

group :integration do
  cookbook 'disable_ipv6', path: 'test/fixtures/cookbooks/disable_ipv6'
  cookbook 'yum-epel'
end

metadata

group :integration do
  cookbook 'install_varnish', path: 'test/fixtures/cookbooks/install_varnish'
end
