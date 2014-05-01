require 'uri'

class Params
  # use your initialize to merge params from
  # 1. query string
  # 2. post body
  # 3. route params
  def initialize(req, route_params = {})
    @permitted = []
    @params = {}
    
    @params.merge!(route_params)
    @params.merge!(parse_www_encoded_form(req.body)) if req.body
    @params.merge!(parse_www_encoded_form(req.query_string)) if req.query_string
  end

  def [](key)
    @params[key]
  end

  def permit(*keys)
    @permitted += keys
  end

  def require(key)
    unless @params.keys.include?(key)
       raise AttributeNotFoundError
     end
  end

  def permitted?(key)
    @permitted.include?(key)
  end

  def to_s
    JSON.parse(@params)
  end

  class AttributeNotFoundError < ArgumentError; end;

  private
  # this should return deeply nested hash
  # argument format
  # user[address][street]=main&user[address][zip]=89436
  # should return
  # { "user" => { "address" => { "street" => "main", "zip" => "89436" } } }
  def parse_www_encoded_form( www_encoded_form)
    nested_hash = {}
      
    URI.decode_www_form(www_encoded_form).each do |pair|      
      array_of_keys = parse_key(pair[0])
      
      level_hash = nested_hash
      while array_of_keys.length > 1
        unless level_hash.keys.include?(array_of_keys.first)               
          level_hash[array_of_keys.first] = {}
        end
        
        level_hash = level_hash[array_of_keys.first]
        array_of_keys.shift
      end
      
      level_hash[array_of_keys.first] = pair[1]
    end
    
     nested_hash
  end

  # this should return an array
  # user[address][street] should return ['user', 'address', 'street']
  def parse_key(key)
    if key.empty?
      key
    else
      key.split(/\]\[|\[|\]/)
    end
  end
end


