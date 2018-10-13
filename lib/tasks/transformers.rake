namespace :bridge do
  desc 'Builds the product index for (Bridge) Catalog'
  task 'run_transformation_job', [:source] => :environment do |_task, args|
    source = args[:source].upcase
    puts "Running transformers for source: #{source}"
    job = Transform::TransformationJob.new
    job.perform(source)
  end
end
