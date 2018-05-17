class EnvVarBootstrap
  def initialize(filename, logger = Logger.new(STDERR), log_level = :warn)
    @should_overwrite = (ENV['RUBY_ENV_FILE_SHOULD_OVERWRITE_ENV'] != 'false')
    @filename = filename
    @file_vars = env_var_file_to_hash

    return if @file_vars.nil?
    # Don't do anything if file isn't present

    init_logger(logger, log_level)
    process_vars
  end

  private

  def process_vars
    info("#{self.class.name}: Using Environment Variables from #{@filename}.") if @file_vars.present?
    @file_vars.each do |var_name, value|
      if current_value_conflicts?(var_name, value)
        overwrite_if_appropriate(var_name, value)
      else
        set(var_name, value)
      end
      debug("  ENV[#{var_name}]=#{value}")
    end
  end

  def current_value_conflicts?(var_name, value)
    ENV.key?(var_name) && value != ENV[var_name]
  end

  def overwrite_if_appropriate(var_name, value)
    if @should_overwrite
      warn("Warning: Overwriting ENV[#{var_name}] from environment " "with value from #{File.basename(@filename)}")
      set(var_name, value)
    else
      warn("Warning: ENV[#{var_name}] already defined in environment, not"\
              ' overwriting because RUBY_ENV_FILE_SHOULD_OVERWRITE_ENV=false')
    end
  end

  def set(var_name, value)
    ENV[var_name] = value
  end

  def env_var_file_to_hash
    return nil unless File.exist?(@filename)
    file_data = {}
    File.open(@filename, 'r') do |file|
      lines_without_comments(file.readlines).each do |line|
        var_name, value = line.strip.split('=')
        file_data[var_name.strip] = value.strip unless var_name.nil?
      end
    end
    file_data
  end

  def lines_without_comments(lines)
    lines.map { |line| line.split('#').first.strip }.reject(&:blank?)
  end

  def init_logger(logger, log_level)
    @logger = logger
    @logger.level = log_level
    @logger.formatter = proc { |severity, _datetime, _progname, msg| "#{severity}: #{msg}\n" }
  end

  def info(str)
    # return puts(str)
    @logger.info(str)
  end

  def warn(str)
    # return puts(str)
    @logger.warn(str)
  end

  def debug(str)
    @logger.debug(str)
  end
end
