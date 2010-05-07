# == Schema Information
# Schema version: 20080916123706
#
# Table name: memberships
#
#  id               :integer(4)      not null, primary key
#  group_id         :integer(4)      
#  person_id        :integer(4)      
#  status           :integer(4)      
#  accepted_at      :datetime        
#  created_at       :datetime        
#  updated_at       :datetime        
#

class Membership < ActiveRecord::Base
  extend ActivityLogger
  extend PreferencesHelper
  
  belongs_to :group
  belongs_to :person
  has_many :activities, :foreign_key => "item_id", :dependent => :destroy
  validates_presence_of :person_id, :group_id
  
  # Status codes.
  ACCEPTED  = 0
  INVITED   = 1
  PENDING   = 2
  
  # Accept a membership request (instance method).
  def accept
    Membership.accept(person_id, group_id)
  end
  
  def breakup
    Membership.breakup(person_id, group_id)
  end
  
  class << self
    
    # Return true if the person is member of the group.
    def exists?(person, group)
      not mem(person, group).nil?
    end
    
    alias exist? exists?
    
    # Make a pending membership request.
    def request(person, group, send_mail = nil)
      if send_mail.nil?
        send_mail = global_prefs.email_notifications? &&
                    group.owner.connection_notifications?
      end
      if person.groups.include?(group) or Membership.exists?(person, group)
        nil
      else
        if group.public? or group.private?
          transaction do
            create(:person => person, :group => group, :status => PENDING)
            if send_mail
              membership = person.memberships.find(:first, :conditions => ['group_id = ?',group])
              PersonMailer.deliver_membership_request(membership)
            end
          end
          if group.public?
            membership = person.memberships.find(:first, :conditions => ['group_id = ?',group])
            membership.accept
            if send_mail
              PersonMailer.deliver_membership_public_group(membership)
            end
          end
        end
        true
      end
    end
    
    def invite(person, group, send_mail = nil)
      if send_mail.nil?
        send_mail = global_prefs.email_notifications? &&
                    group.owner.connection_notifications?
      end
      if person.groups.include?(group) or Membership.exists?(person, group)
        nil
      else
        transaction do
          create(:person => person, :group => group, :status => INVITED)
          if send_mail
            membership = person.memberships.find(:first, :conditions => ['group_id = ?',group])
            PersonMailer.deliver_invitation_notification(membership)
          end
        end
        true
      end
    end
    
    # Accept a membership request.
    def accept(person, group)
      transaction do
        accepted_at = Time.now
        accept_one_side(person, group, accepted_at)
      end
      unless Group.find(group).hidden?
        log_activity(mem(person, group))
      end
    end
    
    def breakup(person, group)
      transaction do
        destroy(mem(person, group))
      end
    end
    
    def mem(person, group)
      find_by_person_id_and_group_id(person, group)
    end
    
    def accepted?(person, group)
      exist?(person, group) and mem(person, group).status == ACCEPTED
    end
    
    def connected?(person, group)
      exist?(person, group) and accepted?(person, group)
    end
    
    def pending?(person, group)
      exist?(person, group) and mem(person,group).status == PENDING
    end
    
    def invited?(person, group)
      exist?(person, group) and mem(person,group).status == INVITED
    end
    
  end
  
  private
  
  class << self
    # Update the db with one side of an accepted connection request.
    def accept_one_side(person, group, accepted_at)
      mem = mem(person, group)
      mem.update_attributes!(:status => ACCEPTED,
                              :accepted_at => accepted_at)
    end
  
    def log_activity(membership)
      activity = Activity.create!(:item => membership, :owner => membership.person)
      add_activities(:activity => activity, :owner => membership.person)
      activity = Activity.create!(:item => membership, :owner => membership.group)
      add_activities(:activity => activity, :owner => membership.group)
    end
  end
  
end
