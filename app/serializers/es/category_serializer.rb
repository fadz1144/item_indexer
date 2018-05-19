module ES
  class CategorySerializer < ActiveModel::Serializer
    attributes :category_id, :parent_id, :name, :level
  end
end
