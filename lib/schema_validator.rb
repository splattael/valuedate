require 'pp'

class SchemaValidator

  class Caller
    def value
      SchemaValidator.new
    end
  end

  attr_reader :validators

  def initialize(&block)
    @validators = []
    @validators << Caller.new.instance_eval(&block) if block
  end

  def hash(schema={})
    valid? do |value|
      schema.all? do |(key, validator)|
        validator.validate(value[key])
      end
    end
  end

  def validate(value = nil)
    if @validators.empty?
      value.nil?
    else
      @validators.all? do |validator|
        validator.call(value)
      end
    end
  end
  alias call validate

  def valid?(&block)
    @validators << block
    self
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

  @matchers = {}
  class << self
    attr_reader :matchers

    def validate(value, &block)
      self.class.new(&block).validate(value)
    end

    def matcher(name, &block)
      undef_method(name) if respond_to?(name)
      @matchers[name] = proc do |value, expected|
        result = block.call(value, expected)
        puts "#{value.inspect} #{name} #{expected.inspect} => #{result.inspect}" if $DEBUG
        result
      end
    end
  end

end

SchemaValidator.matcher(:equals) { |value, expected| value == expected }
SchemaValidator.matcher(:is_a) { |value, expected| value.is_a?(expected) }
