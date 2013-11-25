module RedashUtil
  def require_attribute(attr_lst)
    if ! _require_attribute(attr_lst, node)
      Chef::Application.fatal! "You must set the attribute #{attr_lst.join('.')}"
    end
    return true
  end

  # Given an attribute path expressed as a list,
  # recursively check for all items on the path being defined
  def _require_attribute(attr_lst, base)
    if attr_lst.nil? || attr_lst.empty?
      return true
    end
  
    if (! base.attribute? attr_lst.first) || base[attr_lst.first].nil?
      return false
    end
  
    return _require_attribute(attr_lst[1..-1], base[attr_lst.first])
  end
end

class Chef::Recipe
  include RedashUtil
end