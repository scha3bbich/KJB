class BookingsController < ApplicationController
  before_action :set_booking, only: [:show, :edit, :update, :destroy]

  # GET /bookings
  # GET /bookings.json
  def index
    @date = Date.strptime(session[:date], "%d.%m.%Y")
    @bookings = Booking.all.where(date: @date).order('date DESC')
  end

  # GET /bookings/1
  # GET /bookings/1.json
  def show
  end

  # GET /bookings/new
  def new
    @booking = Booking.new
  end

  # GET /bookings/1/edit
  def edit
  end

  # POST /bookings
  # POST /bookings.json
  def create  
    bparams = booking_params
    bparams[:created_by] = User.find_by_name(session[:user])
    bparams[:date] = Date.strptime(session[:date], "%d.%m.%Y")
    
    bparams[:accounting_number] = Booking.where(account_id: bparams[:account_id]).map {|b| b.accounting_number}.compact.max.to_i+1
      
    @booking = Booking.new(bparams)

    respond_to do |format|
      if @booking.save
        format.html { redirect_to :back, notice: 'Booking was successfully created.' }
        format.json { render :show, status: :created, location: @booking }
      else
        format.html { render :new }
        format.json { render json: @booking.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def update
    respond_to do |format|
      if @booking.update(booking_params.merge({updated_by: @user}))
        format.html { redirect_to @booking, notice: 'Booking was successfully updated.' }
        format.json { render :show, status: :ok, location: @booking }
      else
        format.html { render :edit }
        format.json { render json: @booking.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def create_billing  
    pparams = params[:booking]
    bparams = {}
    params[:booking][:created_by] = User.find_by_name(session[:user])
    params[:booking][:date] = Date.strptime(session[:date], "%d.%m.%Y")
    params[:booking][:accounting_number] = Booking.where(account_id: params[:booking][:account_id]).map {|b| b.accounting_number}.compact.max.to_i+1
       
    # Sub-Booking Parameter
    if (params[:booking][:sub_bookings_attributes])
      pparams[:sub_bookings_attributes].each do |key, value|
        if value[:sign] == "minus"
          value[:amount] = - value[:amount].to_f
        end
        value.delete :sign
        
        # wenn Lagerkasse, dann Gutschrift GL-Kasse
        # @account = Account.find(params[:booking][:account_id])
        @scout_account = Account.find_by_name('Gruppenleiterkasse')
        @main_account = Account.find_by_name('Lagerkasse Bar')
        @main_account_id = @main_account.id
        @scout_account_id = @scout_account.id
        @account_id = params[:booking][:account_id]
        puts "test"
        puts @main_account_id
        puts @account_id
        if (@account_id.to_s == @main_account_id.to_s)
          gparams = {}
          gparams[:amount] = value[:amount]
          gparams[:date] = params[:booking][:date]
          gparams[:created_by] = params[:booking][:created_by]
          gparams[:account_id] = @scout_account_id
          gparams[:accounting_number] = Booking.where(account_id: @scout_account_id).map {|b| b.accounting_number}.compact.max.to_i+1
          gparams[:note1] = "Gutschrift Lagerkasse GL, Quittungsnr:"
          gparams[:note2] = params[:booking][:accounting_number]
  
          @credit = Booking.new(gparams)
        end
      end
    end
    
    # plus/minus Button Main-Booking
    if params[:booking][:sign] == 'minus'
      params[:booking][:amount] = - params[:booking][:amount].to_f
    end
    params[:booking].delete :sign
    @booking = Booking.new(params[:booking].permit!)

    # Meldung
    if (@credit)
      if @booking.valid? and @credit.valid?
        @booking.save
        @credit.save
        redirect_to :back, notice: "Buchung wurde von Lagerkasse in GL-Kasse gebucht."
      else
        redirect_to :back, notice: "Could not save the payment due to an error."
      end
    else
      if @booking.valid?
       @booking.save
       redirect_to :back, notice: "Booking was successfully created."
      else
       redirect_to :back, notice: "Could not save the payment due to an error."        
      end
    end
  end
  
  # post /bookings/create_payment
  def create_payment
    pp = params[:booking]
    bparams = {}
    bparams[:created_by] = User.find_by_name(session[:user])
    bparams[:date] = Date.strptime(session[:date], "%d.%m.%Y")
    if pp[:payment_type] == 'in'
      bparams[:amount] = pp[:amount].to_f
    elsif pp[:payment_type] == 'out'
      bparams[:amount]= - pp[:amount].to_f
    end
    bparams[:remarks] = pp[:remarks]
    if pp.include? :scout_id
      # this is a scout payment
      scout = Scout.find(pp[:scout_id])
      
      main_account = Account.find(pp[:account_id])
      accounting_number = Booking.where(account_id: pp[:account_id]).map {|b| b.accounting_number}.compact.max.to_i+1
      @account_booking = Booking.new(bparams.merge(account: main_account, accounting_number: accounting_number, note1: "Ein-/Auszahlung", note2: scout.full_name))
      
      account_id = scout.account.account.id
      @scout_booking = Booking.new(bparams.merge(account_id: account_id, accounting_number: accounting_number, note1: "Ein-/Auszahlung", note2: main_account.name))
      
      if @account_booking.valid? and @scout_booking.valid?
        @account_booking.save
        @scout_booking.save
        redirect_to :back, notice: "Payment was successfully created." + "#{@account_id}"
      else
        redirect_to :back, error: "Could not save the payment due to an error."
      end
    elsif pp.include? :child_id
      # this is a child payment
      child = Child.find(pp[:child_id])
      
      main_account = Account.find(pp[:account_id])
      accounting_number = Booking.where(account_id: pp[:account_id]).map {|b| b.accounting_number}.compact.max.to_i+1
      @account_booking = Booking.new(bparams.merge(account: main_account, accounting_number: accounting_number, note1: "Ein-/Auszahlung", note2: child.full_name))
      
      account_id = child.account.account.id
      @scout_booking = Booking.new(bparams.merge(account_id: account_id, accounting_number: accounting_number, note1: "Ein-/Auszahlung", note2: main_account.name))
    
      if @account_booking.valid? and @scout_booking.valid?
        @account_booking.save
        @scout_booking.save
        redirect_to :back, notice: "Payment was successfully created."
      else
        redirect_to :back, error: "Could not save the payment due to an error."
      end
    end
  end

  def create_transfer
    # bisher nur fuer Kinderkasse zu Lagerkasse
    pp = params[:booking]
    bparams = {}
    bparams[:created_by] = User.find_by_name(session[:user])
    bparams[:date] = Date.strptime(session[:date], "%d.%m.%Y")
    bparams[:remarks] = pp[:remarks]
    bparams[:amount] = pp[:amount].to_f
    amount_child_account = - pp[:amount].to_f
    
    child_account = Account.find_by_name('Kinderkasse')
    main_account = Account.find_by_name('Lagerkasse Bar')
    accounting_number = Booking.where(account_id: main_account).map {|b| b.accounting_number}.compact.max.to_i+1
    @account_booking = Booking.new(bparams.merge(account: main_account, accounting_number: accounting_number, note1: "Ueberweisung", note2: 'Kinderkasse'))
    
    @child_account_booking = Booking.new(bparams.merge(account: child_account, accounting_number: accounting_number, note1: "Ueberweisung", note2: 'Lagerkasse', amount: amount_child_account))
  
    if @account_booking.valid? and @child_account_booking.valid?
      @account_booking.save
      @child_account_booking.save
      redirect_to :back, notice: "Payment was successfully created."
    else
      redirect_to :back, error: "Could not save the payment due to an error."
    end
    
  end

  def create_personal_transfer
    pp = params[:booking]
    bparams = {}
    bparams[:created_by] = User.find_by_name(session[:user])
    bparams[:date] = Date.strptime(session[:date], "%d.%m.%Y")
    bparams[:remarks] = pp[:remarks]
    bparams[:amount] = - pp[:amount].to_f
    amount2 = pp[:amount].to_f
    accounting_number = 0
    
    if pp.include? :child1_id
      # Überweisung zwischen Kindern
      child1 = Child.find(pp[:child1_id])
      child2 = Child.find(pp[:child2_id])
      account1_id = child1.account.account.id
      account2_id = child2.account.account.id
      note_1 = child2.full_name.to_s
      note_2 = child1.full_name.to_s  
    elsif pp.include? :scout1_id
      # Überweisung zwischen Gruppenleitern
      scout1 = Scout.find(pp[:scout1_id])
      scout2 = Scout.find(pp[:scout2_id])
      account1_id = scout1.account.account.id
      account2_id = scout2.account.account.id
      note_1 = scout2.full_name.to_s
      note_2 = scout1.full_name.to_s      
    end
        
    @booking1 = Booking.new(bparams.merge(account_id: account1_id, accounting_number: accounting_number, note1: "Überweisung", note2: note_1))
    @booking2 = Booking.new(bparams.merge(account_id: account2_id, accounting_number: accounting_number, note1: "Überweisung", note2: note_2, amount: amount2))
  
    if @booking1.valid? and @booking2.valid?
      @booking1.save
      @booking2.save
      redirect_to :back, notice: "Transfer was successfully created."
    else
      redirect_to :back, error: "Could not save the transfer due to an error."
    end  
  end

  # DELETE /bookings/1
  # DELETE /bookings/1.json
  def destroy
    @booking.destroy
    respond_to do |format|
      format.html { redirect_to bookings_url, notice: 'Booking was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_booking
      @booking = Booking.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def booking_params
      params.require(:booking).permit(:date, :account_id, :amount, :note1, :note2, :remarks, :created_by_id, :updated_by_id, :accounting_number, :sign, sub_bookings_attributes: [:id, :account_id, :amount, :note1, :note2, :sign, :date, :created_by, :accounting_number])
    end
end
