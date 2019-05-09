# Load the Rails application.
require_relative 'application'

# Initialize the Rails application.
Rails.application.initialize!

# this is needed for estage data with no single primary key field, External::ECOM::SkuSales
require 'composite_primary_keys'