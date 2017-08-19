class CreateBrands < ActiveRecord::Migration[5.1]
  def change
    create_table :brands, id: false, comment: 'Brand definition' do |t|
      t.primary_key :brand_id, comment: 'Globally unique id for brand'
      t.string :name, limit: 100, comment: 'Brand name'

      t.timestamps
    end
  end
end
