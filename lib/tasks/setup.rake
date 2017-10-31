namespace :setup do
  desc 'Generate yaml files and download environment variables'
  task local_development: %i[deploy_yml download_aws_secrets]

  desc 'Generate yml files from .yml.deploy files'
  task deploy_yml: Rake::FileList.new('config/*.yml.deploy').ext

  rule '.yml' => '.yml.deploy' do |task|
    cp task.prerequisites.first, task.name, verbose: true
  end

  desc 'Download environment variables from AWS as .ruby-env'
  task :download_aws_secrets do
    download_aws_secrets
  end

  require 'nokogiri'
  desc 'Copies the environment variables from the .ruby-env into your rubymine development run configuration'
  task :rubymine_environment_variables do
    rubymine_env_vars
  end
end

private

def read_properties_file_to_hash(filename)
  file_data = {}
  File.open(filename, 'r') do |file|
    file.each_line do |line|
      line = line.strip!
      line_data = line.split('=')
      file_data[line_data[0]] = line_data[1]
    end
  end
  file_data
end

def replace_xml_env_with_props(filename, properties_hash)
  xml      = File.read(filename)
  doc      = Nokogiri::XML(xml)

  envs = doc.at_css 'envs'

  envs.children.each(&:remove)

  properties_hash.each do |key, value|
    envs << "<env name=\"#{key}\" value=\"#{value}\"/>"
  end

  File.write(filename, doc.to_xml)
end

def download_aws_secrets
  sh 'aws s3 cp s3://bbb-secrets/development/search_api.env .ruby-env'

  # same as cd'ing out and back in again; loads environment variables
  puts <<-INSTRUCTIONS

    Please run the following to load the environment variables:
    rvm use .

  INSTRUCTIONS
end

def rubymine_env_vars
  filename = '.idea/runConfigurations/Development__search_api.xml'
  if File.file?(filename)
    properties_hash = read_properties_file_to_hash('.ruby-env')

    # idea file name
    replace_xml_env_with_props(filename, properties_hash)
  else
    puts <<-INSTRUCTIONS

    You will need to start your Development: search_api server once and then re-run the rake task in order to
    auto-populate the environment variables.  Any questions, talk to Todd.

    INSTRUCTIONS
  end
end
