class Static
  attr_reader :app, :root

  def initialize(app)
    @app = app
    @root = :public
  end

  def call(env)
    file_path = requested_file_name(env)

    if can_serve?(file_path)
      res = render_file(file_path)
    else
      res = app.call(env)
    end

    res
  end

  private

  MIME_TYPES = {
    '.txt' => 'text/plain',
    '.jpg' => 'image/jpeg',
    '.zip' => 'application/zip'
  }

  def can_serve?(path)
    path.index("#{root}")
  end

  def requested_file_name(env)
    req = Rack::Request.new(env)
    path = req.path
    dir = File.dirname(__FILE__)
    File.join(dir, '..', path)
  end

  def render_file(file_path)
    res = Rack::Response.new

    if File.exist?(file_path)
      file = File.read(file_path)

      res.status = 200
      res['Content-Type'] = "#{MIME_TYPES[file_path.match(/.\w+$/)[0]]}"
      res.write(file)

      res
    else
      res.status = 404
      res.write("File not found")
    end

    res
  end
end
