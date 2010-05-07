class PersonMailer < ActionMailer::Base
  extend PreferencesHelper
  
  def domain
    @domain ||= PersonMailer.global_prefs.domain
  end
  
  def server
    @server_name ||= PersonMailer.global_prefs.server_name
  end
  
  def password_reminder(person)
    from         "Password reminder <password-reminder@#{domain}>"
    recipients   person.email
    subject      formatted_subject("Password reminder")
    body         "person" => person
  end
  
  def message_notification(message)
    from         "Message notification <message@#{domain}>"
    recipients   message.recipient.email
    subject      formatted_subject("New message")
    body         "server" => server, "message" => message,
                 "preferences_note" => preferences_note(message.recipient)
  end
  
  def connection_request(connection)
    from         "Contact request <connection@#{domain}>"
    recipients   connection.person.email
    subject      formatted_subject("Contact request from #{connection.contact.name}")
    body         "server" => server,
                 "connection" => connection,
                 "url" => edit_connection_path(connection),
                 "preferences_note" => preferences_note(connection.person)
  end
  
  def membership_public_group(membership)
    from         "Membership done <membership@#{domain}>"
    recipients   membership.group.owner.email
    subject      formatted_subject("New member in group #{membership.group.name}")
    body         "server" => server,
                 "membership" => membership,
                 "url" => members_group_path(membership.group),
                 "preferences_note" => preferences_note(membership.group.owner)
  end
  
  def membership_request(membership)
    from         "Membership request <membership@#{domain}>"
    recipients   membership.group.owner.email
    subject      formatted_subject("Membership request for group #{membership.group.name}")
    body         "server" => server,
                 "membership" => membership,
                 "url" => members_group_path(membership.group),
                 "preferences_note" => preferences_note(membership.group.owner)
  end
  
  def membership_accepted(membership)
    from         "Membership accepted <membership@#{domain}>"
    recipients   membership.person.email
    subject      formatted_subject("You have been accepted to join #{membership.group.name}")
    body         "server" => server,
                 "membership" => membership,
                 "url" => group_path(membership.group),
                 "preferences_note" => preferences_note(membership.person)
  end
  
  def invitation_notification(membership)
    from         "Invitation notification <invitation#{domain}>"
    recipients   membership.person.email
    subject      formatted_subject("Invitation from group #{membership.group.name}")
    body         "server" => server,
                 "membership" => membership,
                 "url" => edit_membership_path(membership),
                 "preferences_note" => preferences_note(membership.person)
  end
  
  def invitation_accepted(membership)
    from         "Invitation accepted <invitation@#{domain}>"
    recipients   membership.group.owner.email
    subject      formatted_subject("#{membership.person.name} accepted the invitation")
    body         "server" => server,
                 "membership" => membership,
                 "url" => members_group_path(membership.group),
                 "preferences_note" => preferences_note(membership.group.owner)
  end

  def blog_comment_notification(comment)
    from         "Comment notification <comment@#{domain}>"
    recipients   comment.commented_person.email
    subject      formatted_subject("New blog comment")
    body         "server" => server, "comment" => comment,
                 "url" => 
                 blog_post_path(comment.commentable.blog, comment.commentable),
                 "preferences_note" => 
                    preferences_note(comment.commented_person)
  end
  
  def wall_comment_notification(comment)
    from         "Comment notification <comment@#{domain}>"
    recipients   comment.commented_person.email
    subject      formatted_subject("New wall comment")
    body         "server" => server, "comment" => comment,
                 "url" => person_path(comment.commentable, :anchor => "wall"),
                 "preferences_note" => 
                    preferences_note(comment.commented_person)
  end
  
  def email_verification(ev)
    from         "Email verification <email@#{domain}>"
    recipients   ev.person.email
    subject      formatted_subject("Email verification")
    body         "server_name" => server,
                 "code" => ev.code
  end
  
  private
  
    # Prepend the application name to subjects if present in preferences.
    def formatted_subject(text)
      name = PersonMailer.global_prefs.app_name
      label = name.blank? ? "" : "[#{name}] "
      "#{label}#{text}"
    end
  
    def preferences_note(person)
      %(To change your email notification preferences, visit http://#{server}/people/#{person.to_param}/edit#email_prefs)
    end
end
