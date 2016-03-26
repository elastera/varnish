require 'poise_service/service_mixin'

class Chef
  class Resource
    # Configure Varnish logging.
    class VarnishLog < Chef::Resource::LWRPBase
      include PoiseService::ServiceMixin

      default_action [:enable, :start]

      attribute :name, kind_of: String, name_attribute: true
      attribute :file_name, kind_of: String, default: '/var/log/varnish/varnishlog.log'
      attribute :logrotate, kind_of: [TrueClass, FalseClass], default: true
      attribute :logrotate_path, kind_of: String, default: '/etc/logrotate.d'
      attribute :pid, kind_of: String, default: '/var/run/varnishlog.pid'
      attribute :log_format, kind_of: String, default: 'varnishlog',
                             equal_to: ['varnishlog', 'varnishncsa']
      attribute :ncsa_format_string, kind_of: String,
                                     default: '%h|%l|%u|%t|\"%r\"|%s|%b|\"%{Referer}i\"|\"%{User-agent}i\"'
      attribute :instance_name, kind_of: String,
                                default: nil
    end
  end

  class Provider
    # Configure Varnish logging.
    class VarnishLog < Chef::Provider::LWRPBase
      include PoiseService::ServiceMixin

      def whyrun_supported?
        true
      end

      use_inline_resources

      def action_enable
        if new_resource.logrotate
          new_resource.pid("/var/run/#{new_resource.log_format}-#{new_resource.instance_name}.pid")
          template "#{new_resource.logrotate_path}/#{new_resource.log_format}" do
            source 'lib_logrotate_varnishlog.erb'
            path "#{new_resource.logrotate_path}/#{new_resource.log_format}"
            cookbook 'varnish'
            owner 'root'
            group 'root'
            mode '0644'
            variables(config: new_resource)
            action :create
            only_if { ::File.exist?(new_resource.logrotate_path) }
          end
        end
        super
      end

      # for poise-service
      def service_options(service)
        service_name = "#{new_resource.log_format}-#{new_resource.instance_name}"
        service.service_name(service_name)
        service.restart_on_update :immediately
        cmd = ["/usr/bin/#{new_resource.log_format}"]
        cmd << "-a"
        cmd << "-w #{new_resource.file_name}"
        cmd << "-n #{new_resource.instance_name}"
        if new_resource.log_format == "varnishncsa"
          cmd << "-F '#{new_resource.ncsa_format_string}'"
        end
        cmd << "-P /var/run/#{service_name}.pid"
        service.options(pid_file: "/var/run/#{service_name}.pid")
        service.command(cmd.join(' '))
      end
    end
  end
end
