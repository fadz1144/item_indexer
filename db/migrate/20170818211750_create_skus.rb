class CreateSkus < ActiveRecord::Migration[5.1]
  def change
    create_table :skus, id: false do |t|
      t.primary_key :sku_id, null: false, comment: 'ID in BBBY systems'
      t.integer :gtin, limit: 8, comment: 'UPC or EAN', index: true
      t.string :unit_of_measure_cd, limit: 3, comment: 'Unit of measure code'
      t.boolean :vmf, comment: 'is VMF flag for OKL items?'
      t.string :color_family, limit: 20, comment: 'SKU color family'
      t.boolean :non_taxable, comment: 'is item non-taxable?'
      t.boolean :vintage, comment: 'is vintage?'
      t.timestamps
    end
  end
end
