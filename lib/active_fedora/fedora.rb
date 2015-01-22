module ActiveFedora
  class Fedora
    def initialize(config)
      @config = config
      init_base_path
    end

    def host
      @config[:url]
    end

    def base_path
      @config[:base_path] || '/'
    end

    def username
      @config[:user]
    end

    def password
      @config[:password]
    end

    def connection
      if username and password
        @connection ||= Ldp::Client.new(host, username, password)
      else
        @connection ||= Ldp::Client.new(host)
      end
    end

    SLASH = '/'.freeze
    BLANK = ''.freeze

    # Call this to create a Container Resource to act as the base path for this connection
    def init_base_path
        connection.get(root_resource_path)
        ActiveFedora::Base.logger.info "Attempted to init base path `#{root_resource_path}`, but it already exists" if ActiveFedora::Base.logger
        return false
    rescue Ldp::NotFound
      if !host.downcase.end_with?("/rest")
        ActiveFedora::Base.logger.warn "Fedora URL (#{host}) does not end with /rest. This could be a problem. Check your fedora.yml config"
      end
      connection.put(root_resource_path, BLANK).success?
    end

    # Remove a leading slash from the base_path
    def root_resource_path
      @root_resource_path ||= base_path.sub(SLASH, BLANK)
    end

  end
end
