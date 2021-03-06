class PermissionsController < ApplicationController
  #added the below lines E913
  include AccessHelper
  before_filter :auth_check

  def action_allowed?
    if current_user.role.name.eql?("Super-Administrator")
      true
    end
  end

  #our changes end E913

  def index
    list
    render :action => 'list'
  end

  def list
    @permissions = Permission.paginate(:page => params[:page],:per_page => 10)
  end

  def show
    @permission = Permission.find(params[:id])
    @pages = ContentPage.find_for_permission(params[:id])
    @actions = ControllerAction.find_for_permission(params[:id])
  end

  def new
    @permission = Permission.new
  end

  def create
    @permission = Permission.new(params[:permission])
    if @permission.save
      flash[:notice] = 'Permission was successfully created.'
      Role.rebuild_cache
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @permission = Permission.find(params[:id])
  end

  def update
    @permission = Permission.find(params[:id])
    if @permission.update_attributes(params[:permission])
      flash[:notice] = 'Permission was successfully updated.'
      Role.rebuild_cache
      redirect_to :action => 'show', :id => @permission
    else
      render :action => 'edit'
    end
  end

  def destroy
    Permission.find(params[:id]).destroy
    Role.rebuild_cache
    redirect_to :action => 'list'
  end
end
