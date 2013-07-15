require 'json'
require 'webrick'

class Session
  def initialize(req)
    existing_cookie = req.cookies.select {|cookie| cookie.name == '_rails_lite_app'}
    if existing_cookie.empty?
      @cookie = {}
    else
      @cookie = JSON.parse(existing_cookie.first.value)
    end
    
  end

  def [](key)
    @cookie[key]
  end

  def []=(key, val)
    @cookie[key] = val
  end

  def store_session(res)
    res.cookies << WEBrick::Cookie.new('_rails_lite_app', @cookie.to_json)
  end
end
