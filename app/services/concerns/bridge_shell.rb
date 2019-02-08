require 'open3'

module BridgeShell
  class NonzeroExitStatus < RuntimeError; end
  def shell_cmd(args)
    stdout, stderr, status = Open3.capture3(*args)
    raise NonzeroExitStatus, "Error running: #{args.join(' ')} #{stderr}" unless status.success?
    STDERR.puts(stderr) if stderr.to_s != ''
    stdout
  end
end
