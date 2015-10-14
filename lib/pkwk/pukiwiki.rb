require 'forwardable'
require 'pathname'
require 'uri'

module Pkwk
  class Pukiwiki
    include Enumerable

    attr_reader :path, :uri, :encoding

    def initialize(path, uri, encoding)
      @path = Pathname.new(path)
      @uri = URI.parse(uri)
      @encoding = Encoding.find(encoding)
    end

    def each
      path.each_child(false) do |file|
        if file.extname == EXTNAME
          yield Page.new(self, path + file)
        end
      end
    end

    EXTNAME = '.txt'

    class Page
      extend Forwardable

      attr_reader :path, :title
      def_delegators :@path, :mtime

      def initialize(wiki, path)
        @wiki = wiki
        @path = path
        @title = @wiki.decode_title(path.basename(EXTNAME))
      end

      def uri
        @wiki.uri + ('?' + URI.encode_www_form_component(@title.encode(@wiki.encoding)))
      end

      def content
        File.open(path, "r:#{@wiki.encoding}") {|f| f.read }
      end
    end

    def decode_title(path)
      [path.to_s].pack('H*').force_encoding(encoding)
    end

    def encode_title(title)
      title.to_s.encode(encoding).unpack('H*').first.upcase
    end
  end
end
