require 'resque/tasks'
require 'resque/scheduler/tasks'

namespace :resque do
  task setup: :environment

  task setup_schedule: :setup do
    begin
      schedule = YAML.load_file(Rails.root.join('config', 'resque_schedule.yml'))
    rescue Errno::ENOENT
      schedule.nil? ? raise('Error starting resque schduler: no resque_schedule.yml found') : raise
    end

    Resque.schedule = schedule || {}
  end

  task scheduler: :setup_schedule
end
