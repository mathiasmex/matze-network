# == Schema Information
# Schema version: 20080812094342
#
# Table name: companies
#
#  id               :integer(4)      not null, primary key
#  parent_id        :integer(4)      default(""), not null
#  commentable_id   :integer(4)      
#  name             :string(255)     
#  description      :text            
#  web              :string(255)     
#  created_at       :datetime        
#  updated_at       :datetime        
#

class Company < ActiveRecord::Base
  acts_as_tree :order=>"name"
  has_many :company_persons, :dependent => :destroy
end
