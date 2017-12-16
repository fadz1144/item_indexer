module CatalogTransformer
  module Attributes
    # = Reference Attribute
    #
    # A Reference Attribute is used when a model has a belongs to association and the transformation sets the foreign
    # key but does not update any attributes on the association.
    #
    # For example, a Player transformation might set which team the player is on, but it would not set any attributes of
    # the team itself. (On the other hand, if the player data included team attributes to be updated, then the player
    # transformation would indicate the relationship with a belongs_to association rather than a references.)
    #
    # Why a reference attribute instead of a regular attribute? If the target model has a belongs to association, then
    # saving the foreign key for that association (team_id from the example above) will fire off a query to the database
    # to validate the team Id. This can be prevented by assigned an instance of the team instead of it's Id.
    #
    # As reference attribute is only used when the target model has a belongs to association on it. It also requires the
    # source model to have the same association on it. The association on the source does not have to be a belongs to
    # (it can also be a has one); and the name can be different on the source (that requires setting the source_name
    # parameter).
    #
    # == Examples
    #
    # The following examples are for a target model with a belongs to association named :team.
    #
    # The source has an association named :team
    #   [No reference needed, it will be generated automatically.]
    #
    # The source association :player_affiliation has the association :team
    #   references :team, association: :player_affiliation
    #
    # The source association is named :manager
    #   references :team, source_name: :manager
    #
    # The source association player_affiliation has the association under the name :manager
    #   references :team, association: :player_affiliation, source_name: :manager
    class ReferenceAttribute < Attribute
      def target_includes
        @name
      end

      def source_includes
        @association.present? ? { @association => source_name } : source_name
      end
    end
  end
end
