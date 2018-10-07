class CreateXPDMProductMemberships < ActiveRecord::Migration[5.1]
  def change
    create_table :xpdm_product_memberships do |t|
      t.integer :pdm_object_id, limit: 8
      t.integer :item_code_name_cd, limit: 8
    end

    add_index :xpdm_product_memberships, %i[item_code_name_cd pdm_object_id], unique: true,
              name: 'idx_xpdm_product_memberships_sku_product'
  end
end
