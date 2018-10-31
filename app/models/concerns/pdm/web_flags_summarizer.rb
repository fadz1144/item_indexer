module PDM
  # = Web Flags Summarizer
  #
  # Module Web Flags Summarizer handles the logic to get from the web site code, web disable indicator, and web enable
  # date to the web status. If a class responds to these three methods, then it can include this module:
  # - web_offer_ind
  # - web_dsable_ind
  # - web_enable_dt
  module WebFlagsSummarizer
    def live_on_site?
      web_offer_ind == 'Y' && web_dsable_ind == 'N'
    end

    def in_workflow?
      web_offer_ind == 'Y' && web_dsable_ind == 'Y' && web_enable_dt.nil?
    end

    def suspended?
      (web_offer_ind == 'N' && web_dsable_ind == 'Y') ||
        (web_offer_ind == 'Y' && web_dsable_ind == 'Y' && web_enable_dt.present?)
    end

    def buyer_reviewed?
      web_offer_ind == 'N' && web_dsable_ind == 'N'
    end

    def web_flags_summary
      if live_on_site?
        CatModels::Constants::WebFlagsSummary::LIVE_ON_SITE
      elsif in_workflow?
        CatModels::Constants::WebFlagsSummary::IN_WORKFLOW
      elsif suspended?
        CatModels::Constants::WebFlagsSummary::SUSPENDED
      else
        CatModels::Constants::WebFlagsSummary::BUYER_REVIEWED
      end
    end
  end
end
