class MainBookkeepingController < ApplicationController
  def index
    @date = Date.strptime(session[:date], "%d.%m.%Y")
    @m_account = Account.find_by_name('Lagerkasse Bar')    
    
    @bookings = Booking.where(account: @m_account)
    
    @m_account_balance = Booking.where(account: @m_account).sum(:amount)
  end

  def billing
    @m_account = Account.find_by_name('Lagerkasse Bar')
    @date = Date.strptime(session[:date], "%d.%m.%Y")
    @booking = Booking.new
    @bookings = Booking.where(date: @date, account: @m_account).where("note1 != ?", "Ein-/Auszahlung").order('accounting_number DESC')
    @scouts = Scout.all
    @scout_accounts = ScoutAccount.all
    
    @accounting_number = Booking.where(account_id: @m_account).map {|b| b.accounting_number}.compact.max.to_i+1
    @user = User.find_by_name(session[:user])
    
    @m_account_balance = Booking.where(account: @m_account).sum(:amount)
    @m_account_date_balance = Booking.where(["date = ?", @date]).where(account: @m_account).where("note1 != ?", "Ein-/Auszahlung").sum(:amount)   
  end
  
  def count_cash
    @m_account = Account.find_by_name('Lagerkasse Bar')      
    @m_account_balance = Booking.where(account: @m_account).sum(:amount)
    @count = session[:main_account_cash] || {}
  end
    
  def save_cash
    session[:main_account_cash] = params[:count]
    render text: "OK"
  end
  
  def reset_cash
    session[:main_account_cash] = {}
    
    respond_to do |format|
      format.html{redirect_to :back} 
    end 
  end
  
  def export
    account = Account.find_by_name('Lagerkasse Bar')
    @csv = Booking.to_csv({account: account}, {})
    send_data @csv, filename: "Lagerkasse_Export_#{Time.now.strftime("%Y-%m-%d_%H-%M-%S")}.csv"
  end
  
  def daily_closing
    @date = Date.strptime(session[:date], "%d.%m.%Y")
    @m_account = Account.find_by_name('Lagerkasse Bar')      
    @m_account_balance = Booking.where(account: @m_account).sum(:amount)
    
    @c_account = Account.find_by_name('Kinderkasse')
    @c_account_balance = Booking.where(account: @c_account).sum(:amount)
    
    @m_c_account_sum = @m_account_balance + @c_account_balance
    
    @m_account_date_balance = Booking.where(["date = ?", @date]).where(account: @m_account).where("note1 != ?", "Ein-/Auszahlung").sum(:amount) 
    @m_account_date_first_booking = Booking.where(["date = ?", @date]).where(account: @m_account).where("note1 != ?", "Ein-/Auszahlung").first
    #setze Buchungsnummer auf die erste des Tages, falls leer
    if session[:m_acct_accounting_no].blank?
      if @m_account_date_first_booking.blank?
        session[:m_acct_accounting_no] = 1
      else 
        session[:m_acct_accounting_no] = @m_account_date_first_booking[:accounting_number]
      end
    end
    def booking_sum(account, accounting_no)
      sum = 0.0
      bookings = Booking.where(account: account).each do |b|
        if b.accounting_number.to_i >= accounting_no.to_i
          sum += b.amount
        end
      end
      return sum
    end
    @m_account_current_balance = booking_sum(@m_account, session[:m_acct_accounting_no])
      
    @m_account_date_disbursement = Disbursement.where(["date = ?", @date]).where(account: @m_account).where(cleared: false).sum(:amount)
    @m_account_date_drawback = @m_account_date_disbursement + @m_account_date_balance
    @m_account_current_drawback = @m_account_date_disbursement + @m_account_current_balance
    
    @m_account_date_disbursements = Disbursement.where(["date = ?", @date]).where(account: @m_account)

   
    @count = session[:main_account_cash] || {}
  end
  
  def update_accounting_no
    pp = params[:main_bookkeeping]
    session[:m_acct_accounting_no] = pp[:accounting_no]
    redirect_to main_bookkeeping_daily_closing_path
  end
  
  def clear_disbursement
    @date = Date.strptime(session[:date], "%d.%m.%Y")
    @m_account = Account.find_by_name('Lagerkasse Bar')    
    @m_account_date_disbursements = Disbursement.where(["date = ?", @date]).where(account: @m_account)
    
    @m_account_date_last_booking = Booking.where(["date = ?", @date]).where(account: @m_account).where("note1 != ?", "Ein-/Auszahlung").last
    session[:m_acct_accounting_no] = @m_account_date_last_booking[:accounting_number].to_i + 1
    
    @m_account_date_disbursements.each do |e| 
      e.update('cleared' => true)
    end
    
    respond_to do |format|
      format.html{ redirect_to main_bookkeeping_daily_closing_path, notice: 'Ausgelegtes Geld als erledigt markiert.'} 
    end 
  end
  
end

