module External
  module XPDM
    class SupportDataExport
      def perform(generate_insert_scripts)
        @start = Time.zone.now
        load_catalog_tables
        generate_scripts if generate_insert_scripts
      end

      private

      def load_catalog_tables
        # [External::XPDM::ProductTreeLoader,
        #  External::XPDM::MerchTreeLoader,
        #  External::XPDM::SiteNavigationTreeLoader,
        #  External::XPDM::BrandLoader,
        #  External::XPDM::VendorLoader].each do |klass|
        [External::XPDM::MerchTreeLoader].each do |klass|
          Rails.logger.info "Starting #{klass.name}"
          klass.perform
        end
      end

      # this only works locally; you'd need a place to store the generated files to get it to run in the cloud
      def generate_scripts
        init_pdm_export_folder
        prefixes = ('a'...'z').to_a
        [CatModels::Brand, CatModels::ConceptBrand,
         CatModels::Vendor, CatModels::ConceptVendor,
         CatModels::Tree, CatModels::TreeNode].each_with_index do |model, i|
          arel = model.where(model.arel_attribute(:created_at).gt(@start))
          External::InsertScriptGenerator.new(arel, @folder_name, nil, "#{prefixes[i]}-").generate_inserts
        end
      end

      def init_pdm_export_folder
        @folder_name = 'pdm_export'
        folder_path = Rails.root.join('tmp', @folder_name)
        FileUtils.mv(folder_path, "#{folder_path}_#{Time.zone.now.to_i}") if File.exist?(folder_path)
        Dir.mkdir(folder_path)
      end
    end
  end
end
