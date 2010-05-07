class SearchesController < ApplicationController
  include ApplicationHelper

  before_filter :login_required

  def index
    
    redirect_to(home_url) and return if params[:q].nil?
    
    query = params[:q].strip.inspect
    model = strip_admin(params[:model])
    page  = params[:page] || 1

    unless %(Person Message ForumPost Contacts Group).include?(model)
      flash[:error] = t('flash.invalid_search')
      redirect_to home_url and return
    end

    if query.blank?
      @search  = [].paginate
      @results = []
    else
      filters = {}
      if model == "Person" and current_person.admin?
        # Find all people, including deactivated and email unverified.
        model = "AllPerson"
      elsif model == "Message"
        filters['recipient_id'] = current_person.id
      elsif model == "Contacts"
        model = "Person"
        @person = params[:person_id].blank? ? current_person : Person.find(params[:person_id])
        filters['id'] = @person.contact_ids
      end
      @search = Ultrasphinx::Search.new(:query => query, 
                                        :filters => filters,
                                        :page => page,
                                        :class_names => model)
      @search.run
      @results = @search.results
      if model == "AllPerson"
        # Convert to people so that the routing works.
        @results.map!{ |person| Person.find(person) }
      end
      if model == "Group"
        @results.map!{ |group| group.hidden? ? nil:group}
        @results = @results.compact
      end
    end
  rescue Ultrasphinx::UsageError
    flash[:error] = t('flash.invalid_search_query')
    redirect_to searches_url(:q => "", :model => params[:model])
  end
  
  private
    
    # Strip off "Admin::" from the model name.
    # This is needed for, e.g., searches in the admin view
    def strip_admin(model)
      model.split("::").last
    end
end
