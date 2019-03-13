module API
  class SkuSalesSummaryController < AuthenticatedController
    include ActionController::Live

    def show
      write_timing('initializing publisher', &method(:publisher))
      serialized = write_timing("serializing sku sales summary #{sku_sales_summary_id}") do
        publisher.preview(sku_sales_summary_id)
      end
      writeln(json_html(serialized))
      if stream?
        response.stream.close
      else
        render json: serialized
      end
    end

    private

    def sku_sales_summary_id
      input = params[:id]
      raise "'#{input}' does not seem to be a valid sku_sales_summary_id id" unless input.present? && integer?(input)
      input.to_i
    end

    def stream?
      Rails.env.development? && params[:stream] != 'false'
    end

    def publisher
      @publisher ||= Indexer::IndexPublisherFactory.publisher_for(type: :sales, precache: false)
    end

    def writeln(msg)
      write(msg, true)
    end

    def write(msg, line_break = false)
      response.stream.write(msg + (line_break ? '<br>' : '')) if stream?
    end

    def write_timing(msg)
      start = now
      write "#{msg}..."
      result = yield
      writeln "done in #{(now - start).round(2)} seconds"
      result
    end

    def json_html(object)
      "<pre>#{JSON.pretty_generate(object)}</pre>"
    end

    def integer?(input)
      input.to_i.to_s == input
    end

    def now
      Process.clock_gettime(Process::CLOCK_MONOTONIC)
    end
  end
end
