module Pkwk
  class AnnounceCollector < Collector
    def process(title, revision, io)
      announces = io.each_line.slice_before(RE_ANNOUNCE).map do |fst, snd|
        {start: $~[:start], end: $~[:end], content: format(snd)} if fst =~ RE_ANNOUNCE
      end.compact

      {announces: announces}
    end

    def format(s)
      s.gsub(%r{^//\s*}, '').strip
    end

    RE_DATE = /\d{4}-\d{2}-\d{2}/
    RE_ANNOUNCE = %r{\A//\s*announce\s*\((?<start>#{RE_DATE})\s*,\s*(?<end>#{RE_DATE})\s*\)}
  end
end
