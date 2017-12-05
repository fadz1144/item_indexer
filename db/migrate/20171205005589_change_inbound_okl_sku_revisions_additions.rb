class ChangeInboundOKLSkuRevisionsAdditions < ActiveRecord::Migration[5.1]
  def up
    change_table :inbound_okl_sku_revisions do |t|
      t.integer :source_sku_id, limit: 8, null: false
      t.integer :source_product_id, limit: 8
      t.integer :brand_id, limit: 8
      t.integer :vendor_id, limit: 8
      t.integer :category_id, limit: 8
      t.string :name
      t.text :description
      t.boolean :active
      t.boolean :allow_exposure
      t.string :unit_of_measure_cd
      t.string :line_of_business
      t.boolean :vmf
      t.boolean :vintage
      t.boolean :non_taxable
      t.string :color
      t.string :color_family
      t.string :size
      t.string :materials
      t.string :era
      t.string :style
      t.string :care_instructions
      t.string :care_instructions_other
      t.decimal :map_price, precision: 8, scale: 2
      t.integer :source_created_by
      t.datetime :source_created_at
      t.integer :source_updated_by
      t.datetime :source_updated_at
    end
  end
  
  def down
    change_table :inbound_okl_sku_revisions do |t|
      t.remove :source_sku_id
      t.remove :source_product_id
      t.remove :brand_id
      t.remove :vendor_id
      t.remove :category_id
      t.remove :name
      t.remove :description
      t.remove :active
      t.remove :allow_exposure
      t.remove :unit_of_measure_cd
      t.remove :line_of_business
      t.remove :vmf
      t.remove :vintage
      t.remove :non_taxable
      t.remove :color
      t.remove :color_family
      t.remove :size
      t.remove :materials
      t.remove :era
      t.remove :style
      t.remove :care_instructions
      t.remove :care_instructions_other
      t.remove :map_price
      t.remove :source_created_by
      t.remove :source_created_at
      t.remove :source_updated_by
      t.remove :source_updated_at
    end
  end
end
