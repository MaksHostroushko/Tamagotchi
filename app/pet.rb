require "erb"
require './app/lib/logic'

class Pet
  include Logic

  def self.call(env)
    new(env).response.finish
  end

  def initialize(env)
    @req    = Rack::Request.new(env)
    @food   = 50
    @health = 50
    @sleep  = 50
    @happy  = 50
    @drink  = 0
    $NEEDS  = %w[health food sleep happy]
  end

  def response
    case @req.path
    when '/'
      Rack::Response.new(render("form.html.erb"))

    when '/initialize'
      Rack::Response.new do |response|
        response.set_cookie('health', @health)
        response.set_cookie('food', @food)
        response.set_cookie('sleep', @sleep)
        response.set_cookie('happy', @happy)
        response.set_cookie('drink', @drink)
        response.set_cookie('name', @req.params['name'])
        response.redirect('/start')
      end

    when '/exit'
      Rack::Response.new(render("over.html.erb"))

    when '/meditation'
      if get("drink") >= 100
        Rack::Response.new(render("complete.html.erb"))
      else
        Rack::Response.new(render("meditation.html.erb"))
      end
    when '/meditationtwo'
        return Logic.meditation_params(@req, 'drink') if @req.params['drink']

    when '/start'
      if get("health") <=0 || get("food") <= 0 || get("sleep") <= 0 || get("happy") <= 0
        return Rack::Response.new('Game Over', 404)
      else
        return Rack::Response.new(render("index.html.erb"))
      end

    when '/change'
      return Logic.change_params(@req, 'health') if @req.params['health']
      return Logic.change_params(@req, 'food')   if @req.params['food']
      return Logic.change_params(@req, 'sleep')  if @req.params['sleep']
      return Logic.change_params(@req, 'happy')  if @req.params['happy']
      return Logic.change_params(@req, 'drink')  if @req.params['drink']
    else
      Rack::Response.new('Not Found', 404)
    end
  end

  def render(template)
    path = File.expand_path("../views/#{template}", __FILE__)
    ERB.new(File.read(path)).result(binding)
  end

  def name
    name = @req.cookies['name'].delete(' ')
    name.empty? ? 'Pet' : @req.cookies['name']
  end

  def get(attr)
    @req.cookies["#{attr}"].to_i
  end
end
