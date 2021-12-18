class Day16
  def self.from_file_location(file_location)
    from_hex(File.read(file_location).strip)
  end

  def self.from_hex(hex)
    to_binary = HexToBinary.new(4)

    new(hex.chars.map(&to_binary).join)
  end

  def initialize(binary_stream)
    @binary_stream = binary_stream
  end

  def first_solution
    consumer = StreamConsumer.new(@binary_stream)
    reader = Reader.new
    packets = reader.read_packets(consumer: consumer)

    sum = 0

    while packets.any?
      packet = packets.shift
      sum += packet.version

      packets += packet.children
    end

    sum
  end

  def second_solution
    consumer = StreamConsumer.new(@binary_stream)
    reader = Reader.new
    packets = reader.read_packets(consumer: consumer)

    packets.first.value
  end

  class StreamConsumer
    def initialize(stream)
      @stream = String(stream)
      @offset = 0
    end

    def done?
      @stream.length - @offset < 7
    end

    def consume(n)
      @stream[@offset..(@offset + n).pred].tap do
        @offset += n
      end
    end
  end

  class Reader
    def read_packets(consumer:)
      packets = []

      until consumer.done?
        packets << read_packet(consumer: consumer)
      end

      packets
    end

    def read_packet(consumer:)
      binary_to_integer = BinaryToInteger.new

      version = consumer.consume(3).then(&binary_to_integer)
      packet_type_id = consumer.consume(3).then(&binary_to_integer)

      if packet_type_id == 4
        value = read_literal_packet_value(consumer: consumer)

        LiteralPacket.new(
          version: version,
          packet_type_id: packet_type_id,
          value: value,
        )
      else
        length_type_id = consumer.consume(1).then(&binary_to_integer)

        if length_type_id == 0
          length_in_bits = consumer.consume(15).then(&binary_to_integer)
          sub_consumer = StreamConsumer.new(consumer.consume(length_in_bits))

          sub_packets = read_packets(consumer: sub_consumer)

          OperatorPacket.new(
            version: version,
            packet_type_id: packet_type_id,
            length_type_id: length_type_id,
            length_parameter: length_in_bits,
            children: sub_packets
          )
        else
          number_of_subpackets = consumer.consume(11).then(&binary_to_integer)

          sub_packets = number_of_subpackets.times.map do
            read_packet(consumer: consumer)
          end

          OperatorPacket.new(
            version: version,
            packet_type_id: packet_type_id,
            length_type_id: length_type_id,
            length_parameter: number_of_subpackets,
            children: sub_packets
          )
        end
      end
    end

    def read_literal_packet_value(consumer:)
      binary_to_integer = BinaryToInteger.new

      last_group = false
      literal_binary_value = ""

      while !last_group
        leading_bit = consumer.consume(1).then(&binary_to_integer)

        last_group = leading_bit == 0

        literal_binary_value += consumer.consume(4)
      end

      literal_binary_value.then(&binary_to_integer)
    end
  end

  class LiteralPacket
    def initialize(version:, packet_type_id:, value:)
      @version = version
      @packet_type_id = packet_type_id
      @value = value
      @children = []
    end

    attr_reader :children
    attr_reader :packet_type_id
    attr_reader :value
    attr_reader :version
  end

  class OperatorPacket
    def initialize(version:, packet_type_id:, children:, length_type_id:, length_parameter:)
      @version = version
      @packet_type_id = packet_type_id
      @length_type_id = length_type_id
      @length_parameter = length_parameter
      @children = children
    end

    def value
      case @packet_type_id
      when 0
        @children.sum(&:value)
      when 1
        @children.map(&:value).reduce(&:*)
      when 2
        @children.map(&:value).min
      when 3
        @children.map(&:value).max
      when 5
        first, second = @children

        first.value > second.value ? 1 : 0
      when 6
        first, second = @children

        first.value < second.value ? 1 : 0
      when 7
        first, second = @children

        first.value == second.value ? 1 : 0
      else
        raise "Unexpected packet type #{@packet_type_id}"
      end
    end

    attr_reader :children
    attr_reader :length_type_id
    attr_reader :length_parameter
    attr_reader :packet_type_id
    attr_reader :version
  end

  class HexToBinary
    def initialize(bits)
      @bits = bits
      @to_proc = -> (x) { "%0#{bits}d" % x.to_i(16).to_s(2) }
    end

    attr_reader :to_proc

    def call(hex)
      to_proc.call(hex)
    end
  end

  class BinaryToInteger
    def initialize
      @to_proc = -> (x) { x.to_i(2) }
    end

    attr_reader :to_proc

    def call(binary)
      to_proc.call(binary)
    end
  end
end
