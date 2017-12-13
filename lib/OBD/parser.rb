require_relative 'conversion'
require_relative 'error'

module OBD

  class Parser

    public
    def parse_supported_pids(pids)
      count, result = 0, {}
      pids.each do |hex_string|
        if ['NO DATA', '?', ''].include?(hex_string)
          count.upto(count+31) do
            count+=1
            result[Conversion.dec_to_hex(count)] = false
          end
        else
          raise OBD::ParameterError.format('hex_string', 'WHITE_SPACE') if hex_string.include?(' ')
          hex_string.split('').each do |hex_letter|
            Conversion.single_hex_to_4_bin(hex_letter).split('').each do |bin_number|
              count+=1
              result[Conversion.dec_to_hex(count)] = (bin_number == '1')
            end
          end
        end
      end
      return result
    end

  end

end