module JobHelper
  def grouped_time_zone
    time_zone = ActiveSupport::TimeZone::MAPPING
    {}.tap do |hash|
      time_zone.map do |k, v|
        group = v.split('/').first
        hash[group] ||= []
        hash[group] << k
        hash[group].sort!
      end
    end.sort
  end
end
