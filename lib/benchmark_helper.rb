class BenchmarkHelper
  def initialize(logger: Rails.logger, prefix: '', count: nil, should_print: true, with_summary: false)
    @count = count
    @logger = logger
    @prefix = prefix
    @start_time = Time.current
    @should_print = should_print
    @with_summary = with_summary
  end

  # All parameters are optional and will use whatever was passed to the constructor if not supplied here.
  # This allows for two use cases:
  #
  # 1.
  #
  # benchmark = BenchmarkHelper.new(prefix: 'Some prefix', count: 10000, should_print: true, with_summary: true)
  # benchmark.with_benchmark do
  #   # work to benchmark
  # end
  #
  # 2.
  #
  # benchmark = BenchmarkHelper.new
  # (0..10).each do |i|
  #   even = i % 2 == 0
  #   benchmark.with_benchmark(prefix: "Is Even? #{even}", count: i, should_print: !even, with_summary: i % 5 == 0) do
  #     # some work that may differ based on i
  #   end
  # end
  #
  def with_benchmark(prefix: @prefix, start_time: @start_time, count: @count, should_print: @should_print,
                     with_summary: @with_summary)
    @logger.info "#{prefix} START" if should_print
    yield
    end_time   = Time.current
    elapsed_ms = (end_time - start_time) * 1_000
    @logger.info benchmark_end_str(prefix, elapsed_ms, count) if should_print
    @logger.info benchmark_summary_str(prefix, elapsed_ms) if should_print && with_summary
  end

  private

  def benchmark_end_str(prefix, elapsed_ms, count)
    avg_str = count.present? ? "-> Avg: #{elapsed_ms / (1.0 * count)} ms for #{count} items" : ''
    "#{prefix} DONE took #{elapsed_ms} ms #{avg_str}"
  end

  # Takes elapsed ms and turns it into HH:MM:SS
  def benchmark_summary_str(prefix, elapsed_ms)
    summary_time = Time.at(elapsed_ms / 1000).utc.strftime('%H:%M:%S')
    "#{prefix} SUMMARY Elapsed: #{summary_time}"
  end
end
