require 'erb'
require 'active_support/inflector'
require 'binding_of_caller'
require_relative 'params'
require_relative 'session'



class ControllerBase
  attr_reader :params, :req, :res

  # setup the controller
  #route_params { query_string: 'query string', cookies: 'cookie', body: 'body'}
  def initialize(req, res, route_params = {})
    @req = req
    @res = res
  end

  # populate the response with content
  # set the responses content type to the given type
  # later raise an error if the developer tries to double render
  def render_content(content, type)
    raise "error in render_content" if already_built_response?
    res.content_type = type
    res.body = content
    @already_built_response = true
    session.store_session(@res)
  end

  # helper method to alias @already_built_response
  def already_built_response?
    !!@already_built_response
  end

  # set the response status code and header
  def redirect_to(url)
    raise "error in redirect_to" if already_built_response?
    res.status = 302
    res["Location"] = url
    @already_built_response = true
    session.store_session(@res)
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    template = File.read("views/#{self.class.to_s.underscore}/#{template_name}.html.erb")    
    view = ERB.new(template).result(binding)
    render_content(view, 'text/html')
  end

  # method exposing a `Session` object
  def session
    @session ||= Session.new(@req)
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
  end
end
