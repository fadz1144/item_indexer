module External
  module XPDM
    class VendorView < External::XPDM::Base
      self.table_name = 'pdm_item_prmry_vdr_info'
      self.primary_key = 'pmry_vdr_num'
      default_scope do
        where.not(pmry_vdr_num: 0)
             .select(:pmry_vdr_num, 'max(pmry_vdr_name) as pmry_vdr_name')
             .group(:pmry_vdr_num)
      end
      attribute :pmry_vdr_name, :xpdm_string

      MISSING_VENDORS = [68801, 68803, 68804, 68809, 68811, 68812, 68813, 68814, 68819, 68820, 68821, 68825, 68826, 68827, 68830, 68831, 68833, 68834, 68845, 68848, 68849, 68862, 68872, 68873, 68882, 68884, 68885, 68889, 68892, 68895, 68897, 68898, 68899, 68902, 68905, 68906, 68910, 68911, 68913, 68916, 68918, 68921, 68929, 68930, 68932, 68933, 68935, 68944, 68946, 68948, 68949, 68951, 68952, 68954, 68958, 68959, 68960, 68961, 68962, 68963, 68964, 68965, 68969, 68970, 68971, 68972, 68974, 68975, 68977, 68980, 68981, 68982, 68983, 68984, 68986, 68987, 68989, 69000, 69001, 69002, 69003, 69004, 69006, 69007, 69008, 69011, 69013, 69018, 69022, 69023, 69024, 69025, 69028, 69029, 69030, 69033, 69035, 69037, 69039, 69043, 69047, 69051, 69052, 69053, 69054, 69056, 69057, 69058, 69059, 69061, 69062, 69065, 69067, 69069, 69070, 69074, 69075, 69076, 69078, 69080, 69081, 69082, 69083, 69084, 69086, 69089, 69090, 69091, 69093, 69094, 69095, 69097, 69098, 69099, 69105, 69106, 69107, 69108, 69109, 69110, 69111, 69112, 69115, 69116, 69121, 69123, 69125, 69127, 69135, 69138, 69139, 69143, 69144, 69145, 69147, 69148, 69149, 69150, 69157, 69160, 69165, 69166, 69167, 69169, 69170, 69173, 69181, 69185, 69186, 69189, 69195, 69196, 69297, 69298, 69302, 69303, 69311, 69313, 69314, 69315, 69319, 69328, 69331, 69332, 69333, 69334, 69335, 69341, 69343, 69344, 69346, 69347, 69348, 69353, 69356, 69359, 69360, 69363, 69364, 69376, 69379, 69387, 69388, 69392, 69394, 69396, 69403, 69404, 69406, 69407, 69409, 69413, 69421, 69423, 69427, 69429, 69438, 69440, 69447, 69449, 69451, 69453, 69455, 69456, 69461, 69462, 69463, 69474, 69475, 69477, 69486, 69487, 69489, 69493, 69506, 69508, 69517, 69518, 69524, 69526, 69530, 69535, 69539, 69553, 69559, 69562, 69569, 69574, 69602, 69611, 69613, 69620, 69622, 69626, 69635, 69645, 69648, 69652, 69661, 69667, 69676, 638387].freeze # rubocop:disable Style/NumericLiterals, Metrics/LineLength

      def self.missing
        where(pmry_vdr_num: [MISSING_VENDORS])
      end

      def self.current_missing
        where(pmry_vdr_num: [missing_vendor_ids])
      end

      # returns vendor ids which are currently missing in our system
      def self.missing_vendor_ids
        curr = CatModels::ConceptVendor.pluck(:source_vendor_id)
        total = External::XPDM::VendorView.pluck(:pmry_vdr_num)
        res = total - curr
        Rails.logger.info "Missing vendors: #{res}"
        res
      end

      def self.create_zero_vendor
        return if CatModels::ConceptVendor.where(source_vendor_id: 0).exists?
        dummy_name = 'DUMMY VENDOR ASSIGNED'
        vendor = CatModels::Vendor.find_or_create_by!(name: dummy_name)
        CatModels::ConceptVendor.create!(source_vendor_id: 0, concept_id: 99, vendor: vendor,
                                         source_created_by: 0, name: dummy_name,
                                         source_created_at: Time.zone.now,
                                         source_updated_at: Time.zone.now)
      end

      def vendor_num
        pmry_vdr_num
      end

      def vendor_name
        pmry_vdr_name
      end

      def source_created_at
        Time.zone.now
      end

      def source_updated_at
        source_created_at
      end
    end
  end
end
