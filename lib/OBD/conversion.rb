module Conversion

  public
  def self.hex_to_bin(input)
    input.to_i(16).to_s(2)
  end

  public
  def self.hex_to_bin_rjust(input)
    input.to_i(16).to_s(2).rjust(input.size*4, '0')
  end

  public
  def self.hex_to_dec(input)
    input.to_i(16)
  end

  public
  def self.dec_to_hex(input)
    '%02X' % input
  end

  public
  def self.dec_to_bin(input)
    input.to_s(2)
  end

end