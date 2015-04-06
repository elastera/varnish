class Chef
  class Resource
    # Configure the Varnish service.
    class VarnishInstance < Chef::Resource::LWRPBase
      include PoiseService::ServiceMixin

      self.resource_name = :varnish_instance

      default_action [:enable, :start]

      attribute :name, kind_of: String, name_attribute: true

      # Service config options
      attribute :max_open_files, kind_of: Fixnum, default: 131_072
      attribute :max_locked_memory, kind_of: Fixnum, default: 82_000
      attribute :instance_name, kind_of: String, :name_attribute => true

      # Daemon options
      attribute :listen_address, kind_of: Fixnum, default: nil
      attribute :listen_port, kind_of: Fixnum, default: 6081
      attribute :path_to_vcl, kind_of: String, default: '/etc/varnish/default.vcl'
      attribute :admin_listen_address, kind_of: String, default: '127.0.0.1'
      attribute :admin_listen_port, kind_of: Fixnum, default: 6082
      attribute :user, kind_of: String, default: 'varnish'
      attribute :group, kind_of: String, default: 'varnish'
      attribute :ttl, kind_of: Fixnum, default: 120
      attribute :storage, kind_of: String, default: 'file',
                          equal_to: ['file', 'malloc']
      attribute :file_storage_path, kind_of: String,
                                    default: nil
      attribute :file_storage_size, kind_of: String, default: '1G'
      attribute :malloc_size, kind_of: String, default: nil
      attribute :parameters, kind_of: Hash,
                             default: { 'thread_pools' => '4',
                                        'thread_pool_min' => '5',
                                        'thread_pool_max' => '500',
                                        'thread_pool_timeout' => '300' }
      attribute :path_to_secret, kind_of: String, default: '/etc/varnish/secret'
    end
  end

  class Provider
    # Configure the Varnish service.
    class VarnishInstance < Chef::Provider::LWRPBase
      include PoiseService::ServiceMixin
      def whyrun_supported?
        true
      end

      use_inline_resources

      # for poise-service
      def service_options(resource)
        service_name = "varnish-" + new_resource.instance_name
        resource.service_name(service_name)
        resource.restart_on_update :immediately
        # service is the PoiseService::Resource object instance.
        varnish_args = ['/usr/sbin/varnishd']
        varnish_args << "-a #{new_resource.listen_address}:#{new_resource.listen_port}"
        varnish_args << "-f #{new_resource.path_to_vcl}"
        varnish_args << "-T #{new_resource.admin_listen_address}:#{new_resource.admin_listen_port}"
        varnish_args << "-u #{new_resource.user} -g #{new_resource.group}"
        varnish_args << "-t #{new_resource.ttl}"
        varnish_args << "-n #{new_resource.instance_name}"
        if new_resource.storage == 'file'
          storage = [new_resource.storage,
                     new_resource.file_storage_path,
                     new_resource.file_storage_size].compact.join(",")
        else
          storage = [new_resource.storage, new_resource.malloc_size].compact.join(",")
        end
        varnish_args << "-s #{storage}"
        unless new_resource.parameters.nil?
          new_resource.parameters.each do |param, value|
            varnish_args << "-p #{param.to_s}=#{value}"
          end
        end
        varnish_args << "-S #{new_resource.path_to_secret}"

        varnish_args << "-P /var/run/#{service_name}.pid"
        resource.options(pid_file: "/var/run/#{service_name}.pid")

        resource.command(varnish_args.join(' '))
        # service.stop_signal 'WINCH'
        # service.reload_signal 'USR1'
      end
    end
  end
end
