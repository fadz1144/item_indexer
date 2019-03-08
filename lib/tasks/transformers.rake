namespace :bridge do
  desc 'Runs a transformation job by source, pass source in [brackets].'
  task 'run_transformation_job', [:source] => :environment do |_task, args|
    # Following ensures no quotes accidentally get in from being quoted without a shell decoding them
    source = args[:source].gsub(/['"]/, '').upcase
    puts "Running transformers for source: #{source}"
    job = Transform::TransformationJob.new
    job.perform(source)
  end

  desc 'Transform JDA pricing and clear suspicious CA margin'
  task transform_jda: :environment do
    Transform::TransformationJob.new.perform('JDA')
    DataMaintenance::CanadianMarginRemover.new.perform
  end
end
