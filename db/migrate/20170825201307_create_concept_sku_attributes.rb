class CreateConceptSkuAttributes < ActiveRecord::Migration[5.1]
  include ConceptMigrationHelper

  def change
    create_table :concept_sku_attributes, id: false, comment: 'Concept-specific sparse sku attributes' do |t|
      t.primary_key :concept_sku_attribute_id, comment: "Unique id for concept + sku + attribute intersection"
      t.references :sku, foreign_key: { primary_key: :sku_id, name: :csku_attributes__fk_sku_id }, type: :integer, limit: 8, null: false, comment: "Global sku Id"
      t.references :concept, foreign_key: { primary_key: :concept_id, name: :csku_attributes__fk_concept_id }, type: :integer, limit: 8, null: false
      t.references :concept_sku, foreign_key: { primary_key: :concept_sku_id, name: :csku_attributes__fk_concept_sku_id }, type: :integer, limit: 8, null: false
      t.string :name, limit: 40, comment: 'Attribute name'
      t.string :value, limit: 255, comment: 'Attribute value'
      add_source_timestamps(t)

      t.timestamps
    end
  end
end
