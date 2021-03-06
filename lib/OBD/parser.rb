require_relative 'conversion'
require_relative 'error'

module OBD

  class Parser

    public
    def parse_supported_pids(pids)
      count, result = 0, {}
      pids.each do |hex_string|
        if !has_data?(hex_string)
          count.upto(count+31) do
            count+=1
            result[Conversion.dec_to_hex(count)] = false
          end
        else
          raise OBD::ParameterError.format('hex_string', 'WHITE_SPACE') if hex_string.include?(' ')
          hex_string.split('').each do |hex_letter|
            Conversion.hex_to_bin_rjust(hex_letter).split('').each do |bin_number|
              count+=1
              result[Conversion.dec_to_hex(count)] = (bin_number == '1')
            end
          end
        end
      end
      return result
    end

    public
    def has_data?(data)
      !['NO DATA', 'NONE', '?', ''].include?(data)
    end

    public
    def raise_if_no_data(data, parameter)
      raise OBD::ParameterError.nodata(parameter, data) unless has_data?(data)
    end

  end

end