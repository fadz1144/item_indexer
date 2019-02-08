class ProductsController < ApplicationController
  include ActionController::Live

  # rubocop:disable Metrics/AbcSize
  def show
    # for preview, we always want a fresh collection cache lookup, whether during adhoc fetch or after precaching
    clear_cache
    write_timing('initializing publisher', &method(:publisher))
    serialized = write_timing("serializing product #{product_id}") { publisher.preview(product_id) }
    writeln(json_html(serialized))
    if stream?
      response.stream.close
    else
      render json: serialized
    end
  end
  # rubocop:enable Metrics/AbcSize

  private

  def product_id
    input = params[:id]
    raise "'#{input}' does not seem to be a valid product id" unless input.present? && integer?(input)
    input.to_i
  end

  def stream?
    Rails.env.development? || params[:stream] == 'true'
  end

  def precache?
    params[:precache] == 'true'
  end

  def publisher
    @publisher ||= Indexer::IndexPublisherFactory.publisher_for(type: :product, platform: :solr, precache: precache?)
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

  def clear_cache
    # clear concept collection cache, which functions the same whether or not it's optionally precached
    config = Rails.configuration
    config.indexer_concept_collection_cache.clear if config.respond_to? :indexer_concept_collection_cache
  end
end
