module CatalogTransformer
  module Associations
    extend ActiveSupport::Concern

    # Associations are a set of class methods that enable a transformer to indicate that additional records should also
    # be populated during the transformation. The associations follow the relationship logic as ActiveRecord.
    #
    # == Belongs To
    #
    # The belongs_to method specifies a singular association. If the name of the association on the source model is not
    # the same, then it can be specified with the source_name parameter. If the name of the transformer for the
    # association is different than the name of the association, then it can be specified with the transformer_name
    # parameter.
    #
    # == Has One
    #
    # This uses the same logic as belongs_to.
    #
    # == Has Many
    #
    # The has_many method specifies a collection association. The source_name and transformer_name use the same logic as
    # the belongs_to association. In order to match up the target and source items, this association allows one or more
    # attributes to be specified as match_keys. If there is only one match key and it is simply a singular version of
    # the association plus _id, it does not need to be specified.
    module ClassMethods
      def belongs_to(name, source_name: nil, transformer_name: nil, match_keys: nil)
        add_singular_association(name, source_name, transformer_name, match_keys)

        # do not try to assign the foreign key; assigning the belongs to association will do this
        exclude association_foreign_key(name)
      end

      def has_one(name, source_name: nil, transformer_name: nil) # rubocop:disable Naming/PredicateName
        add_singular_association(name, source_name, transformer_name, nil)
      end

      # rubocop:disable Naming/PredicateName
      def has_many(name, source_name: nil, transformer_name: nil, match_keys: nil)
        associations <<
          CatalogTransformer::Associations::CollectionAssociation.new(
            name, source_name, derive_transformer(name.to_s.singularize, transformer_name),
            derive_match_key(name, match_keys)
          )
      end
      # rubocop:enable Naming/PredicateName

      def associations
        @associations ||= []
      end

      # enables eager loading of data to be updated as well as validations that will fire at save
      def target_includes
        associations.map(&:target_includes) + additional_belongs_to_on_target
      end

      def source_includes_from_associations
        associations.map(&:source_includes).compact
      end

      private

      def add_singular_association(name, source_name, transformer_name, match_keys)
        associations <<
          CatalogTransformer::Associations::SingularAssociation.new(name,
                                                                    source_name,
                                                                    derive_transformer(name, transformer_name),
                                                                    match_keys)
      end

      def association_foreign_key(name)
        target_class.reflect_on_association(name.to_s).association_foreign_key
      end

      # if the transformer name is just the association name, then it does not need to be specified
      def derive_transformer(association, transformer)
        return transformer if transformer.present?
        namespace = name.deconstantize
        "#{namespace}::#{association.to_s.camelcase}"
      end

      # if there is a single match key and it is just the singular version of the association plus _id,
      # it does not need to be specified
      def derive_match_key(association, match_keys)
        match_keys.presence || "#{association.to_s.singularize}_id"
      end

      # if the target class has a belongs to that's not updated, it still tries to validate;
      # adding them to the target includes means that can be done with eager loading
      def additional_belongs_to_on_target
        target_class.reflect_on_all_associations.select(&:belongs_to?).map(&:name) - associations.map(&:name)
      end
    end

    def associations
      self.class.associations
    end
  end
end
