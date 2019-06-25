module External
  module XPDM
    # = Web Info
    #
    # Attributes:
    # - pdm_object_id
    # - addnl_info_reasn_cd
    # - baby_only_ind
    # - blck_rqst_by
    # - blck_rsn_cd
    # - blck_rsn_name
    # - blck_rsn_comt_txt
    # - blck_start_dt
    # - blck_end_dt
    # - clctn_pdp_vw_txt
    # - cm_kywd_srch_tag_txt
    # - dsgnt_prod_txt
    # - dscntnu_wp_clctn_ind
    # - email_cust_for_oos_ind
    # - event_name
    # - fast_trk_ind
    # - fast_trk_flg_phto_ind
    # - free_shp_start_dt
    # - free_shp_end_dt
    # - have_vendor_web_copy_ind
    # - have_vendor_samp_ind
    # - intrnatl_shp_ind
    # - lead_item_prod_ind
    # - priority_flg
    # - phto_comt_txt
    # - pre_order_ind
    # - pre_order_start_dt
    # - pre_order_end_dt
    # - prvnt_auto_flg_on_ind
    # - prvnt_auto_flg_on_comt_txt
    # - prevnt_flg_off_reasn_cd
    # - item_tab_cd
    # - item_tab_name
    # - prod_guid_cd
    # - prod_guid_name
    # - school_cd
    # - school_name
    # - show_prod_thumbnail_ind
    # - tab_desc
    # - web_copy_cmplt_ind
    # - web_event_dt
    # - web_only_ind
    # - web_gf_card_sku_ind
    # - web_nav_start_ts
    # - web_nav_end_ts
    # - warranty_txt
    class WebInfo < External::XPDM::Base
      self.table_name = 'pdm_item_web_info'
      INCLUDED_COLUMNS = %w[pdm_object_id
                            blck_rsn_cd
                            blck_rsn_name
                            email_cust_for_oos_ind
                            blck_start_dt
                            blck_end_dt
                            web_copy_cmplt_ind].freeze

      default_scope -> { select(INCLUDED_COLUMNS) }

      belongs_to :item, foreign_key: :pdm_object_id, primary_key: :pdm_object_id, inverse_of: :web_info
      attribute :email_cust_for_oos_ind, :xpdm_boolean_ind
    end
  end
end
