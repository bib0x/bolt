require 'bolt/result'
require 'bolt/config'
require 'bolt/target'
require 'logging'

module Bolt
  class Node
    STDIN_METHODS       = %w[both stdin].freeze
    ENVIRONMENT_METHODS = %w[both environment].freeze

    def self.from_target(target, **kwargs)
      klass = case target.protocol || kwargs[:config][:transport]
              when 'winrm'
                Bolt::WinRM
              when 'pcp'
                Bolt::Orch
              else
                Bolt::SSH
              end
      klass.new(target, **kwargs)
    end

    def self.initialize_transport(_logger); end

    attr_reader :logger, :user, :password, :connect_timeout, :target

    def initialize(target, config: Bolt::Config.new)
      @target = target

      transport_conf = config[:transports][protocol.to_sym]
      @user = @target.user || transport_conf[:user]
      @password = @target.password || transport_conf[:password]
      @key = transport_conf[:key]
      @cacert = transport_conf[:cacert]
      @tty = transport_conf[:tty]
      @insecure = transport_conf[:insecure]
      @connect_timeout = transport_conf[:connect_timeout]
      @sudo_password = transport_conf[:sudo_password]
      @run_as = transport_conf[:run_as]
      @tmpdir = transport_conf[:tmpdir]
      @service_url = transport_conf[:service_url]
      @token_file = transport_conf[:token_file]
      @orch_task_environment = transport_conf[:orch_task_environment]
      @extensions = transport_conf[:extensions]

      @logger = Logging.logger[@target.host]
    end

    def uri
      @target.uri
    end
  end
end

require 'bolt/node/errors'
require 'bolt/node/ssh'
require 'bolt/node/winrm'
require 'bolt/node/orch'
