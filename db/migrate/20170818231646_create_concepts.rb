class CreateConcepts < ActiveRecord::Migration[5.1]
  def change
    create_table :concepts, id: false, comment: 'Master concept definition' do |t|
      t.primary_key :concept_id, comment: 'Concept Id'
      t.string :name, limit: 30, null: false, comment: 'Name'
      t.string :abbreviation, limit: 8, null: false, comment: 'Abbreviation'
      t.string :legal_name, limit: 100, null: false, comment: 'Legal name'
      t.timestamps
    end
  end
end

# helper methods for concept-specific tables such as concept_skus and concept_brands
module ConceptMigrationHelper
  def add_concept_common_fields(t, name)
    add_primary_key_and_references(t, name)
    add_active_and_status(t)
    add_name_and_description(t)
    add_source_timestamps(t)
  end

  def add_primary_key_and_references(t, name)
    t.primary_key "concept_#{name}_id", comment: "Unique id for concept + #{name} intersection"
    t.references name, foreign_key: { primary_key: "#{name}_id", name: "#{t.name}__fk_#{name}_id" }, type: :integer, limit: 8, null: false, comment: "Global #{name} Id"
    t.references :concept, foreign_key: { primary_key: :concept_id, name: "#{t.name}__fk_concept_id" }, type: :integer, limit: 8, null: false
    t.integer "source_#{name}_id", limit: 8, null: false, comment: "#{name.to_s.titleize} Id in source system"
  end

  def add_active_and_status(t)
    t.boolean :active, null: false, comment: 'Concept-specific active flag'
    t.string :status, limit: 10, null: false, comment: 'Concept-specific status'
  end

  def add_name_and_description(t)
    t.string :name, limit: 100, comment: 'Concept-specific name'
    t.string :description, limit: 1000, comment: 'Concept-specific description'
  end

  def add_source_timestamps(t)
    t.integer :source_created_by, limit: 8, null: false, default: 0
    t.datetime :source_created_at, null: false
    t.integer :source_updated_by, limit: 8, null: false, default: 0
    t.datetime :source_updated_at, null: false
  end
end
