class Valuedate

  class ValidationFailed < StandardError
    attr_reader :errors

    def initialize(errors)
      super("validation failed with #{errors.size} errors")
      @errors = errors
    end
  end

  class Error
    attr_reader :options

    def initialize(options={})
      @options = options
    end
  end

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
    def call(value = nil)
      value.nil? || super
    end
  end

  attr_reader :errors

  def initialize(&block)
    @errors = []
    @validators = []
    if block
      validator = Scope.new.instance_eval(&block)
      @validators << validator if validator.respond_to?(:call)
    end
  end

  def hash(schema={})
    valid? do |value|
      value ||= {}
      schema.all? do |(key, validator)|
        validator.call(value[key]) || collect_errors!(validator, key)
      end
    end
  end

  def call(value = nil)
    @errors.clear
    @validators.all? { |validator| validator.call(value) || collect_errors!(validator) }
  end
  alias :validate :call

  def call!(value = nil)
    call(value) or raise ValidationFailed.new(@errors)
  end
  alias :validate! :call!

  def valid?(&block)
    @validators << block
    self
  end

  def collect_errors!(validator, key=nil)
    case validator
    when Valuedate
      @errors.concat(validator.errors.map { |error| error.options[:key] ||= key; error })
    end
    false
  end

  def errors
    @errors.uniq
  end

  def error(options={})
    @errors << Error.new(options)
    false
  end

  def method_missing(method, *args, &block)
    if matcher = Valuedate.matchers[method]
      valid? do |value|
        matcher.call(value, *args, &block) || error(:matcher => method, :value => value, :args => args)
      end
    else
      super
    end
  end

  @matchers = {}
  class << self
    attr_reader :matchers

    def validate(value, &block)
      schema(&block).call(value)
    end

    def validate!(value, &block)
      schema(&block).call!(value)
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
  validators.any? { |validator| validator.call(value) }
end
Valuedate.matcher(:in) { |value, expected| expected.include?(value) }
Valuedate.matcher(:is) { |*value, &block| block.call(*value)  }
Valuedate.matcher(:not) { |*value, &block| !block.call(*value)  }
Valuedate.matcher(:matches) { |value, expected| expected.match(value.to_s) }
