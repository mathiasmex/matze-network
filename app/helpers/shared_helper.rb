# Helpers added to this module are available in both controllers and views.
module SharedHelper

  def current_person?(person)
    logged_in? and person == current_person
  end
  
  # Return true if a person is connected to (or is) the current person
  def connected_to?(person)
    current_person?(person) or Connection.connected?(person, current_person)
  end

  # Return true if a person is the owner of a group or if member of it
  def is_member_of?(group)
    group.owner?(current_person) or Membership.accepted?(current_person, group)
  end
end
