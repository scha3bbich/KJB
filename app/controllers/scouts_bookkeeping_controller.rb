class ScoutsBookkeepingController < ApplicationController
  autocomplete :scout, :first_name, full: true,  :extra_data => [:last_name]
  
  def index
    @scouts = Scout.all
  end
  
  def index2
    date = Date.strptime(session[:date], "%d.%m.%Y")
    s_account_cash = Account.find_by_name('Gruppenleiterkasse')
    s_account_giro = Account.find_by_name('Gruppenleiterkasse Girokonto')        
    
    @bookings_cash = Booking.where(account: s_account_cash)
    @bookings_giro = Booking.where(account: s_account_giro)
    
    @s_account_cash_balance = Booking.where(account: s_account_cash).sum(:amount)
    @s_account_giro_balance = Booking.where(account: s_account_giro).sum(:amount) 
  end

  def consumption
    @dates = (Date.parse(Setting.find_by(key: :start_date).value)..Date.parse(Setting.find_by(key: :end_date).value)).to_a
    puts @dates
    @consumption = {}
    @dates.each do |date|
      @consumption[date] = ScoutConsumption.where(date: date).each.map { |sc| sc.total }.sum
    end
    @balance = {}
    @balance[ @dates.first ] = 0
    @dates.take(@dates.length-1).each_with_index.map {|e,i| [e, @dates[i+1]]}.each do |beforedate, date|  
      @balance[date] = @balance[beforedate] - @consumption[date]
    end    
  end

  def overview
    @random = Scout.offset(rand(Scout.count)).first
    @name = @random.last_name.chars.first + '.'
    if @random.account_balance < 0
      @negative = true
    else
      @negative = false
    end 
  end

  def billing
    @date = Date.strptime(session[:date], "%d.%m.%Y")
    @s_account_cash = Account.find_by_name('Gruppenleiterkasse')
    @s_account_giro = Account.find_by_name('Gruppenleiterkasse Girokonto')       
      
    @bookings_cash = Booking.where(account: @s_account_cash, date: @date).where("note1 != ?", "Ein-/Auszahlung").order('accounting_number DESC')
    @bookings_giro = Booking.where(account: @s_account_giro, date: @date).where("note1 != ?", "Ein-/Auszahlung").order('accounting_number DESC')
    
    @s_account_cash_balance = Booking.where(account: @s_account_cash).sum(:amount)
    @s_account_giro_balance = Booking.where(account: @s_account_giro).sum(:amount)    
    
    @s_account_cash_date_balance = Booking.where(["date = ?", @date]).where(account: @s_account_cash).where("note1 != ?", "Ein-/Auszahlung").sum(:amount)
    @s_account_giro_date_balance = Booking.where(["date = ?", @date]).where(account: @s_account_giro).where("note1 != ?", "Ein-/Auszahlung").sum(:amount)    

    @accounting_number = Booking.where(account_id: @s_account_cash).map {|b| b.accounting_number}.compact.max.to_i+1
        
    @scout_accounts = ScoutAccount.all
    
    @booking = Booking.new
  end
  
  def payment
    @scouts = Scout.all
    @date = Date.strptime(session[:date], "%d.%m.%Y")
    @s_account_cash = Account.find_by_name('Gruppenleiterkasse')
    @s_account_giro = Account.find_by_name('Gruppenleiterkasse Girokonto')
    @payments = Booking.where("note1 = ?", "Ein-/Auszahlung").where("note2 like ?", "%Gruppenleiter%")
    # ggf. unter payments noch jeweils den zweiten Buchungssatz hinzufuegen
  end
  
  def count_cash
    @s_account_cash = Account.find_by_name('Gruppenleiterkasse')      
    @s_account_cash_balance = Booking.where(account: @s_account_cash).sum(:amount)
    @count = session[:scouts_account_cash] || {}
  end
    
  def save_cash
    session[:scouts_account_cash] = params[:count]
    render text: "OK"
  end

  def reset_cash
    session[:scouts_account_cash] = {}
    
    respond_to do |format|
      format.html{redirect_to :back} 
    end 
  end

  def input
    date = Date.strptime(session[:date], "%d.%m.%Y")
    @scout_consumptions = ScoutConsumption.where(date: date).joins(:scout)
    @scouts = Scout.all - @scout_consumptions.map {|sc| sc.scout}
  end
  
  def new_entry
    date = Date.strptime(session[:date], "%d.%m.%Y")
    scout = Scout.find(params[:scout_id])
    ScoutConsumption.create(scout: scout, date: date, created_by: session[:user])
    redirect_to :scouts_bookkeeping_input
  end
  
  def update_entry
    puts params
    @entry = ScoutConsumption.find(params[:scout_consumption_id])
    @entry.update(scout_consumption_params)
    @entry.update(edited_by: session[:user])
    redirect_to :scouts_bookkeeping_input
  end
  
  def personal_transfer
    @transfers = Booking.where("note1 = ?", "Überweisung")
    @scouts = Scout.all
  end
  
  def export
    account_cash = Account.find_by_name('Gruppenleiterkasse')
    @csv = Booking.to_csv({account: account_cash}, {})
    send_data @csv, filename: "Gruppenleiterkasse_Export_#{Time.now.strftime("%Y-%m-%d_%H-%M-%S")}.csv"
  end
  
  def export_giro
    account_giro = Account.find_by_name('Gruppenleiterkasse Girokonto')
    @csv = Booking.to_csv({account: account_giro}, {})
    send_data @csv, filename: "Gruppenleiterkasse_Girokonto_Export_#{Time.now.strftime("%Y-%m-%d_%H-%M-%S")}.csv"
  end

  def daily_closing
    @date = Date.strptime(session[:date], "%d.%m.%Y")
    @s_account = Account.find_by_name('Gruppenleiterkasse')      
    @s_account_balance = Booking.where(account: @s_account).sum(:amount)
    
    @s_account_date_balance = Booking.where(["date = ?", @date]).where(account: @s_account).where("note1 != ?", "Ein-/Auszahlung").sum(:amount)   
    
    @s_account_date_first_booking = Booking.where(["date = ?", @date]).where(account: @s_account).where("note1 != ?", "Ein-/Auszahlung").first
    #setze Buchungsnummer auf die erste des Tages, falls leer
    if session[:s_acct_accounting_no].blank?
      if @s_account_date_first_booking.blank?
        session[:s_acct_accounting_no] = 1
      else 
        session[:s_acct_accounting_no] = @s_account_date_first_booking[:accounting_number]
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
    @s_account_current_balance = booking_sum(@s_account, session[:s_acct_accounting_no])
    
    @s_account_date_disbursements = Disbursement.where(["date = ?", @date]).where(account: @s_account).where(cleared: false).sum(:amount)
    @s_account_date_drawback = @s_account_date_disbursements + @s_account_date_balance
    @s_account_current_drawback = @s_account_date_disbursements + @s_account_current_balance
    
    @count = session[:scouts_account_cash] || {}
  end
  
  def update_accounting_no
    pp = params[:scouts_bookkeeping]
    session[:s_acct_accounting_no] = pp[:accounting_no]
    redirect_to scouts_bookkeeping_daily_closing_path
  end
  
  def clear_disbursement
    @date = Date.strptime(session[:date], "%d.%m.%Y")
    @s_account = Account.find_by_name('Gruppenleiterkasse')    
    @s_account_date_disbursements = Disbursement.where(["date = ?", @date]).where(account: @s_account)
    
    @s_account_date_last_booking = Booking.where(["date = ?", @date]).where(account: @s_account).where("note1 != ?", "Ein-/Auszahlung").last
    session[:s_acct_accounting_no] = @s_account_date_last_booking[:accounting_number].to_i + 1
    
    @s_account_date_disbursements.each do |e| 
      e.update('cleared' => true)
    end
  
   respond_to do |format|
      format.html{ redirect_to scouts_bookkeeping_daily_closing_path, notice: 'Ausgelegtes Geld als erledigt markiert.'} 
    end 
  end

  def scout_data
    @scout = Scout.find(params[:scout_id])
  end
  
  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def good_params
      params.permit(:scout_id, :scout_consumption_id)
    end
    
    def scout_consumption_params
      params.require(:scout_consumption).permit(:beer, :pork, :sausage, :soft_drink, :turkey, :corn, :other)
    end
end
