class ChildrenBookkeepingController < ApplicationController
  
  def payment_in
    @date = Date.strptime(session[:date], "%d.%m.%Y")
    @children_account = Account.find_by_name('Kinderkasse')
    @payments = Booking.where("note1 = ?", "Ein-/Auszahlung").where("note2 like ?", "%Kinderkasse%").where(date: @date)
  end
  
    def payment_out
    @date = Date.strptime(session[:date], "%d.%m.%Y")
    @children_account = Account.find_by_name('Kinderkasse')
    @payments = Booking.where("note1 = ?", "Ein-/Auszahlung").where("note2 like ?", "%Kinderkasse%").where(date: @date)
  end
  
  
  def transfer
    @m_account = Account.find_by_name('Lagerkasse Bar')      
    @m_account_balance = Booking.where(account: @m_account).sum(:amount)
    
    @c_account = Account.find_by_name('Kinderkasse')
    @c_account_balance = Booking.where(account: @c_account).sum(:amount)
    
    @m_c_account_sum = @m_account_balance + @c_account_balance
  end
  
  def personal_transfer
    @transfers = Booking.where("note1 = ?", "Überweisung")
  end
  
  def child_data
    @child = Child.find(params[:child_id])
  end
  
end
