class ImportController < ApplicationController
  
  def index
  end
  
  def upload
    if params[:upload][:data] == 'children_tool_christian'
      @file = params[:upload][:file]
      if @file.content_type == "text/xml"
        import_children_tool_from_xml
      elsif @file.content_type == "text/csv"
        import_children_tool_from_csv
      else
        flash[:alert] = "Could not import the given file: unknown format"
      end
    elsif params[:upload][:data] == 'scouts_tool_christian'
      @file = params[:upload][:file]
      if @file.content_type == "text/xml"
        import_scouts_tool_from_xml
      elsif @file.content_type == "text/csv"
        import_scouts_tool_from_csv
      else
        flash[:alert] = "Could not import the given file: unknown format"
      end      
    elsif params[:upload][:data] == 'tents_tool_christian'
      @file = params[:upload][:file]
      if @file.content_type == "text/xml"
        import_tents_tool_from_xml
      elsif @file.content_type == "text/csv"
        import_tents_tool_from_csv
      else
        flash[:alert] = "Could not import the given file: unknown format"
      end
    elsif params[:upload][:data] == 'tent_members_tool_christian'
      @file = params[:upload][:file]
      if @file.content_type == "text/xml"
        import_tent_members_tool_from_xml
      elsif @file.content_type == "text/csv"
        import_tent_members_tool_from_csv
      else
        flash[:alert] = "Could not import the given file: unknown format"
      end
    elsif params[:upload][:data] == 'scouts_csv'
      @file = params[:upload][:file]
      if @file.content_type == "text/csv"
        import_scouts_from_csv
      else
        flash[:alert] = "Could not import the given file: unknown format"
      end
    elsif params[:upload][:data] == 'children_csv'
      @file = params[:upload][:file]
      if @file.content_type == "text/csv"
        import_children_from_csv
      else
        flash[:alert] = "Could not import the given file: unknown format"
      end    
    elsif params[:upload][:data] == 'scouts'
      @file = params[:upload][:file]
      case File.extname(@file.original_filename)
        when ".csv" then import_scouts
        when ".xls" then import_scouts
        when ".xlsx" then import_scouts
      else
        flash[:alert] = "Could not import the given file: unknown format"
      end
    elsif params[:upload][:data] == 'children'
      @file = params[:upload][:file]
      case File.extname(@file.original_filename)
        when ".csv" then import_children
        when ".xls" then import_children
        when ".xlsx" then import_children
      else
        flash[:alert] = "Could not import the given file: unknown format"
      end  
    end
    render :index
  end
  
# Import Scouts  
  def import_scouts_tool_from_csv
    @filecontent = @file.read
    @filecontent.force_encoding('UTF-8')
    @csv = CSV.new(@filecontent, headers: true, col_sep: ",")
    @content = @csv.to_a.map {|row| row.to_hash }
    @content.each do |row|
      if(row["Aktiv"] == "1")
        data = {
          first_name: row["Vorname"],
          last_name: row["Nachname"],
          birthday: Date.strptime(row["Geburtsdatum"].split(' ')[0], '%m/%d/%Y')
        }
        scout = Scout.create(data)
        #create attendances for scouts
        d = Date.parse(Setting.find_by(key: :start_date).value)
        for d in (Date.parse(Setting.find_by(key: :start_date).value)..Date.parse(Setting.find_by(key: :end_date).value)) do
          pparams = {}
          pparams[:scout] = scout
          pparams[:date] = d
          pparams[:attending] = true
          Attendance.create(pparams)
        end
      end
    end
    flash[:notice] = "Import successful"
  end
  
  def import_scouts_tool_from_xml
    @filecontent = @file.read
    @data = Hash.from_xml @filecontent
    @data["RECORDS"]["RECORD"].each do |row|
      if(row["Aktiv"] == "1")      
        data = {
            first_name: row["Vorname"],
            last_name: row["Nachname"],
            birthday: Date.strptime(row["Geburtsdatum"].split(' ')[0], '%m/%d/%Y')
          }
        scout = Scout.create(data)
        #create attendances for scouts
        d = Date.parse(Setting.find_by(key: :start_date).value)
        for d in (Date.parse(Setting.find_by(key: :start_date).value)..Date.parse(Setting.find_by(key: :end_date).value)) do
          pparams = {}
          pparams[:scout] = scout
          pparams[:date] = d
          pparams[:attending] = true
          Attendance.create(pparams)
        end
      end
    end
    flash[:notice] = "Import successful"
  end  

# Import children  
  def import_children_tool_from_xml
    @filecontent = @file.read
    @data = Hash.from_xml @filecontent
    @data["RECORDS"]["RECORD"].each do |row|
      data = {
        first_name: row["Vorname"],
        last_name: row["Nachname"],
        birthday: Date.strptime(row["Geburtsdatum"].split(' ')[0], '%m/%d/%Y'),
        phone: "Telefon: "+row["Telefon"].to_s+"\nElternTelefon: "+row["ElternTelefon"].to_s+"\nElternTelefonDienstlich: "+
          row["ElternTelefonDienstlich"].to_s + "\nElternErreichbarUrlaub: "+row["ElternErreichbarUrlaub"].to_s,
        source_id: row["id"].to_i,
        image: row["TeilnehmerImage"]
      }
      child = Child.create(data)
    end
    flash[:notice] = "Import successful"
  end
  
  def import_children_tool_from_csv
    @filecontent = @file.read
    @filecontent.force_encoding('UTF-8')
    @csv = CSV.new(@filecontent, headers: true, col_sep: ",", encoding: "UTF-8")
    @content = @csv.to_a.map {|row| row.to_hash }
    @content.each do |row|
      data = {
        first_name: row["Vorname"],
        last_name: row["Nachname"],
        birthday: Date.strptime(row["Geburtsdatum"].split(' ')[0], '%m/%d/%Y'),
        phone: "Telefon: "+row["Telefon"].to_s+"\nElternTelefon: "+row["ElternTelefon"].to_s+"\nElternTelefonDienstlich: "+
          row["ElternTelefonDienstlich"].to_s + "\nElternErreichbarUrlaub: "+row["ElternErreichbarUrlaub"].to_s,
        source_id: row["id"].to_i,
        image: row["TeilnehmerImage"]
      }
      child = Child.create(data)
    end
    flash[:notice] = "Import successful"
  end

# Import Tents  
  def import_tents_tool_from_csv
    @filecontent = @file.read
    @filecontent.force_encoding('UTF-8')
    @csv = CSV.new(@filecontent, headers: true, col_sep: ",", encoding: "UTF-8")
    @content = @csv.to_a.map {|row| row.to_hash }
    @content.each do |row|
      data = {
        number: row["Bezeichnung"].split(" ").last.to_i,
        source_id: row["id"].to_i
      }
      tent = Tent.create(data)
    end
    flash[:notice] = "Import successful"
  end

  def import_tents_tool_from_xml
    @filecontent = @file.read
    @data = Hash.from_xml @filecontent
    @data["RECORDS"]["RECORD"].each do |row|
      data = {
        number: row["Bezeichnung"].split(' ').last.to_i,
        source_id: row["id"].to_i        
      }
      tent = Tent.create(data)
    end
    flash[:notice] = "Import successful"    
  end
  
  def import_tent_members_tool_from_csv
    @filecontent = @file.read
    @filecontent.force_encoding('UTF-8')
    @csv = CSV.new(@filecontent, headers: true, col_sep: ",", encoding: "UTF-8")
    @content = @csv.to_a.map {|row| row.to_hash }
    @content.each do |row|
      tent = Tent.find_by_source_id(row["zeltId"])
      child = Child.find_by_source_id(row["TeilnehmerId"])
      child.tent = tent
      child.save
    end
    flash[:notice] = "Import successful"
  end
  
  def import_tent_members_tool_from_xml
    @filecontent = @file.read
    @data = Hash.from_xml @filecontent
    @data["RECORDS"]["RECORD"].each do |row|
      tent = Tent.find_by_source_id(row["zeltId"])
      child = Child.find_by_source_id(row["TeilnehmerId"])
      child.tent = tent
      child.save
    end
    flash[:notice] = "Import successful"    
  end
  
  def import_scouts_from_csv
    @filecontent = @file.read
    @filecontent.force_encoding('UTF-8')
    @csv = CSV.new(@filecontent, headers: true, col_sep: ";")
    @content = @csv.to_a.map {|row| row.to_hash }
    @content.each do |row|
      data = {
        first_name: row["Vorname"],
        last_name: row["Nachname"],
        birthday: Date.strptime(row["Geburtsdatum"].split(' ')[0], '%d.%m.%Y')
      }
      scout = Scout.create(data)
      #create attendances for scouts
      d = Date.parse(Setting.find_by(key: :start_date).value)
      for d in (Date.parse(Setting.find_by(key: :start_date).value)..Date.parse(Setting.find_by(key: :end_date).value)) do
        pparams = {}
        pparams[:scout] = scout
        pparams[:date] = d
        pparams[:attending] = true
        Attendance.create(pparams)
      end
    end
    flash[:notice] = "Import successful"
  end
  
  def import_children_from_csv
    @filecontent = @file.read
    @filecontent.force_encoding('UTF-8')
    @csv = CSV.new(@filecontent, headers: true, col_sep: ";", encoding: "UTF-8")
    @content = @csv.to_a.map {|row| row.to_hash }
    @content.each do |row|
      data = {
        first_name: row["Vorname"],
        last_name: row["Nachname"],
        birthday: Date.strptime(row["Geburtsdatum"].split(' ')[0], '%d.%m.%Y')
      }
      tent = Tent.find_by_number(row["Zelt"])
      child = Child.create(data)
      child.tent = tent
      child.save
    end
    flash[:notice] = "Import successful"
  end
  
  def import_scouts
    def open_spreadsheet(file)
      case File.extname(file.original_filename)
        when ".csv" then Roo::CSV.new(file.path, nil, :ignore)
        when ".xls" then Roo::Excel.new(file.path, packed: false, file_warning: :ignore)
        when ".xlsx" then Roo::Excelx.new(file.path, packed: nil, file_warning: :ignore)
        else raise "Unknown file type: #{file.original_filename}"
      end
    end
    spreadsheet = open_spreadsheet(@file)
    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      data = {
        first_name: row["Vorname"],
        last_name: row["Nachname"],
        birthday: Date.parse(row["Geburtsdatum"].to_s)
      }
      scout = Scout.create(data)
      #create attendances for scouts
      d = Date.parse(Setting.find_by(key: :start_date).value)
      for d in (Date.parse(Setting.find_by(key: :start_date).value)..Date.parse(Setting.find_by(key: :end_date).value)) do
        pparams = {}
        pparams[:scout] = scout
        pparams[:date] = d
        pparams[:attending] = true
        Attendance.create(pparams)
      end
    end
    flash[:notice] = "Import successful"
  end
  
  def import_children
    def open_spreadsheet(file)
      case File.extname(file.original_filename)
        when ".csv" then Roo::CSV.new(file.path, nil, :ignore)
        when ".xls" then Roo::Excel.new(file.path, packed: false, file_warning: :ignore)
        when ".xlsx" then Roo::Excelx.new(file.path, packed: nil, file_warning: :ignore)
        else raise "Unknown file type: #{file.original_filename}"
      end
    end
    spreadsheet = open_spreadsheet(@file)
    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      data = {
        first_name: row["Vorname"],
        last_name: row["Nachname"],
        birthday: Date.parse(row["Geburtsdatum"].to_s),
        #tent_id: row["Zelt"]
      }
      tent = Tent.find_by_number(row["Zelt"])
      child = Child.create(data)
      child.tent = tent
      child.save
    end
    flash[:notice] = "Import successful"
  end
end
