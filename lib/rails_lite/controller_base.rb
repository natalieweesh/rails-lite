require 'erb'
require 'active_support/core_ext'
require_relative 'params'
require_relative 'session'

class ControllerBase
  attr_reader :params
  attr_accessor :already_rendered, :response_built

  def initialize(req, res, route_params=nil)
    @request = req
    @response = res
    @params = Params.new(req, route_params)
    @already_rendered = false
    @response_built = false
  end

  def session
    @session ||= Session.new(@request)
  end

  def already_rendered?
    @already_rendered
  end

  def redirect_to(url)
    unless @response_built
      @response.status = 302
      @response['location'] = url
      @response_built = true
      session.store_session(@response)
    end
  end

  def render_content(content, type)
    unless @already_rendered
      @response.content_type = type
      @response.body = content
      @already_rendered = true
      session.store_session(@response)
    end
  end

  def render(template_name)
    controller_name = self.class.name.underscore
    template_file = File.read("views/#{controller_name}/#{template_name}.html.erb")
    erb_template = ERB.new(template_file).result(binding)
    render_content(erb_template, 'text/html')
  end

  def invoke_action(name)
    self.send(name)
    unless already_rendered?
      invoke_action(:render)
    end
  end
end
