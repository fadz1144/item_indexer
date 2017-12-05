class AddVendorSkuToInboundOKLSkuRevisions < ActiveRecord::Migration[5.1]
  def change
    change_table :inbound_okl_sku_revisions do |t|
      t.string :vendor_sku
    end
  end
end
