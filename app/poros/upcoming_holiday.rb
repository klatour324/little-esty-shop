class UpcomingHoliday
  attr_reader :holiday
  def initialize(data)
    @holiday = data[:name]
  end
end