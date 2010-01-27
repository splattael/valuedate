class Schema
  def initialize(&block)
    @validators = []
    instance_eval(&block) if block
  end

  def equals(expected)
    append { |value| value == expected }
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
  end
end
