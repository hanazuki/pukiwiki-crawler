require 'pathname'
require 'yaml'

module Pkwk
  class Collector
    def initialize(cache_path)
      @cache_path = Pathname.new(cache_path)
      load
    end

    def load
      @dirty = false
      @cache = YAML.load_file(@cache_path)
      @cache = {} unless @cache.kind_of?(Hash)
    rescue Errno::ENOENT
      @cache = {}
    end

    def save
      open(@cache_path, 'w') {|f| YAML.dump(@cache, f) } if @dirty
    end

    def needs_update?(title, revision)
      cached = @cache[title].try! {|s| s[:revision] }
      !cached || cached != revision
    end

    def update(title, revision, io)
      @dirty = true
      @cache[title] = process(title, revision, io).merge(revision: revision)
    end
  end
end
