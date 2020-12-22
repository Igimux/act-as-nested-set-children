# USE .children method

def build_tree(category)
  categories = []

  category.children.preload(:children, :category_image).each do |node|
    child = API::V1::Entities::CategoryV1.represent(node, serializable: true)
    child['children'] = node.children.any? ? build_tree(node) : []

    categories << child
  end

  categories
end

categories = []

Category.roots.each do |category|
  cat = API::V1::Entities::CategoryV1.represent(category, serializable: true) # OR cat = category.attributes
  cat['children'] = build_tree(category)

  categories << cat
end

pp categories

#### OR use .self_and_descendants method

categories = []

collection.each do |root|
  category_levels = {}

  ::Category.each_with_level(root.self_and_descendants.includes(:category_image)) do |category, level|
    cat = API::V1::Entities::CategoryV1.represent(category, serializable: true) # OR cat = category.attributes
    cat['children'] = []

    category_levels[level] = cat

    if level == 0
      categories << cat
    elsif level > 0
      parent = category_levels[level - 1]
      parent['children'] << cat
    end
  end
end

