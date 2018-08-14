namespace :xpdm do # rubocop:disable all
  desc 'Verify token ENABLE_PDM_CONNECTION is present'
  task :verify_token do
    if ENV.fetch('ENABLE_PDM_CONNECTION', 'false') == 'false'
      raise 'XPDM export requires connection to PDM; please confirm connection then set token ENABLE_PDM_CONNECTION'
    end
  end

  desc 'Build concept cache'
  task build_concept_cache: %i[environment] do
    Transform::ConceptCache.build
  end

  desc 'Verify dummy brand exists'
  task verify_dummy_brand: %i[environment] do
    External::MissingBrandService.no_brand_assigned
  end

  desc 'Load support data'
  task load_support_data: %i[verify_token environment build_concept_cache] do
    External::XPDM::SupportDataExport.new.perform(false)
  end

  desc 'Load products, optionally pass divisor and modulu (`xpdm:load_products[5,3]` for the 20% in the middle)'
  task :load_products, %i[divisor modulus] =>
    %i[verify_token verify_dummy_brand environment build_concept_cache] do |_task, args|
    divisor = (args.divisor || 5).to_i
    modulus = (args.modulus || 1).to_i
    External::DirectLoadService
      .new(External::XPDM::ProductMembershipLoader.new)
      .partial(External::XPDM::ProductMembership.modulo(divisor, modulus))
    External::DirectLoadService
      .new(External::XPDM::ProductLoader.new)
      .partial(External::XPDM::Product.modulo(divisor, modulus))
  end

  desc 'Load skus (for products)'
  task load_product_skus: %i[verify_token environment build_concept_cache] do
    External::DirectLoadService
      .new(External::XPDM::ProductSkuLoader.new(true))
      .full
  end

  desc 'Load skus'
  task load_skus: %i[verify_token environment build_concept_cache] do
    External::DirectLoadService
      .new(External::XPDM::SkuLoader.new(true))
      .full
  end

  desc 'One task to rule them all'
  task load_all_data: %i[load_support_data load_products load_skus]

  desc 'Load inventory changes'
  task incremental_inventory: %i[verify_token environment] do
    External::DirectLoadService
      .new(External::ECOM::InventoryLoader.new)
      .incremental
  end

  desc 'Load missing images'
  task load_missing_images: %i[verify_token environment] do
    External::DirectLoadService
      .new(External::XPDM::MissingImagesLoader.new)
      .full
  end

  desc 'Load missing vendors'
  task load_missing_vendors: %i[verify_token environment] do
    External::XPDM::VendorLoader.new.load_missing
  end

  desc 'Truncate and reload local product membership'
  task reload_product_membership: %i[verify_token environment] do
    External::XPDM::ProductMembershipLocal.connection.truncate(:xpdm_product_memberships)
    External::DirectLoadService
      .new(External::XPDM::ProductMembershipLoader.new)
      .full
  end

  desc 'Load products and skus for missing vendors'
  task load_data_for_missing_vendors: %i[verify_token environment build_concept_cache] do
    missing = External::XPDM::ItemVendor.where(pmry_vdr_num: External::XPDM::VendorView::MISSING_VENDORS)
    External::DirectLoadService
      .new(External::XPDM::ProductLoader.new)
      .partial(External::XPDM::Product.web_product.joins(:item_vendor).merge(missing))

    External::DirectLoadService
      .new(External::XPDM::SkuLoader.new)
      .partial(External::XPDM::Sku.beyond_sku.joins(:item_vendor).merge(missing))
  end

  desc 'Catch up on changes in chunks'
  task :incremental_catch_up, %i[start stop] =>
    %i[verify_token environment build_concept_cache] do |_task, args|
    start = args.start.to_datetime
    stop = args.stop.to_datetime
    Rails.logger.info "xpdm::incremental_catch_up from #{start} to #{stop}"
    External::DirectLoadService
      .new(External::XPDM::ProductLoader.new)
      .partial(External::XPDM::Product.web_product.where(update_ts: (start..stop)))

    External::DirectLoadService
      .new(External::XPDM::SkuLoader.new)
      .partial(External::XPDM::Sku.beyond_sku.where(update_ts: (start..stop)))
  end

  desc 'Load product and sku changes, ' \
       'optional last updated timestamp (`rails xpdm:incremental_products_and_skus[2018-10-27T00:00]`)'
  task :incremental_products_and_skus, %i[updates_since] =>
    %i[verify_token environment build_concept_cache reload_product_membership] do |_task, args|
    updates_since = args.updates_since&.to_datetime
    Rails.logger.info "xpdm::incremental_products_and_skus #{updates_since}"
    External::DirectLoadService.new(External::XPDM::ProductLoader.new).incremental(updates_since)
    External::DirectLoadService.new(External::XPDM::SkuLoader.new).incremental(updates_since)
  end

  desc 'Test connectivity'
  task test_connectivity: %i[verify_token environment] do
    puts "Product count from PC: #{CatModels::Product.count}"
    puts "Product count from XPDM: #{External::XPDM::Product.count}"
  end
end
