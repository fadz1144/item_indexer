module PDM
  # = Web Status
  #
  # Module Web Status handles the logic to get from the web site code, web disable indicator, and web offer date to the
  # web status. If a class responds to these three methods, then it can include this module:
  # - web_offer_ind
  # - web_dsable_ind
  # - web_offer_dt
  module WebStatus
    def active?
      web_offer_ind == 'Y' && web_dsable_ind == 'N'
    end

    def in_progress?
      web_offer_ind == 'Y' && web_dsable_ind == 'Y' && web_enable_dt.nil?
    end

    def suspended?
      (web_offer_ind == 'N' && web_dsable_ind == 'Y') ||
        (web_offer_ind == 'Y' && web_dsable_ind == 'Y' && web_enable_dt.present?)
    end

    def buyer_reviewed?
      web_offer_ind == 'N' && web_dsable_ind == 'N'
    end

    def web_status
      if active?
        CatModels::WebStatus::ACTIVE
      elsif in_progress?
        CatModels::WebStatus::IN_PROGRESS
      elsif suspended?
        CatModels::WebStatus::SUSPENDED
      else
        CatModels::WebStatus::BUYER_REVIEWED
      end
    end
  end
end
