desc 'Block forever so that a Docker container will stay up'
task 'block' do
  puts "Blocking.\n"
  n = 0
  loop do
    sleep 60
    n += 1
    print "\rI have been blocking for #{n} minutes.    " if n % 5 == 0
  end
end

desc 'Block forever but after loading the environment. Used for ensuring that configs work'
task 'block_with_environment' => :environment do
  puts "Blocking.\n"
  n = 0
  loop do
    sleep 60
    n += 1
    print "\rI have been blocking for #{n} minutes.    " if n % 5 == 0
  end
end
