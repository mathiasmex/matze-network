module CompaniesHelper
  def companies(parent)
    Company.find(:all, 
      :conditions => [parent == 0 ? "parent_id = 0" : "parent_id > 0"], 
      :order => "name ASC")
  end
end
