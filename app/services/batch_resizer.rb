class BatchResizer
  def initialize(size, &block)
    @size = size
    @block = block
    @queue = []
  end

  def push(batch)
    @queue.concat(batch)
    yield_in_sized_batches
  end

  def flush
    @block.call(@queue) unless @queue.empty?
  end

  private

  def yield_in_sized_batches
    @block.call(@queue.shift(@size)) while @queue.size >= @size
  end
end
