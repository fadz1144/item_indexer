class AddMerchHierarchyToInboundOKLSkuRevisionsAndProductRevisions < ActiveRecord::Migration[5.1]
  def change
    [:inbound_okl_product_revisions, :inbound_okl_sku_revisions].each do |table_name|
      change_table table_name do |t|
        t.integer :bbb_department_id
        t.integer :bbb_sub_department_id
        t.integer :bbb_class_id
      end
    end
  end
end
