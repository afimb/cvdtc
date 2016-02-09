module JobHelper
  def grouped_time_zone
    time_zone = ActiveSupport::TimeZone::MAPPING
    {}.tap { |hash|
      time_zone.map{ |k, v|
        group = v.split('/').first
        hash[group] ||= []
        hash[group] << k
        hash[group].sort!
      }
    }.sort
  end
end
