class Attendance < ActiveRecord::Base
  belongs_to :scout
  validates_presence_of :scout, :date, :attending
end
