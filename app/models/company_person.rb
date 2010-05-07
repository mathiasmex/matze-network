# == Schema Information
# Schema version: 20080819173849
#
# Table name: company_people
#
#  id               :integer(4)      not null, primary key
#  person_id        :integer(4)      
#  company_id       :integer(4)      
#  created_at       :datetime        
#  updated_at       :datetime        
#

class CompanyPerson < ActiveRecord::Base
  include ActivityLogger
  
  belongs_to :company
  belongs_to :person
  
  has_many :activities, :foreign_key => "item_id", :dependent => :destroy
  
  after_save :log_activity
  
  private
  
    def log_activity
      activity = Activity.create!(:item => self, :person => self.person)
      add_activities(:activity => activity, :person => person)
    end
end
