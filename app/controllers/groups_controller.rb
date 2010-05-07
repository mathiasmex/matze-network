class GroupsController < ApplicationController
  before_filter :login_required
  before_filter :group_owner, :only => [:edit, :update, :destroy, 
                              :new_photo, :save_photo, :delete_photo]
  
  def index
    @groups = Group.not_hidden(params[:page])

    respond_to do |format|
      format.html
    end
  end

  def show
    @group = Group.find(params[:id])
    @parent = @group
    num_contacts = Person::MAX_DEFAULT_CONTACTS
    @members = @group.people
    @some_members = @members[0...num_contacts]
    @blog = @group.blog
    @posts = @group.blog.posts.paginate(:page => params[:page])
    @galleries = @group.galleries.paginate(:page => params[:page])
    group_redirect_if_not_public 
  end

  def new
    @group = Group.new

    respond_to do |format|
      format.html
    end
  end

  def edit
    @group = Group.find(params[:id])
  end

  def create
    @group = Group.new(params[:group])
    @group.owner = current_person

    respond_to do |format|
      if @group.save
        flash[:success] = t('flash.group_created')
        format.html { redirect_to(group_path(@group)) }
      else
        format.html { render :action => "new" }
      end
    end
  end

  def update
    @group = Group.find(params[:id])

    respond_to do |format|
      if @group.update_attributes(params[:group])
        flash[:success] = t('flash.group_updated')
        format.html { redirect_to(group_path(@group)) }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  def destroy
    @group = Group.find(params[:id])
    @group.destroy

    respond_to do |format|
      flash[:success] = t('flash.group_destroyed')
      format.html { redirect_to(groups_path) }
    end
  end
  
  def invite
    @group = Group.find(params[:id])
    @contacts = contacts_to_invite

    respond_to do |format|
      if current_person.own_groups.include?(@group) and @group.hidden?
        if @contacts.length == 0
          flash[:error] = t('flash.group_no_contacts_or_invited_all')
          format.html { redirect_to(group_path(@group)) }
        end
        format.html
      else
        format.html { redirect_to(group_path(@group)) }
      end
    end
  end
  
  def invite_them
    @group = Group.find(params[:id])
    invitations = params[:checkbox].collect{|x| x if  x[1]=="1" }.compact
    invitations.each do |invitation|
      if Membership.find_all_by_group_id(@group, :conditions => ['person_id = ?',invitation[0].to_i]).empty?
        Membership.invite(Person.find(invitation[0].to_i),@group)
      end
    end
    respond_to do |format|
      flash[:notice] = t('flash.group_invited_some_contacts', :name => (@group.name))
      format.html { redirect_to(group_path(@group)) }
    end
  end
  
  def members
    @group = Group.find(params[:id])
    @members = @group.people.paginate(:page => params[:page],
                                      :per_page => RASTER_PER_PAGE)
    @pending = @group.pending_request
    group_redirect_if_not_public
  end
  
  def photos
    @group = Group.find(params[:id])
    @photos = @group.photos
    respond_to do |format|
      format.html
    end
  end
  
  def new_photo
    @photo = Photo.new

    respond_to do |format|
      format.html
    end
  end
  
  def save_photo
    group = Group.find(params[:id])
    if params[:photo].nil?
      # This is mainly to prevent exceptions on iPhones.
      flash[:error] = t('flash.browser_does_not_support_uploading')
      redirect_to(edit_group_path(group)) and return
    end
    if params[:commit] == "Cancel"
      flash[:notice] = t('flash.canceled_upload')
      redirect_to(edit_group_path(group)) and return
    end
    
    group_data = { :group => group,
                   :primary => group.photos.empty? }
    @photo = Photo.new(params[:photo].merge(group_data))
    
    respond_to do |format|
      if @photo.save
        flash[:success] = t('flash.photo_successfully_uploaded')
        if group.owner == current_person
          format.html { redirect_to(edit_group_path(group)) }
        else
          format.html { redirect_to(group_path(group)) }
        end
      else
        format.html { render :action => "new_photo" }
      end
    end
  end
  
  def delete_photo
    @group = Group.find(params[:id])
    @photo = Photo.find(params[:photo_id])
    @photo.destroy
    flash[:success] = t('flash.photo_deleted_for_group', :group => group.name)
    respond_to do |format|
      format.html { redirect_to(edit_group_path(@group)) }
    end
  end
  
  private
  
  def contacts_to_invite
    current_person.contacts - @group.people  - @group.pending_invitations
  end
  
  def group_owner
    redirect_to home_url unless current_person == Group.find(params[:id]).owner
  end
  
  def group_redirect_if_not_public
    respond_to do |format|
      #FIXME:it must be another way to do this if
      if @group.public? or @group.private? or current_person.admin? or 
          @group.owner?(current_person) or @group.has_invited?(current_person) or
          (@group.hidden? and @group.people.include?(current_person))
        format.html
      else
        format.html { redirect_to(groups_path) }
      end
    end
  end
  
end
