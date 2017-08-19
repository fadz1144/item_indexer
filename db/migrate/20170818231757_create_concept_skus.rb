class CreateConceptSkus < ActiveRecord::Migration[5.1]
  include ConceptMigrationHelper

  def change
    create_table :concept_skus, id: false, comment: 'Concept-specific attributes for SKU' do |t|
      add_primary_key_and_references(t, :sku)
      add_active_and_status(t)
      t.string :status_reason_cd, limit: 5, comment: 'Optional reason code for the SKU/concept status'
      add_name_and_description(t)
      t.string :color, limit: 100, comment: 'Concept-specific SKU color'
      add_source_timestamps(t)

      t.timestamps
    end
  end
end
