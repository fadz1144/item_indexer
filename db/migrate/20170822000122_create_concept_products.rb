class CreateConceptProducts < ActiveRecord::Migration[5.1]
  include ConceptMigrationHelper

  def change
    create_table :concept_products, id: false, comment: 'Concept specific attributes for product' do |t|
      add_primary_key_and_references(t, :product)
      add_active_and_status(t)
      add_name_and_description(t)
      t.string :pdp_url, limit: 255, comment: 'Product description page URL'
      add_source_timestamps(t)

      t.timestamps
    end
  end
end
