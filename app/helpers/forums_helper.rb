module ForumsHelper
  def forum_name(forum)
    forum.name.nil? || forum.name.blank? ? t('forum.forum_number', :number => forum.id) : forum.name
  end
end
