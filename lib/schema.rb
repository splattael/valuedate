require 'pp'

class Schema

  class Validator
    attr_reader :validators

    def initialize(schema, &block)
      @schema = schema
      @validators = [ block ]
    end

    def method_missing(method, *args, &block)
      @validators.concat(@schema.send(method, *args, &block).validators)
      self
    end

    def validate(value)
      @validators.all? do |block|
        block.call(value)
      end
    end

    def size
      @validators.size
    end

    def inspect
      "#<%s:%x @validators=%d>" % [ self.class.name, hash, size ]
    end
  end

  # Schema
  attr_reader :validators

  class << self
    attr_reader :matchers
  end
  @matchers = {}

  def self.validate(value, &block)
    Schema.new(&block).validate(value)
  end

  def initialize(&block)
    @validators = []
    instance_eval(&block) if block
  end

  def self.matcher(name, &block)
    @matchers[name] = proc do |value, expected|
      result = block.call(value, expected)
      puts "#{value.inspect} #{name} #{expected.inspect} => #{result.inspect}"
      result
    end
  end

  matcher(:equals) { |value, expected| value == expected }
  matcher(:is_a?) { |value, expected| value.is_a?(expected) }

  matchers.keys.each { |m| undef_method m if respond_to?(m) }

  def value
    Schema.new
  end

  def hash(schema={})
    valid? do |value|
      schema.all? do |(key, validator)|
        validator.validate(value[key])
      end
    end
  end

  def validate!(value = nil)
    if @validators.empty?
      value.nil?
    else
      @validators.all? do |validator|
        validator.validate(value)
      end
    end
  end

  def valid?(&block)
    Validator.new(self, &block).tap do |validator|
      @validators << validator
    end
  end

  def method_missing(method, *args, &block)
    if matcher = self.class.matchers[method]
      valid? do |value|
        matcher.call(value, args.first)
      end
    else
      super
    end
  end
end
