module BAMFCSV
  class Table
    include Enumerable
    def initialize(matrix, opts = {})
      @opts = opts
      @headers = matrix.shift

      if @opts.has_key? :header_converters
        if !@opts[:header_converters].is_a? Array
          @opts[:header_converters] = [@opts[:header_converters]]
        end
        @opts[:header_converters].each do |converter|
          if converter.is_a? Symbol
            @headers.collect! { |v| v.send(converter) }
          end
        end
      end

      @matrix = matrix
      @header_map = {}
      @headers.each_with_index do |h, i|
        @header_map[h] = i
      end
      @row_cache = []
    end

    def each
      if block_given?
        @matrix.size.times do |idx|
          yield self[idx]
        end
      end
      self
    end

    def [](idx)
      idx += @matrix.size if idx < 0
      return if idx < 0 || idx >= @matrix.size
      @row_cache[idx] ||= Row.new(@header_map, @matrix[idx])
    end

    def empty?
      @matrix.empty?
    end

    def inspect
      "[#{self.map{|r| r.inspect}.join(", ")}]"
    end

    private
    def row_hash(row)
      Hash[@headers.zip(row)]
    end

    class Row
      attr_reader :fields

      def initialize(header_map, fields)
        @header_map = header_map
        @fields = fields
      end

      def headers
        @header_map.keys
      end

      def [](key)
        @fields[@header_map[key]]
      end

      def to_hash
        pairs = []
        headers.each{ |h| pairs << [h, self[h]] }
        Hash[pairs]
      end

      def inspect
        pairs = []
        headers.each do |h|
          pairs << "#{h.inspect} => #{self[h].inspect}"
        end
        "{#{pairs.join(", ")}}"
      end

    end
  end
end
