class Valuedate

  class Scope
    def value
      Value.new
    end

    def optional_value
      OptionalValue.new
    end
  end

  class Value < Valuedate
  end

  class OptionalValue < Valuedate
    def validate(value = nil)
      value.nil? || super
    end
  end


  def initialize(&block)
    @validators = []
    @validators << Scope.new.instance_eval(&block) if block
  end

  def hash(schema={})
    valid? do |value|
      value ||= {}
      schema.all? do |(key, validator)|
        validator.validate(value[key])
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
    if matcher = Valuedate.matchers[method]
      valid? { |value| matcher.call(value, *args) }
    else
      super
    end
  end

  @matchers = {}
  class << self
    attr_reader :matchers

    def validate(value, &block)
      schema(&block).validate(value)
    end

    def schema(&block)
      new(&block)
    end

    def matcher(name, &block)
      undef_method(name) if respond_to?(name)
      @matchers[name] = block
    end
  end

end

Valuedate.matcher(:equals) { |value, expected| value == expected }
Valuedate.matcher(:is_a) { |value, expected| value.is_a?(expected) }
Valuedate.matcher(:any) do |value, *validators|
  validators.any? { |validator| validator.validate(value) }
end
