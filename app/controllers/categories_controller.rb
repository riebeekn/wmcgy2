class CategoriesController < ApplicationController
  before_filter :signed_in_user
  
  def index
    @category = Category.new
    @categories = current_user.categories
  end
  
  def create
    @category = current_user.categories.build(params[:category])
    
    if @category.valid? && @category.save
      redirect_to categories_path
    else
      @categories = current_user.categories.reload
      render :index, notice: "cat taken"
    end
  end
end
