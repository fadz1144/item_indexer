# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

# do not load rails when running setup tasks
task_name = $*.first

if task_name&.start_with? 'setup:'
  load 'lib/tasks/setup.rake'
else
  require_relative 'config/application'
  Rails.application.load_tasks
end
