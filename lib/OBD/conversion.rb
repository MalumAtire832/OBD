module Conversion

  def self.hex_to_bin(input)
    input.to_i(16).to_s(2)
  end

  def self.hex_to_bin_rjust(input)
    input.to_i(16).to_s(2).rjust(input.size*4, '0')
  end

  def self.hex_to_dec(input)
    input.to_i(16)
  end

  def self.dec_to_hex(input)
    '%02X' % input
  end

  def self.dec_to_bin(input)
    input.to_s(2)
  end

end