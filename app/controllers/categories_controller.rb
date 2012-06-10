class CategoriesController < ApplicationController
  respond_to :html, :json
  
  def index
    @category = Category.new
    @categories = current_user.categories
  end
  
  def create
    @category = current_user.categories.build(params[:category])
    
    if @category.valid? && @category.save
      redirect_to categories_path
    else
      @categories = current_user.categories
      render :index
    end
  end
  
  def update
    @category = current_user.categories.find(params[:id])
    @category.update_attributes(params[:category]) 
    respond_with @category
  end
  
  def destroy
    current_user.categories.find(params[:id]).destroy
    redirect_to categories_path, notice: "Category removed"
  end
end
