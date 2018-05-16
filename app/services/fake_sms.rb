class FakeSMS
  Message = Struct.new(:from, :to, :body)

  attr_accessor :messages


  def initialize
    @messages = []
  end


  def messages
    self
  end

  def create(from:, to:, body:)
    @messages << Message.new(from: from, to: to, body: body)
  end
end
