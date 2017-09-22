class CreateInboundOKLSkuDimensionsRevisions < ActiveRecord::Migration[5.1]
  include InboundBatchReference

  def change
    create_table :inbound_okl_sku_dimensions_revisions do |t|
      references_inbound_batch(t)
      t.integer :sku_id, limit: 8, null: false
      t.decimal :cost, precision: 8, scale: 2
      %w[item shipping].each { |type| add_dimension_fields(t, type) }
    end
  end

  private

  def add_dimension_fields(table, type)
    options = { precision: 8, scale: 2 }
    %w[width height length weight].each do |dim|
      table.decimal "#{type}_#{dim}", options
    end
  end
end
