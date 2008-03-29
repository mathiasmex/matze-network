# == Schema Information
# Schema version: 13
#
# Table name: comments
#
#  id           :integer(11)     not null, primary key
#  person_id    :integer(11)     
#  commenter_id :integer(11)     
#  blog_post_id :integer(11)     
#  body         :text            
#  type         :string(255)     
#  created_at   :datetime        
#  updated_at   :datetime        
#

class BlogPostComment < Comment  
  belongs_to :commenter, :class_name => "Person",
                         :foreign_key => "commenter_id"
  belongs_to :post, :counter_cache => true, :foreign_key => "blog_post_id"
    
  validates_presence_of :commenter
  validates_length_of :body, :maximum => MAX_TEXT_LENGTH
  
  after_create :log_activity
  
  private
  
    def log_activity
      activity = Activity.create!(:item => self, :person => commenter)
      add_activities(:activity => activity, :person => post.blog.person)
      add_activities(:activity => activity, :person => commenter)
    end
end
