$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "socialjack"
  s.version     = "0.0.2"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Robby Ranshous"]
  s.email       = ["rranshous@gmail.com"]
  s.homepage    = "http://oneinchmile.com"
  s.summary     = "jack is a very social boy"
  s.description = "all work and no chatter makes jack a crouchy boy"

  s.files        = Dir.glob("{lib}/**/*")
  s.require_path = 'lib'
end
