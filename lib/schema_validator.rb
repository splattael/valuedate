require 'pp'

class SchemaValidator

  class Scope
    def value
      Value.new
    end

    def optional_value
      OptionalValue.new
    end
  end

  class Value < SchemaValidator
  end

  class OptionalValue < SchemaValidator
    def validate(value = nil)
      puts "optional: #{value.inspect}" if $DEBUG
      value.nil? || super
    end
  end

  attr_reader :validators

  def initialize(&block)
    @validators = []
    @validators << Scope.new.instance_eval(&block) if block
  end

  def hash(schema={})
    valid? do |value|
      value ||= {}
      schema.all? do |(key, validator)|
        result = validator.validate(value[key])
        puts "hash[:#{key}] = #{value[key].inspect} # => #{result.inspect}" if $DEBUG
        result
      end
    end
  end

  def validate(value = nil)
    @validators.all? { |validator| validator.call(value) }
  end

  def call(value)
    validate(value)
  end

  def valid?(&block)
    @validators << block
    self
  end

  def method_missing(method, *args, &block)
    if matcher = SchemaValidator.matchers[method]
      valid? do |value|
        matcher.call(value, *args)
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
      @matchers[name] = proc do |value, *expected|
        result = block.call(value, *expected)
        puts "#{value.inspect} #{name} #{expected.inspect} => #{result.inspect}" if $DEBUG
        result
      end
    end
  end

end

SchemaValidator.matcher(:equals) { |value, expected| value == expected }
SchemaValidator.matcher(:is_a) { |value, expected| value.is_a?(expected) }
SchemaValidator.matcher(:any) do |value, *validators|
  validators.any? { |validator| validator.validate(value) }
end
