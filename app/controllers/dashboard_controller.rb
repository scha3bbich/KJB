class DashboardController < ApplicationController
  def index
    @disbursements = Disbursement.where(cleared: false)
    @disbursement = Disbursement.new
    @news = News.new
    @latest_news = News.last(5).reverse
  end
  
  def select_user
    if params[:user]
      session[:user] = params[:user]
    end
    redirect_to :back
  end
  
  def select_date
    if params[:date]
      session[:date] = params[:date]
    end
    redirect_to :back
  end
end
