namespace :data_maintenance do
  desc 'clear margin from Canada skus when price and cost currency indeterminate'
  task clear_canada_margin: :environment do
    DataMaintenance::CanadianMarginRemover.new.perform
  end
end
