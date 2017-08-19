class CreateConceptBrands < ActiveRecord::Migration[5.1]
  include ConceptMigrationHelper

  def change
    create_table :concept_brands, id: false, comment: 'Concept specific attribute for brand' do |t|
      add_concept_common_fields(t, :brand)
      t.timestamps
    end
  end
end
