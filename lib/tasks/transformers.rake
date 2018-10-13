namespace :bridge do
  desc 'Builds the product index for (Bridge) Catalog'
  task 'run_transformation_job', [:source] => :environment do |_task, args|
    # Following ensures no quotes accidentally get in from being quoted without a shell decoding them
    source = args[:source].gsub(/['"]/, '').upcase
    puts "Running transformers for source: #{source}"
    job = Transform::TransformationJob.new
    job.perform(source)
  end
end
