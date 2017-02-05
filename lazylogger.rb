module LazyLogger
  extend self

  attr_accessor :output

  def log(&callback)
    @log_actions ||= []
    @log_actions << callback
  end

  def flush
    @log_actions.each { |e| e.call(output) }
  end
end

class User
  def initialize(id)
    @id = id
    LazyLogger.log { |out| out << "Created User with ID #{id}" }
  end
end

# Although this code may look simple, it has a subtle memory leak. 
# The leak can be verified via the following simple script, 
# which shows that 1000 users still exist in the system, 
# even though the objects were created as throwaway objects:

LazyLogger.output = ""
1000.times { |i| User.new(i) }

GC.start
p ObjectSpace.each_object(User).count #=> 1000



############## but a version below won't end up with proxy Users taking up space. 
module LazyLogger
  extend self

  attr_accessor :output
  PPP = proc { |id, out| out << "Created User with ID #{id}" }

  def log(&callback)
    @log_actions ||= []
    @log_actions << callback
  end

  def flush
    @log_actions.each { |e| e.curry.call(output) }
  end

end

class User
  def initialize(id)
    LazyLogger.log &LazyLogger::PPP.curry.call(id)
  end
end


LazyLogger.output = ""
1000.times { |i| User.new(i) }
GC.start

p ObjectSpace.each_object(User).count #=> 1
# p ObjectSpace.each_object(LazyLogger).count

LazyLogger.flush
p LazyLogger.output
