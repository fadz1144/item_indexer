module External
  class MissingBrandService
    def self.no_brand_assigned
      @no_brand_assigned ||=
        CatModels::Brand.includes(:concept_brands).find_by!(name: 'No Brand Assigned')
    end
  end
end
