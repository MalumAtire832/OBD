module Conversion

  def hex_to_bin(input)
    input.to_i(16).to_s(2)
  end

  def hex_to_bin_rjust(input)
    input.to_i(16).to_s(2).rjust(input.size*4, '0')
  end

  def hex_to_dec(input)
    input.to_i(16)
  end

  def dec_to_hex(input)
    '%02X' % input
  end

  def dec_to_bin(input)
    input.to_s(2)
  end

end