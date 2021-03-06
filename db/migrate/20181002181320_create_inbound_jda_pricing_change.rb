require_relative '20170914170447_create_inbound_batches'

class CreateInboundJdaPricingChange < ActiveRecord::Migration[5.2]
  include InboundBatchReference
  def change
    create_table :inbound_jda_pricing_changes, primary_key: :id do |t|
      references_inbound_batch(t)
      t.integer :AUSTOR, null: false, comment: 'Store'
      t.integer :AUSKU, null: false, comment: 'SKU Number'
      t.string :AURMTH, limit: 1, null: false, comment: 'Regular Pricing Method'
      t.string :AUPMTH, limit: 1, null: false, comment: 'Promo Pricing Method'
      t.decimal :AUREGU, precision: 9, scale: 2, null: false, comment: 'Actual Current Price, Regular or Promotion'
      t.string :AUREAS, limit: 2, null: false, comment: 'Last Price Change Reason (Note: XX means no price changes ever done)'
      t.string :AUPRRS, limit: 2, null: false, comment: 'Last Promo Change Reason'
      t.string :AUDISC, limit: 1, null: false, comment: 'Discretionary Flag'
      t.decimal :AULREG, precision: 9, scale: 2, null: false, comment: 'Last Regular Price'
      t.date :AULRDT, null: false, comment: 'Last Regular Price Change Date'
      t.decimal :AUPCOF, precision: 2, scale: 0, null: false, comment: 'Percent Off'
      t.decimal :AUPCRP, precision: 9, scale: 2, null: false, comment: 'Percent Off Regular'
      t.decimal :AUDLOF, precision: 9, scale: 2, null: false, comment: 'Dollar Off'
      t.decimal :AUPRPR, precision: 9, scale: 2, null: false, comment: 'Promotional Price'
      t.decimal :AURGDQ, precision: 3, scale: 0, null: false, comment: 'Regular Deal Qty'
      t.decimal :AURGDP, precision: 9, scale: 2, null: false, comment: 'Regular Deal Price'
      t.decimal :AUPORD, precision: 9, scale: 2, null: false, comment: 'Percent Off Regular Deal Price'
      t.decimal :AUBOGO, precision: 3, scale: 0, null: false, comment: 'BOGO Percentage'
      t.decimal :AUPRDQ, precision: 3, scale: 0, null: false, comment: 'Promo Deal Qty'
      t.decimal :AUPRDP, precision: 9, scale: 2, null: false, comment: 'Promo Deal Price'
      t.decimal :AULRTL, precision: 9, scale: 2, null: false, comment: 'Lowest Retail Price'
      t.date :AULPDT, null: false, comment: 'Lowest Price Date'
      t.decimal :AUDGCD, precision: 2, scale: 0, null: false, comment: 'Deal Group Code'
      t.decimal :AUBGCD, precision: 2, scale: 0, null: false, comment: 'BOGO Deal Group Code'
      t.decimal :AUCATG, precision: 3, scale: 0, null: false, comment: 'Mix Match Catg Code'
      t.string :AURGEV, limit: 7, null: false, comment: 'Reg Price Evt/Count Page No.'
      t.string :AUDLEV, limit: 6, null: false, comment: 'Deal Price Event No.'
      t.string :AUPREV, limit: 6, null: false, comment: 'Promotional Event No.'
      t.date :AUCRDT, null: false, comment: 'Create Date'
      t.timestamp :DPSTDT, null: false, comment: 'Dynamic Pricing Start Date'
      t.string :DPRCRSNCD, limit: 2, null: false, comment: 'Dynamic Pricing Reason Code'
      t.string :DPCPNEX, limit: 1, null: false, comment: 'Coupon Exclude'
      t.string :DPBRSN, limit: 2, null: false, comment: 'Business Reason Code'
      t.string :DPRULE, limit: 2, null: false, comment: 'Price Set Rule Code'
      t.decimal :DPJDAPRC, precision: 9, scale: 2, null: false, comment: 'JDA Regular Price'
      t.string :DPAPPCD, limit: 3, null: false, comment: 'Application Codes'
      t.timestamp :DPCRTDT, null: false, comment: 'Current System Timestamp - Always sort by this ascending to get data in the right order'
      t.decimal :DPORGPRC, precision: 9, scale: 2, null: false, comment: 'MAYBE: Dynamic Pricing Original price'
      t.string :DPOPRSNCD, limit: 2, null: false, comment: 'MAYBE: Dynamic Pricing Original Price Reason Code'
      t.decimal :DPWASPRC, precision: 9, scale: 2, null: false, comment: 'Dynamic Pricing Was-Price'
      t.decimal :DPMAP, precision: 9, scale: 2, null: false, comment: 'Dynamic Pricing Minimum Advertised Price'
      t.timestamp :DPFUPRTS, null: false, comment: 'Dynamic Pricing Future Use Pr Timestamp'
      t.string :DPFUPRFLG, limit: 1, null: false, comment: 'Dynamic Pricing Future Use Pr Flag'
    end
  end
end
