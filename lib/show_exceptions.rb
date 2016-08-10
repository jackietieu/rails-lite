require 'erb'

class ShowExceptions
  attr_reader :app

  def initialize(app)
    @app = app
  end

  def call(env)
    begin
      app.call(env)
    rescue Exception => e
      #require 'byebug'; debugger
      render_exception(e)
    end
  end

  private

  def render_exception(e)
    template_path = "#{File.dirname(__FILE__)}/templates/rescue.html.erb"
    file_content = File.read(template_path)
    body = ERB.new(file_content).result(binding)

    res = ['500', {'Content-type' => 'text/html'}, body]
  end
end
