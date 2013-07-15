class Route
  attr_reader :pattern, :http_method, :controller_class, :action_name

  def initialize(pattern, http_method, controller_class, action_name)
    @pattern = pattern
    @http_method = http_method
    @controller_class = controller_class
    @action_name = action_name

  end

  def matches?(req)
    req.request_method.downcase.to_sym == @http_method && req.path =~ @pattern
  end

  def run(req, res)
    match_data = @pattern.match(req.path)
    route_params = Hash.new
    match_data.names.each_with_index do |name, i|
      route_params[name.to_sym] = match_data.captures[i]
    end
    x = @controller_class.new(req, res, route_params)
    x.invoke_action(@action_name)
  end
end

class Router
  attr_reader :routes

  def initialize
    @routes = []
  end

  def add_route(pattern, method, controller_class, action_name)
    @routes << Route.new(pattern, method, controller_class, action_name)
  end

  def draw(&proc)
    self.instance_eval(&proc)
  end

  [:get, :post, :put, :delete].each do |http_method|
    # add these helpers in a loop here
    define_method(http_method) do |pattern, controller_class, action_name|
      add_route(pattern, http_method, controller_class, action_name)
    end
  end

  def match(req)
    @routes.find{|route| route.pattern =~ req.path}
  end

  def run(req, res)
    unless match(req)
      res.status = 404
    else
      match(req).run(req, res)
    end
  end
end
