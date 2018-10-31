module External
  module XPDM
    # = Web Info Site
    #
    # Attributes:
    # - web_site_cd
    # - afs_fulfl_cd
    # - blck_status_ind
    # - clr_promo_vld_status_ind
    # - flg_off_dt
    # - flg_off_rsn_cd
    # - frc_blw_registry_ln_ind
    # - free_shp_promo_vld_status_ind
    # - web_afs_qty
    # - web_enable_dt
    # - web_status_flg (A / D / I / N / P / U)
    class WebInfoSite < External::XPDM::Base
      self.table_name = 'pdm_item_web_info_site'
      belongs_to :item, foreign_key: :pdm_object_id, primary_key: :pdm_object_id, inverse_of: :web_info_sites
    end
  end
end
