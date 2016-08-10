require 'active_support'
require 'active_support/core_ext'
require 'active_support/inflector'
require 'erb'
require_relative './session'
require_relative './flash'
require 'byebug'

class ControllerBase
  attr_reader :req, :res, :params

  # Setup the controller
  def initialize(req, res, route_params = {})
    @req, @res = req, res
    @params = route_params
    @already_built_response = false
  end

  # Helper method to alias @already_built_response
  def already_built_response?
    @already_built_response
  end

  # Set the response status code and header
  def redirect_to(url)
    raise 'double render error' if already_built_response?

    @already_built_response = true
    @res.status = 302
    @res['Location'] = url

    session.store_session(@res)
    flash.store_flash(@res)

    nil
  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type)
    raise 'double render error' if already_built_response?

    @already_built_response = true
    @res.write(content)
    @res['Content-Type'] = content_type

    session.store_session(@res)
    flash.store_flash(@res)

    nil
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    template_path = "#{File.dirname(__FILE__)}/../views/#{self.class.name.underscore}/#{template_name}.html.erb"
    file_content = File.read(template_path)
    content = ERB.new(file_content).result(binding)
    render_content(content, 'text/html')
  end

  # method exposing a `Session` object
  def session
    @session ||= Session.new(@req)
  end

  def flash
    @flash ||= Flash.new(@req)
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
    self.send(name)
    render(name) unless already_built_response?

    nil
  end
end
