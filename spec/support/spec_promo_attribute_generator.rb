# rubocop:disable Metrics/AbcSize
# rubocop:disable Metrics/MethodLength
module SpecPromoAttributeGenerator
  def build_promo_attribute(item:, long_promo_cd:, concept_flags: 'YYY', dates: default_dates, update_ts: def_upd_ts)
    flags = concept_flags.chars
    item.promo_attribute_attachments.build(
      promo_cd: long_promo_cd,
      promo_start_dt: dates.first,
      promo_end_dt: dates[1],
      update_ts: update_ts
    ).tap do |attr|
      attr.all_concept_flags.build(web_site_cd: 'BBBY', promo_vld_status_ind: flags[0].casecmp('Y').zero?,
                                   promo_cd: long_promo_cd)
      attr.all_concept_flags.build(web_site_cd: 'CA',   promo_vld_status_ind: flags[1].casecmp('Y').zero?,
                                   promo_cd: long_promo_cd)
      attr.all_concept_flags.build(web_site_cd: 'BABY', promo_vld_status_ind: flags[2].casecmp('Y').zero?,
                                   promo_cd: long_promo_cd)
    end
  end

  def fake_promo_attrib_definition(promo_cd, name)
    External::XPDM::PromoAttributeDefinition.new(
      promo_cd: promo_cd,
      promo_atrib_val_name: name,
      promo_atrib_html_val_name: '<b>%s Site Description</b>' % name,
      image_url: '//s7d9.scene7.com/is/content/BedBathandBeyond/lol',
      actn_url: '/some/url'
    )
  end

  def default_dates
    [Time.zone.yesterday, Time.zone.today + 33]
  end

  def def_upd_ts
    Time.zone.now - 3.days
  end
end
# rubocop:enable Metrics/MethodLength
# rubocop:enable Metrics/AbcSize
