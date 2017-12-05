class AddFkToInboundOKLTables < ActiveRecord::Migration[5.1]
  def change
    %w[state shipping dimensions inventory image attribute].each { |name| add_reference(name) }
  end

  private

  def add_reference(name)
    change_table "inbound_okl_sku_#{name}_revisions" do |t|
      t.references :inbound_okl_sku_revisions, type: :integer, limit: 8,
                       index: { name: "#{t.name}__fk_inb_okl_sku" }
    end
  end
end
