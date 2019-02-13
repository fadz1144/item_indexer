module Transform
  module Transformers
    module XPDM
      # = Site Navigation Collection
      #
      # The Site Navigation Collection transformer is to backfill site navigations. The target will be the related
      # concept product or concept collection. The source will simply be an array of records; the association's source
      # name is 'itself', so it will use the array for the transformation.
      class SiteNavigationCollection < CatalogTransformer::Base
        specified_attributes_only # we are not transforming anything on the parent (concept product / collection)

        # since the source is the array of site_navigations, we want the transformer to call 'itself' on that array
        has_many :site_navigations, source_name: :itself,
                                    match_keys: %i[root_tree_node branch_tree_node leaf_tree_node]

        def apply_transformation(target, excluded_attributes = nil)
          target.extend(DelegateSaveToMembers)
          super
        end

        # the concept product / collection has not changed, so delegate validations and saves to the site navigations
        module DelegateSaveToMembers
          def valid?
            site_navigations.all?(&:valid?)
          end

          def save!
            site_navigations.each(&:save!)
          end

          def errors
            (site_navigations.find { |sn| !sn.errors.empty? } || site_navigations.first).errors
          end
        end
      end
    end
  end
end
