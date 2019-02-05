namespace :bridge do
  namespace :updates do
    desc 'switch logger to stdout'
    task to_stdout: [:environment] do
      Rails.logger.extend(ActiveSupport::Logger.broadcast(ActiveSupport::Logger.new(STDOUT)))
    end

    desc 'Update web_flags_summary from web_status'
    task web_flags_summary: %i[environment to_stdout] do
      CatalogUpdates::WebFlagsSummary.each { |model| CatalogUpdates::UpdateService.new(model).execute }
    end

    desc 'Update chain status from letter to value (A -> Active'
    task chain_status: %i[environment to_stdout] do
      CatalogUpdates::ChainStatus.each { |model| CatalogUpdates::UpdateService.new(model).execute }
    end

    desc 'Update OKL concept product and product web status'
    task okl_product_web_status: %i[environment to_stdout] do
      CatalogUpdates::UpdateService.new(CatalogUpdates::OKL::ConceptProductWebStatus.new).execute
      CatalogUpdates::OKL::ProductWebStatus.each { |status| CatalogUpdates::UpdateService.new(status).execute }
    end

    desc 'Update OKL concept sku web status'
    task okl_concept_sku_web_status: %i[environment to_stdout] do
      CatalogUpdates::UpdateService.new(CatalogUpdates::OKL::ConceptSkuWebStatus.new).execute
      CatalogUpdates::UpdateService.new(CatalogUpdates::OKL::SkuWebStatus.new).execute
    end

    desc 'Update false positive vdc_sku from 12-11 update'
    task xpdm_sku_vdc_sku: %i[environment to_stdout] do
      CatalogUpdates::UpdateService.new(CatalogUpdates::XPDM::SkuVDC.new).execute
    end

    desc 'Update null sku chain status to Unknown (OKL Skus)'
    task null_chain_status: %i[environment to_stdout] do
      CatalogUpdates::UpdateService.new(CatalogUpdates::NullChainStatus.new).execute
    end

    desc 'Update null web_flags_summary from web_status'
    task null_web_flags_summary: %i[environment to_stdout] do
      CatalogUpdates::NullWebFlagsSummary.each { |model| CatalogUpdates::UpdateService.new(model).execute }
    end
  end
end
