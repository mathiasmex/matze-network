class Admin::CompaniesController < ApplicationController
  
  before_filter :login_required, :admin_required

  def index
    @companies = Company.find(:all, :conditions => ["parent_id = 0"])

    respond_to do |format|
      format.html
    end
  end

  def show
    @company = Company.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @company }
    end
  end

  def new
    @company = Company.new

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  def edit
    @company = Company.find(params[:id])
  end
  
  def new_child
    @parent = Company.find(params[:id])
    @company = Company.new
    @company.parent = @parent
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  def create
    @company = Company.new(params[:company])

    respond_to do |format|
      if @company.save
        if @company.parent.nil?
          flash[:notice] = t('flash.company_created')
          format.html { redirect_to(admin_company_path(@company)) }
        else
          flash[:notice] = t('node_created')
          format.html { redirect_to(admin_company_path(@company.root)) }
        end
      else
        format.html { render :action => "new" }
      end
    end
  end

  def update
    @company = Company.find(params[:id])

    respond_to do |format|
      if @company.update_attributes(params[:company])
        flash[:notice] = t('flash.company_updated')
        format.html { redirect_to(admin_company_path(@company)) }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  def destroy
    @company = Company.find(params[:id])
    @company.destroy

    respond_to do |format|
      if @company.parent.nil?
        format.html { redirect_to(admin_companies_url) }
      else
        format.html { redirect_to(admin_company_url(@company.root)) }
      end
    end
  end
end
