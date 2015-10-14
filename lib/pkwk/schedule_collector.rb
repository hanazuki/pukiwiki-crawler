# coding: utf-8

module Pkwk
  class ScheduleCollector < Collector
    def process(title, revision, io)
      events = io.each_line.map do |l|
        if l =~ RE_FILTER
          data = {}

          [RE_DATE, RE_TIME, RE_TITLE].each do |re|
            $~.names.each {|n| data[n.to_sym] = $~[n] } if l =~ re
          end

          [:year, :month, :day, :start_hour, :start_min, :end_hour, :end_min].each do |s|
            data[s] = data[s].try!(:to_i)
          end

          data[:wday] = WDAYS[data[:wday]]
          data[:year] ||= estimate_year_by_wday(data) ||
                          estimate_year_by_title(title) ||
                          estimate_year_by_mtime(revision)

          if data[:title]
            data[:title].strip!
            data[:title] = title + ' ' + (data[:title].start_with?('+') ? data[:title][1..-1] : data[:title])
          else
            data[:title] = title
          end

          data if [:year, :month, :day, :title].all? {|s| data[s] }
        end
      end.compact

      {events: events}
    end

    WDAYS = {'日' => 0, '月' => 1, '火' => 2, '水' => 3, '木' => 4, '金' => 5, '土' => 6}
    RE_WDAY = Regexp.union(WDAYS.keys)
    RE_DATE = /(?:(?<year>\d{1,4})\s*[\/年]\s*)?(?<month>\d{1,2})\s*[\/月]\s*(?<day>\d{1,2})(?:\s*日)?(?:\s*[(（](?<wday>#{RE_WDAY})[)）])?/
    RE_TITLE = /&title\((?<title>.*?)\);/
    RE_TIME = /(?<start_hour>\d{1,2}):(?<start_min>\d{1,2})(?:\s*(?:[-~−〜]|から)\s*(?<end_hour>\d{1,2}):(?<end_min>\d{1,2}))?/
    RE_FILTER = /(?:日時|日付|日程)[:\|\s]*(?:#{RE_DATE})|(?:#{RE_DATE}).*(?:#{RE_TITLE})/

    def estimate_year_by_wday(data)
      now = Time.now
      if wday = data[:wday]
        0.upto(10) do |i|
          t = Time.local(now.year - i, data[:month], data[:day])
          return t.year if t.wday == wday
        end
      end
    end

    def estimate_year_by_title(title)
      return $&.to_i if title =~ /\d{4}/
    end

    def estimate_year_by_mtime(revision)
      if revision.kind_of?(Time)
        now = Time.now
        return now.year - 1 if revision.month < now.month - 6
        return now.year + 1 if revision.month > now.month + 6
        return now.year
      end
    end
  end
end
