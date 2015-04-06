include_recipe 'apt'
package 'curl'

varnish_install 'default' do
  package_name 'varnish'
  vendor_repo true
  vendor_version '3.0'
  no_default_service true
end

file "/etc/varnish/default.vcl" do
  content <<EOF
backend default {
        .host = "rackspace.com";
        .port = "80";
}
EOF
end

varnish_instance 'default' do
  max_open_files 131_072
  max_locked_memory 82_000
  listen_address nil
  listen_port 6081
  path_to_vcl '/etc/varnish/default.vcl'
  admin_listen_address '127.0.0.1'
  admin_listen_port 6082
  user 'varnish'
  group 'varnish'
  ttl 120
  storage 'malloc'
  malloc_size "#{(node['memory']['total'][0..-3].to_i * 0.25).to_i}K"
  parameters(thread_pools: '4',
             thread_pool_min: '5',
             thread_pool_max: '500',
             thread_pool_timeout: '300')
  path_to_secret '/etc/varnish/secret'
end

varnish_instance 'alternate' do
  instance_name 'alternate2'
  max_open_files 131_072
  max_locked_memory 82_000
  listen_address nil
  listen_port 6181
  path_to_vcl '/etc/varnish/default.vcl'
  admin_listen_address '127.0.0.1'
  admin_listen_port 6182
  user 'varnish'
  group 'varnish'
  ttl 120
  storage 'malloc'
  malloc_size "#{(node['memory']['total'][0..-3].to_i * 0.25).to_i}K"
  parameters(thread_pools: '4',
             thread_pool_min: '5',
             thread_pool_max: '400',
             thread_pool_timeout: '300')
  path_to_secret '/etc/varnish/secret'
end
