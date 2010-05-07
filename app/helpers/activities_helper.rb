module ActivitiesHelper

  # Given an activity, return a message for the feed for the activity's class.
  def feed_message(activity, recent = false)
    owner = activity.owner
    case activity_type(activity)
    when "BlogPost"
      post = activity.item
      blog = post.blog
      view_blog = blog_link(t('post.owners_blog', :owner => h(owner.name)), blog)
      if recent
        t 'post.new_blog_post_link', :blog_post => post_link(blog, post)
      else
        t 'post.owner_posted_blog_post', :owner => person_link_with_image(owner),
                                         :blog_post => post_link(blog, post),
                                         :blog => view_blog
      end
    when "Comment"
      parent = activity.item.commentable
      parent_type = parent.class.to_s
      case parent_type
      when "BlogPost"
        post = activity.item.commentable
        blog = post.blog
        if recent
          t 'comment.to_owners_blog_post',
                     :owner => someones(blog.owner, owner),
                     :blog_post => post_link(blog, post)
        else
          t 'comment.author_to_owners_blog_post',
                     :author => person_link_with_image(owner),
                     :owner => someones(blog.owner, owner),
                     :owner_blog_post => t('owner.blog_post'),
                     :blog_post => post_link(blog, post)
        end
      when "Person"
        if recent
          t 'comment.commented_on_activity',
                     :activity => wall(activity)
        else
          t 'comment.person_commented_on_activity', 
                     :person => person_link_with_image(activity.item.commenter), 
                     :activity => wall(activity)
        end
      when "Group"
        if recent
          t 'comment.commented_on_group_activity',
                     :activity => wall(activity)
        else
          t 'comment.person_commented_on_group_activity', 
                     :person => person_link_with_image(activity.item.commenter), 
                     :activity => wall(activity)
        end
      when "Event"
        event = activity.item.commentable
        if recent
          t 'comment.commented_on_organizer_event',
                     :organizer => someones(event.person, activity.item.commenter),
                     :event => event_link(event.title, event)
        else
          t 'comment.person_commented_on_organizer_event',
                     :person => person_link_with_image(activity.item.commenter), 
                     :organizer => someones(event.person, activity.item.commenter),
                     :event => event_link(event.title, event)
        end
      end
    when "Event"
      # TODO: make recent/long versions for this
      event = activity.item.commentable
      commenter = activity.item.commenter
      t 'comment.person_commented_on_organizer_event', 
                 :person => person_link_with_image(commenter), 
                 :organizer => someones(event.person, commenter), 
                 :event => event_link(event.title, event)
    when "Connection"
      if activity.item.contact.admin?
        if recent
          t 'activity.just_joined'
        else
          t 'activity.person_joined',
                      :person => person_link_with_image(activity.item.person)
        end
      else
        if recent
          t 'person.connected_with',
                    :person => person_link_with_image(activity.item.contact)
        else
          t 'person.persons_have_connected', 
                    :person1 => person_link_with_image(activity.item.person),
                    :person2 => person_link_with_image(activity.item.contact)
        end
      end
    when "ForumPost"
      post = activity.item
      if recent
        t 'forum.new_forum_post',
                 :topic => topic_link(post.topic)
      else
        t 'forum.person_posted', 
                 :person => person_link_with_image(owner),
                 :topic => topic_link(post.topic)
      end
    when "Topic"
      if recent
        t 'topic.new_discussion',
                 :topic => topic_link(activity.item)
      else
        t 'topic.person_posted', 
                 :person => person_link_with_image(owner),
                 :topic => topic_link(activity.item)
      end
    when "Person"
      if recent
        t 'person.description_changed'
      else
        t 'person.persons_description_changed',
                  :person => person_link_with_image(owner)
      end
    when "Gallery"
      if recent
        t 'gallery.new_gallery_added',
                   :gallery => gallery_link(activity.item)
      else
        t 'gallery.owner_added_new_gallery',
                   :owner => person_link_with_image(owner),
                   :gallery => gallery_link(activity.item)
      end
    when "Photo"
      if recent
        t 'photo.new_photo_added',
                 :photo => photo_link(activity.item),
                 :gallery => to_gallery_link(activity.item.gallery)
      else
        t 'photo.owner_added_new_photo',
                 :owner => person_link_with_image(owner),
                 :photo_str => t('photo.photo'),
                 :photo => photo_link(activity.item),
                 :gallery => to_gallery_link(activity.item.gallery)
      end
    when "Event"
      event = activity.item
      if recent
        t 'event.created_event',
                 :event => event_link(event.title, event)
      else
        t 'event.owner_created_event',
                 :owner => person_link_with_image(owner),
                 :event => event_link(event.title, event)
      end
    when "EventAttendee"
      event = activity.item.event
      if recent
        t 'event.attending_organizer_event',
                 :organizer => someones(event.person, owner),
                 :event => event_link(event.title, event)
      else
        t 'event.person_attending_organizer_event',
                 :person => person_link_with_image(owner),
                 :organizer => someones(event.person, owner),
                 :event => event_link(event.title, event)
      end
    when "CompanyPerson"
      t 'company.person_joined_company',
                 :person => person_link(person),
                 :company => company_tree(activity.item.company)
    when "Group"
      if owner.class.to_s == "Group"
        t 'group.description_changed'
      else
        t 'group.person_created_group',
                :person => person_link_with_image(owner),
                :group_link => group_link(Group.find(activity.item))
      end
    when "Membership"
      if owner.class.to_s == "Group"
        t 'group.person_joined',
                 :person => person_link(Person.find(activity.item.person))
      else
        t 'group.person_joined_group',
                 :person => person_link_with_image(owner),
                 :group_link => group_link(Group.find(activity.item.group))
      end
    else
      raise t('activity.invalid_activity_type', :activity => activity_type(activity).inspect)
    end
  end
  
  def minifeed_message(activity)
    owner = activity.owner
    case activity_type(activity)
    when "BlogPost"
      post = activity.item
      blog = post.blog
      t 'post.person_new_blog_post',
              :person => person_link(owner),
              :new_blog_post => post_link(t('post.new_blog_post'), blog, post)
    when "Comment"
      parent = activity.item.commentable
      parent_type = parent.class.to_s
      case parent_type
      when "BlogPost"
        post = activity.item.commentable
        blog = post.blog
        t 'comment.author_to_persons_blog_post',
                   :author => person_link(owner),
                   :person => someones(blog.owner, owner),
                   :person_blog_post => t('person.blog_post'),
                   :blog_post => post_link(t('person.blog_post'), post.blog, post)
      when "Person"
        t 'comment.person_commented_on_activity',
                   :person => person_link(activity.item.commenter),
                   :activity => wall(activity)
      when "Event"
        event = activity.item.commentable
        t 'comment.person_commented_on_organizer_event',
                   :person => person_link(activity.item.commenter), 
                   :organizer => someones(event.person, activity.item.commenter),
                   :event => event_link(event.title, event)
      when "Group"
        t 'comment.person_commented_on_activity',
                   :person => person_link_with_image(activity.item.commenter),
                   :activity => wall(activity)
      end
    when "Connection"
      if activity.item.contact.admin?
        t 'activity.person_joined',
                    :person => person_link(owner)
      else
        t 'connection.persons_have_connected',
                      :person1 => person_link(owner),
                      :person2 => person_link(activity.item.contact)
      end
    when "ForumPost"
      topic = activity.item.topic
      t 'forum.person_posted',
               :person => person_link(owner),
               :topic => topic_link(topic)
    when "Topic"
      t 'topic.person_posted',
               :person => person_link(owner),
               :topic => topic_link(activity.item)
    when "Person"
      t 'person.persons_description_changed',
                :person => person_link(owner)
    when "Gallery"
      t 'gallery.person_added_new_gallery',
                 :person => person_link(owner),
                 :gallery => gallery_link(activity.item)
    when "Photo"
      t 'photo.person_added_new_photo',
               :person => person_link(owner),
               :photo => photo_link(activity.item),
               :photo_str => t('photo.photo'),
               :gallery => to_gallery_link(activity.item.gallery)
    when "Event"
      t 'event.person_created_event',
               :person => person_link(owner),
               :event => event_link(activity.item)
    when "EventAttendee"
      event = activity.item.event
      t 'event.person_attending_organizer_event',
               :person => person_link(owner),
               :organizer => someones(event.person, owner),
               :event => event_link(event.title, event)
    when "CompanyPerson"
      t 'company.person_joined_company',
                 :person => person_link(owner),
                 :company => company_tree(activity.item.company)
    when "Group"
      if owner.class.to_s == "Group"
        t 'group_description_changed'
      else
        t 'group.person_created_group',
                :person => person_link(owner),
                :group_link => group_link(Group.find(activity.item))
      end
    when "Membership"
      t 'group.person_joined_group',
               :person => person_link(owner),
               :group => group_link(Group.find(activity.item.group))
    else
      raise t('activity.invalid_activity_type', :activity => activity_type(activity).inspect)
    end
  end
  
  # Given an activity, return the right icon.
  def feed_icon(activity)
    img = case activity_type(activity)
            when "BlogPost"
              "page_white.png"
            when "Comment"
              parent_type = activity.item.commentable.class.to_s
              case parent_type
              when "BlogPost"
                "comment.png"
              when "Event"
                "comment.png"
              when "Person"
                "sound.png"
              when "Group"
                "sound.png"
              end
            when "Connection"
              if activity.item.contact.admin?
                "vcard.png"
              else
                "connect.png"
              end
            when "ForumPost"
              "asterisk_yellow.png"
            when "Topic"
              "note.png"
            when "Person"
                "user_edit.png"
            when "Gallery"
              "photos.png"
            when "Photo"
              "photo.png"
            when "Event"
              # TODO: replace with a png icon
              "time.gif"
            when "EventAttendee"
              # TODO: replace with a png icon
              "check.gif"
            when "CompanyPerson"
                "bargraph.gif"
            when "Group"
              if activity.owner.class.to_s == "Group"
                # TODO: replace with a group_edit png icon
                "user_edit.png"
              else
                # TODO: replace with a group png icon
                "asterisk_yellow.png"
              end
            when "Membership"
              # TODO: replace with a png icon
              "add.gif"
            else
              raise t('activity.invalid_activity_type', :activity => activity_type(activity).inspect)
            end
    image_tag("icons/#{img}", :class => "icon")
  end
  
  def someones(person, commenter, link = true)
    link ? t('person.persons', :person =>person_link_with_image(person)) : t('person.persons', :person => h(person.name))
  end
  
  def blog_link(text, blog)
    link_to(text, blog_path(blog))
  end
  
  def post_link(text, blog, post = nil)
    if post.nil?
      post = blog
      blog = text
      text = post.title
    end
    link_to(text, blog_post_path(blog, post))
  end
  
  def topic_link(text, topic = nil)
    if topic.nil?
      topic = text
      text = topic.name
    end
    link_to(text, forum_topic_path(topic.forum, topic))
  end
  
  def gallery_link(text, gallery = nil)
    if gallery.nil?
      gallery = text
      text = gallery.title
    end
    link_to(h(text), gallery_path(gallery))
  end
  
  def to_gallery_link(text = nil, gallery = nil)
    if text.nil?
      ''
    else
      t 'gallery.to_gallery', :gallery => gallery_link(text, gallery)
    end
  end
  
  def photo_link(text, photo= nil)
    if photo.nil?
      photo = text
      text = t('photo.photo')
    end
    link_to(h(text), photo_path(photo))
  end

  def event_link(text, event)
    link_to(text, event_path(event))
  end

  # Return a link to the wall.
  def wall(activity)
    commenter = activity.owner
    if activity.item.commentable.class.to_s == "Person"
      person = activity.item.commentable
      link_to(t('person.person_wall', :person => someones(person, commenter, false)), 
        person_path(person, :anchor => "tWall"))
    else
      group = activity.item.commentable
      link_to(t('group.group_wall', :group => someones(group, commenter, false)),
        group_path(group, :anchor => "tWall"))
    end
  end
  
  # Only show member photo for certain types of activity
  def posterPhoto(activity)
    shouldShow = case activity_type(activity)
    when "Photo"
      true
    when "Connection"
      true
    else
      false
    end
    if shouldShow
      image_link(activity.owner, :image => :thumbnail)
    end
  end
  
  private
  
    # Return the type of activity.
    # We switch on the class.to_s because the class itself is quite long
    # (due to ActiveRecord).
    def activity_type(activity)
      activity.item.class.to_s      
    end
end
