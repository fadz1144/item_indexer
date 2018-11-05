namespace :bridge do
  namespace :updates do
    desc 'switch logger to stdout'
    task to_stdout: [:environment] do
      puts 'Attempting to log to STDOUT...'
      Rails.logger.extend(ActiveSupport::Logger.broadcast(ActiveSupport::Logger.new(STDOUT)))
      Rails.logger.info '...broadcasting to log and STDOUT'
    end

    desc 'Update web_flags_summary from web_status'
    task web_flags_summary: %i[environment to_stdout] do
      CatalogUpdates::WebFlagsSummary.each { |model| CatalogUpdates::UpdateService.new(model).execute }
    end
  end
end
