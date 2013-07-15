require 'uri'

class Params
  def initialize(req, route_params)
    @params = parse_www_encoded_form(req.query_string.to_s)
    @params.merge!(parse_www_encoded_form(req.body.to_s)) if req.body
    @params.merge!(route_params) if route_params
  end

  def [](key)
    @params[key]
  end

  def to_s
    @params.to_s
  end

  private
  def parse_www_encoded_form(www_encoded_form)
    nested_arr = URI.decode_www_form(www_encoded_form)
    params = {}
    nested_arr.each do |arr|
      keys = parse_key(arr[0])
      result = params
      keys.each_with_index do |key, i|
        if (i + 1) == keys.length
          result[key] = arr[1]
        else
          result[key] ||= {}
          result = result[key]
        end
      end
    end
    params
  end

  def parse_key(key)
    subkey = key.match(/\[?(\w*)\]?(\[?.*\]?)/)
    if subkey[2] == "" #then it's a top level thing
      #so stop it
      [subkey[1]]
    else #it is something like cat[owner]
      [subkey[1]] + parse_key(subkey[2])
    end
    
  end
end
