require 'stringio'

module Pkwk
  class Crawler
    def initialize(wiki)
      @subscribers = []
      @wiki = wiki
    end

    def <<(subscriber)
      @subscribers << subscriber
    end

    def crawl
      @wiki.each do |page|
        title = page.title.encode('utf-8')
        mtime = page.mtime

        if @subscribers.any? {|subscriber| subscriber.needs_update?(title, mtime) }
          content = page.content.encode('utf-8')
          @subscribers.each do |subscriber|
            subscriber.update(title, mtime, StringIO.new(content)) if subscriber.needs_update?(title, mtime)
          end
        end
      end
    end
  end
end
