json.array!(@attendances) do |attendance|
  json.extract! attendance, :id, :date, :scout_id, :attending
  json.url attendance_url(attendance, format: :json)
end
