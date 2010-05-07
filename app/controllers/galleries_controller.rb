class GalleriesController < ApplicationController
  before_filter :login_required
  before_filter :correct_user_required, :only => [ :edit, :update, :destroy ]
  
  def show
    @body = "galleries"
    @gallery = Gallery.find(params[:id])
    @photos = @gallery.photos.paginate :page => params[:page] 
  end
  
  def index
    @body = "galleries"
    @parent = params[:person_id].nil? ? Group.find(params[:group_id]) : Person.find(params[:person_id])
    @galleries = @parent.galleries.paginate :page => params[:page]
  end
  
  def new
    @gallery = Gallery.new
  end
  
  def create
    @gallery = parent.galleries.build(params[:gallery])
    respond_to do |format|
      if @gallery.save
        flash[:success] = t('flash.gallery_created')
        format.html { redirect_to gallery_path(@gallery) }
      else
        format.html { render :action => "new" }
      end
    end
  end
  
  def edit
    @gallery = Gallery.find(params[:id])
  end
  
  def update
    @gallery = Gallery.find(params[:id])
    respond_to do |format|
      if @gallery.update_attributes(params[:gallery])
        flash[:success] = t('flash.gallery_updated')
        format.html { redirect_to gallery_path(@gallery) }
      else
        format.html { render :action => "new" }
      end
    end
  end
  
  def destroy
    gallery = Gallery.find(params[:id])
    owner = gallery.owner
    owner_type = gallery.owner_type
    if owner.galleries.count == 1
      flash[:error] = t('flash.at_least_one_gallery')
    elsif gallery.destroy
      flash[:success] = t('flash.gallery_destroyed')
    else
      flash[:error] = t('flash.gallery_not_destroyed')
    end

    respond_to do |format|
      if owner_type == "Person"
        format.html { redirect_to person_galleries_path(current_person) }
      else
        format.html { redirect_to group_galleries_path(owner) }
      end
    end

  end
 
  private
  
    # Return the parent (person or group) of the gallery.
    def parent
      if person?
        Person.find(params[:parent_id])
      elsif group?
        Group.find(params[:parent_id])
      end
    end
    
    def person?
      params[:parent] == "person"
    end

    def group?
      params[:parent] == "group"
    end

    def correct_user_required
      @gallery = Gallery.find(params[:id])
      if @gallery.nil?
        flash[:error] = t('flash.gallery_not_found')
        redirect_to person_galleries_path(current_person)
      elsif @gallery.owner_type == "Person"
        if @gallery.owner != current_person 
          flash[:error] = t('flash.not_owner_of_gallery')
          redirect_to person_galleries_path(@gallery.owner)
        end
      elsif !current_person.own_groups.include?(@gallery.owner)
        flash[:error] = t('flash.not_owner_of_gallery')
        redirect_to person_galleries_path(@gallery.owner)
      end
    end

end
