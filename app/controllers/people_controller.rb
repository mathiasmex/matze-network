class PeopleController < ApplicationController
  
  skip_before_filter :require_activation, :only => :verify_email
  skip_before_filter :admin_warning, :only => [ :show, :update ]
  before_filter :login_required, :only => [ :show, :edit, :update,
                                            :common_contacts ]
  before_filter :correct_user_required, :only => [ :edit, :update, :invitations ]
  before_filter :setup
  
  def index
    @people = Person.mostly_active(params[:page])

    respond_to do |format|
      format.html
    end
  end
  
  def show
    @person = Person.find(params[:id])
    @parent = @person
    unless @person.active? or current_person.admin?
      flash[:error] = t('flash.person_not_active')
      redirect_to home_url and return
    end
    if logged_in?
      @some_contacts = @person.some_contacts
      page = params[:page]
      @common_contacts = current_person.common_contacts_with(@person,
                                                             :page => page)
      # Use the same max number as in basic contacts list.
      num_contacts = Person::MAX_DEFAULT_CONTACTS
      @some_common_contacts = @common_contacts[0...num_contacts]
      @blog = @person.blog
      @posts = @person.blog.posts.paginate(:page => params[:page])
      @galleries = @person.galleries.paginate(:page => params[:page])
      @groups = current_person == @person ? @person.groups : @person.groups_not_hidden
      @some_groups = @groups[0...num_contacts]
      @own_groups = current_person == @person ? @person.own_groups : @person.own_not_hidden_groups
      @some_own_groups = @own_groups[0...num_contacts]
      @events = @person.geolocated? ?
        Event.monthly_events(Time.now).find(:all, :origin => [@person.lat,@person.lng], :within => params[:within] || 100) : []
    end
    respond_to do |format|
      format.html
    end
  end

  def new
    @body = "register single-col"
    @person = Person.new

    respond_to do |format|
      format.html
    end
  end

  def create
    cookies.delete :auth_token
    @person = Person.new(params[:person])
    respond_to do |format|
      @person.email_verified = false if global_prefs.email_verifications?
      @person.identity_url = session[:verified_identity_url]
      @person.save
      if @person.errors.empty?
        session[:verified_identity_url] = nil
        if global_prefs.email_verifications?
          @person.email_verifications.create
          flash[:notice] = t('flash.thanks_sign_up_verify_email')
          format.html { redirect_to(home_url) }
        else
          self.current_person = @person
          flash[:notice] = t('flash.thanks_sign_up')
          format.html { redirect_back_or_default(home_url) }
        end
      else
        @body = "register single-col"
        format.html { if @person.identity_url.blank? 
                        render :action => 'new'
                      else
                        render :partial => "shared/personal_details.html.erb", :object => @person, :layout => 'application'
                      end
                    }
      end
    end
  rescue ActiveRecord::StatementInvalid
    # Handle duplicate email addresses gracefully by redirecting.
    redirect_to home_url
  rescue ActionController::InvalidAuthenticityToken
    # Experience has shown that the vast majority of these are bots
    # trying to spam the system, so catch & log the exception.
    warning = "ActionController::InvalidAuthenticityToken: #{params.inspect}"
    logger.warn warning
    redirect_to home_url
  end

  def verify_email
    verification = EmailVerification.find_by_code(params[:id])
    if verification.nil?
      flash[:error] = t('flash.invalid_email_verification_code')
      redirect_to home_url
    else
      cookies.delete :auth_token
      person = verification.person
      person.email_verified = true; person.save!
      self.current_person = person
      flash[:success] = t('flash.verified_active')
      redirect_to person
    end
  end

  def edit
    @person = Person.find(params[:id])

    respond_to do |format|
      format.html
    end
  end

  def update
    @person = Person.find(params[:id])
    respond_to do |format|
      case params[:type]
      when 'info_edit'
        if !preview? and @person.update_attributes(params[:person])
          flash[:success] = t('flash.profile_updated')
          format.html { redirect_to(@person) }
        else
          if preview?
            @preview = @person.description = params[:person][:description]
          end
          format.html { render :action => "edit" }
        end
      when 'password_edit'
        if global_prefs.demo?
          flash[:error] = t('flash.no_password_change_in_demo')
          redirect_to @person and return
        end
        if @person.change_password?(params[:person])
          flash[:success] = t('flash.password_changed')
          format.html { redirect_to(@person) }
        else
          format.html { render :action => "edit" }
        end
      end
    end
  end
  
  def common_contacts
    @person = Person.find(params[:id])
    @common_contacts = @person.common_contacts_with(current_person,
                                                    :page => params[:page])
    respond_to do |format|
      format.html
    end
  end
  
  def add_company
    @person = Person.find(params[:id])
    company_id = params[:company][:id].empty? ? 0 : params[:company][:id]
    (Preference.find(:first).node_number-1).times do |num|
      company_id = params["company#{num}"][:id] unless params["company#{num}"].nil?
    end
    respond_to do |format|
      if company_id != 0 and !@person.company_ids.include?(company_id.to_i)
        if @person.companies.length < Preference.find(:first).number_of_companies
          @person.companies << Company.find(company_id) unless @person.company_ids.include?(company_id.to_i)
          flash[:success] = t('flash.company_added')
          format.html { redirect_to(edit_person_path(@person)+"?edit=company") }
        else
          flash[:error] = t('flash.no_more_companies')
          format.html { redirect_to(edit_person_path(@person)+"?edit=company") }
        end
      else
        format.html { redirect_to(edit_person_path(@person)+"?edit=company") }
      end
    end
  end
  
  def delete_company
    @person = Person.find(params[:id])
    @person.companies.delete(Company.find(params[:company_id]))
    respond_to do |format|
      flash[:success] = t('flash.company_deleted')
      format.html { redirect_to(edit_person_path(@person)+"?edit=company") }
    end
  end
    
  def groups
    @person = Person.find(params[:id])
    @groups = current_person == @person ? @person.groups : @person.groups_not_hidden
    @some_groups = @groups.paginate(:page => params[:page], :per_page => RASTER_PER_PAGE)
    
    respond_to do |format|
      format.html
    end
  end
  
  def admin_groups
    @person = Person.find(params[:id])
    @groups = current_person == @person ? @person.own_groups : @person.own_not_hidden_groups
    @some_groups = @groups.paginate(:page => params[:page], :per_page => RASTER_PER_PAGE)
    render :action => :groups
  end

  private

    def setup
      @body = "person"
    end
  
    def correct_user_required
      redirect_to home_url unless Person.find(params[:id]) == current_person
    end
    
    def preview?
      params["commit"] == t('global.preview')
    end

end
