# ty: https://raw.github.com/djberg96/memoize/master/lib/memoize.rb

module Memoizeable
  @@cache = {}

  def self.memoize name
    alias_method "original_#{name}".to_sym, name.to_sym
    puts "defining: #{name}"
    define_method name do |*args|
      key = [name].concat args
      unless @@cache.has_key? key
        @@cache[key] = send("original_#{name}", *args) 
      end
      @@cache[args]
    end
    @@cache
  end

  def dememoize name, *args
    key = [name].concat args
    begin
      @@cache.delete key
    rescue
      puts "Could not dememoize: #{key}"
    end
  end
end
