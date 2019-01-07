namespace :xpdm do
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

  desc 'Load collections'
  task load_collections: %i[verify_token environment build_concept_cache] do
    External::DirectLoadService.new(External::XPDM::CollectionLoader.new).full
  end

  desc 'Load tags for products and skus (one-time only, does not check for existing values!)'
  task load_tags: %i[verify_token environment build_concept_cache] do
    External::DirectLoadService.new(External::XPDM::ProductTagLoader.new).full
    External::DirectLoadService.new(External::XPDM::SkuTagLoader.new).full
  end

  desc 'One task to rule them all'
  task load_all_data: %i[load_support_data load_products load_skus]

  desc 'Load inventory changes'
  task incremental_inventory: %i[verify_token environment] do
    External::DirectLoadService
      .new(External::ECOM::InventoryLoader.new)
      .incremental
  end

  desc 'Load Commerce Hub changes'
  task :incremental_commerce_hub, %i[updates_since] => %i[verify_token environment build_concept_cache] do |_task, args|
    updates_since = args.updates_since&.to_datetime
    Rails.logger.info "xpdm::incremental_commerce_hub #{updates_since}"
    External::DirectLoadService
      .new(External::ECOM::CommerceHubLoader.new)
      .incremental(updates_since)
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
    Rails.logger.info 'xpdm:reload_product_membership'
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

  desc 'Incremental brand updates'
  task :incremental_brand_updates, %i[updates_since] =>
    %i[verify_token environment build_concept_cache] do |_task, args|
    updates_since = args.updates_since&.to_datetime
    Rails.logger.info "xpdm::incremental_brands #{updates_since}"
    External::DirectLoadService.new(External::XPDM::BrandLoader.new).incremental(updates_since)
  end

  desc 'Incremental product updates'
  task :incremental_product_updates, %i[updates_since] =>
    %i[verify_token environment build_concept_cache reload_product_membership] do |_task, args|
    updates_since = args.updates_since&.to_datetime
    Rails.logger.info "xpdm::incremental_products #{updates_since}"
    External::DirectLoadService.new(External::XPDM::ProductLoader.new).incremental(updates_since)
  end

  desc 'Incremental collection updates'
  task :incremental_collection_updates, %i[updates_since] =>
    %i[verify_token environment build_concept_cache] do |_task, args|
    updates_since = args.updates_since&.to_datetime
    Rails.logger.info "xpdm::incremental_collections #{updates_since}"
    External::DirectLoadService.new(External::XPDM::CollectionLoader.new).incremental(updates_since)
  end

  desc 'Incremental sku updates'
  task :incremental_sku_updates, %i[updates_since] => %i[verify_token environment build_concept_cache] do |_task, args|
    updates_since = args.updates_since&.to_datetime
    Rails.logger.info "xpdm::incremental_skus #{updates_since}"
    External::DirectLoadService.new(External::XPDM::SkuLoader.new).incremental(updates_since)
  end

  desc 'Incremental updates with ' \
       'optional last updated timestamp (`rails xpdm:incremental_updates[2018-10-27T00:00]`)'
  task :incremental_updates, %i[updates_since] =>
    %i[incremental_brand_updates incremental_product_updates incremental_collection_updates incremental_sku_updates]

  desc 'Updates for items without a brand'
  task update_items_without_brand: %i[verify_token environment build_concept_cache] do
    Rails.logger.info 'xpdm::update_items_without_brand'
    External::DirectLoadService
      .new(External::XPDM::ProductLoader.new)
      .partial(External::XPDM::Product.web_product.where(brand_cd: nil).updates_since('2018-10-03'.to_datetime))
    External::DirectLoadService
      .new(External::XPDM::CollectionLoader.new)
      .partial(External::XPDM::Collection.web_collection.where(brand_cd: nil).updates_since('2018-11-29'.to_datetime))
    External::DirectLoadService
      .new(External::XPDM::SkuLoader.new)
      .partial(External::XPDM::Sku.beyond_sku.where(brand_cd: nil).updates_since('2018-10-03'.to_datetime))
  end

  desc 'Test connectivity'
  task test_connectivity: %i[verify_token environment] do
    puts "Product count from PC: #{CatModels::Product.count}"
    puts "Product count from XPDM: #{External::XPDM::Product.count}"
  end

  desc 'Backfill product web status'
  task backfill_product_web_status: %i[verify_token environment] do
    External::DirectLoadService.new(External::XPDM::ProductWebStatusBackfill.new).full
  end

  desc 'Backfill sku web status'
  task backfill_sku_web_status: %i[verify_token environment] do
    External::DirectLoadService.new(External::XPDM::SkuWebStatusBackfill.new).full
  end

  desc 'Reload items with spurious vendor rows'
  task reload_items_with_spurious_vendor_rows: %i[verify_token environment build_concept_cache] do
    Rails.logger.info 'xpdm:reload_items_with_spurious_vendor_rows'
    sub_query = 'pdm_object_id in (select pdm_object_id from pdm_item_prmry_vdr_info where pmry_vdr_num = 0)'
    External::DirectLoadService.new(External::XPDM::ProductLoader.new)
                               .partial(External::XPDM::Product.web_product.where(sub_query))
    External::DirectLoadService.new(External::XPDM::CollectionLoader.new)
                               .partial(External::XPDM::Collection.web_collection.where(sub_query))
    External::DirectLoadService.new(External::XPDM::SkuLoader.new)
                               .partial(External::XPDM::Sku.beyond_sku.where(sub_query))
  end
end
