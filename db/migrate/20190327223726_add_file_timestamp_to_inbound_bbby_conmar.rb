class AddFileTimestampToInboundBBBYConmar < ActiveRecord::Migration[5.2]
  def change
    add_column :inbound_dw_contribution_margin_feed, :file_mod_time, :timestamp
  end
end
