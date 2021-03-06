module DateParser
  @@isoDateFormatter = nil

  # Parse a date string: E.g.:
  #
  # DateParser.parse_date "There is a date in here tomorrow at 9:00 AM"
  #
  # => 2013-02-20 09:00:00 -0800
  def self.parse_date(date_string)
    if date_string.match(/\d{2}T\d{2}/)
      return fractional_date(date_string) if date_string =~ /\.\d{3}Z$/
      return Time.iso8601(date_string)
    end

    detect(date_string).first.date
  end

  # Parse time zone from date
  #
  # DateParser.parse_date "There is a date in here tomorrow at 9:00 AM EDT"
  #
  # Caveat: This is implemented per Apple documentation. I've never really
  #         seen it work.
  def self.parse_time_zone(date_string)
    detect(date_string).first.timeZone
  end

  # Parse a date string: E.g.:
  #
  # SugarCube::DateParser.parse_date "You have a meeting from 9:00 AM to 3:00 PM"
  #
  # => 21600.0
  #
  # Divide by 3600.0 to get number of hours duration.
  def self.parse_duration(date_string)
    detect(date_string).first.send(:duration)
  end

  # Parse a date into a raw match array for further processing
  def self.match(date_string)
    detect(date_string)
  end

  private
  def self.detect(date_string)
    error = Pointer.new(:object)
    detector = NSDataDetector.dataDetectorWithTypes(NSTextCheckingTypeDate, error:error)
    matches = detector.matchesInString(date_string, options:0, range:NSMakeRange(0, date_string.length))
  end

  def self.allocate_date_formatter
    @@isoDateFormatter = NSDateFormatter.alloc.init
    @@isoDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ'"
  end

  def self.fractional_date(date_string)
    allocate_date_formatter if @@isoDateFormatter.nil?
    date = @@isoDateFormatter.dateFromString date_string
    return date
  end
end


class String
# Use NSDataDetector to parse a string containing a date
# or duration. These can be of the form:
#
# "tomorrow at 7:30 PM"
# "11.23.2013"
# "from 7:30 to 10:00 AM"
#
# etc.
  def to_date
    DateParser.parse_date(self)
  end

  def to_timezone
    DateParser.parse_time_zone(self)
  end

  def to_duration
    DateParser.parse_duration(self)
  end
end
