include_recipe 'apt'
package 'curl'

varnish_install 'default' do
  package_name 'varnish'
  vendor_repo true
  vendor_version '3.0'
  no_default_service true
end
