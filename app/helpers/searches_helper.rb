module SearchesHelper
  
  # Return the model to be searched based on params.
  def search_model
    return "Person"    if params[:controller] =~ /home/
    return "ForumPost" if params[:controller] =~ /forums/ || params[:controller] =~ /topics/
    return "Contacts"  if params[:controller] =~ /connections/
    return "Group"     if params[:controller] =~ /groups/ or params[:action] =~ /groups/
    params[:model] || params[:controller].classify
  end
  
  def search_type
    if params[:controller] == "forums" or params[:model] == "ForumPost" or params[:controller] == "topics"
      t 'search.browse_forum' 
    elsif params[:controller] == "messages" or params[:model] == "Message"
      t 'search.search_message'
    elsif params[:controller] == "connections" or params[:model] == "Contacts"
      t 'search.search_contacts'
    elsif params[:controller].include?("groups") or params[:model] == "Group" or params[:action].include?("groups")
      t 'search.browse_groups'
    else
      t 'search.search_people'
    end
  end
  
  # Return the partial (including path) for the given object.
  # partial can also accept an array of objects (of the same type).
  def partial(object)
    object = object.first if object.is_a?(Array)
    klass = object.class.to_s
    case klass
    when "ForumPost"
      dir  = "topics" 
      part = "search_result"
    when "AllPerson"
      dir  = 'people'
      part = 'person'
    else
      dir  = klass.tableize  # E.g., 'Person' becomes 'people'
      part = dir.singularize # E.g., 'people' becomes 'person'
    end
    admin_search? ? "admin/#{dir}/#{part}" : "#{dir}/#{part}"
  end

  private
  
    def admin_search?
      params[:model] =~ /Admin/
    end
end
