class Object
  def try!(*a, &b)
    unless nil?
      if a.empty? && block_given?
        yield self
      else
        public_send(*a, &b)
      end
    end
  end
end

module Pkwk
  autoload :Crawler, File.join(__dir__, 'pkwk/crawler')
  autoload :Collector, File.join(__dir__, 'pkwk/collector')
  autoload :AnnounceCollector, File.join(__dir__, 'pkwk/announce_collector')
  autoload :ScheduleCollector, File.join(__dir__, 'pkwk/schedule_collector')
  autoload :Pukiwiki, File.join(__dir__, 'pkwk/pukiwiki')
end
