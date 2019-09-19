module Etcd::Utils
  # Calculate range_end for given prefix
  def prefix_range_end(prefix)
    bytes = Base64.decode(prefix)
    # Add to byte array, handling carry
    size = bytes.size
    carry = false
    size.times do |offset|
      index = size - 1 - offset
      if offset == 0 || carry
        bytes[index] += 1
        carry = bytes[index] == UInt8::MIN
      else
        break
      end
    end

    Base64.strict_encode(bytes)
  end
end
