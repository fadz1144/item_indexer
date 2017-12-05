class ChangeInboundSkuStateRevisions < ActiveRecord::Migration[5.1]
  def change
    rename_column :inbound_okl_sku_state_revisions, 'obsolete reason id', :obsolete_reason_id
    rename_column :inbound_okl_sku_state_revisions, 'obsolete reason name', :obsolete_reason_name
  end
end
