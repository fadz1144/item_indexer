module SOLR
  def self.notify_and_exit(exception, description)
    Honeybadger.notify(exception, tags: 'indexing, batch, fail', context: { description: description })
    STDERR.puts(description)
    STDERR.puts exception.class.name
    STDERR.puts exception.message
    STDERR.puts exception.backtrace
    exit(1) # rubocop:disable Rails/Exit
  end
end
