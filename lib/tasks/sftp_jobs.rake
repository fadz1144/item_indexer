namespace :sftp do
  desc 'Get contribution margin data from SFTP source and copy to inbound tables'
  task('get_contribution_margin_from_sftp' => :environment) { DataWarehouseImportOrchestrator.new.orchestrate }
end
