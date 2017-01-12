class AssertionError < RuntimeError; end

class ImmutableStack
  class EmptyStack
    def empty?
      true
    end

    def push(item)
      ImmutableStack.new(item, self)
    end

    def pop
      raise 'Cannot pop empty stack'
    end

    def peek
      raise 'Cannot peek empty stack'
    end
  end

  def self.empty
    EmptyStack.new
  end

  def initialize(head, tail)
    @head = head
    @tail = tail
  end

  attr_reader :head, :tail

  def peek
    head
  end

  def push(item)
    ImmutableStack.new(item, self)
  end

  def pop
    [tail, head]
  end

  def empty?
    false
  end
end


#### usage pattern:
#### remmeber, never modify existing data structure (or a reference to). 
s = ImmutableStack.empty

bottom = s.push('bottom')
mid = bottom.push('middle')
top = mid.push('top')

puts top.peek # -> 'top'

mid_, top_val = top.pop # -> a stack under current item
puts mid_.peek # 'middle'

bottom_, mid_val = mid_.pop
puts bottom_.peek # -> 'bottom'

empty_stack, bottom_val = bottom_.pop
begin
  empty_stack.peek
rescue RuntimeError => e
  puts e.message
end

#############################
# or with a mutable reference,
s = ImmutableStack.empty

s = s.push('bottom item')
s = s.push('top item')

val = s.peek
puts val # top item
s, val_ = s.pop
raise AssertionError unless val == val_

puts s.peek # bottom item
s, _ = s.pop

puts s.peek # Cannot peek empty stack (RuntimeError)
