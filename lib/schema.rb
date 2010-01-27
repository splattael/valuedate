class Schema
  def initialize(&block)
    @validators = []
    instance_eval(&block) if block
  end

  def equals(expected)
    append { |value| value == expected }
  end

  def is_a?(expected)
    append { |value| value.is_a?(expected) }
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

  def append(&block)
    @validators << block
    self
  end
end
