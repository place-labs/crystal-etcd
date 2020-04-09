require "tokenizer"
require "simple_retry"

require "./utils"
require "./model/watch"

class Etcd::Watch
  include Utils

  # Types for watch event filters
  enum Filter
    NOPUT    # filter put events
    NODELETE # filter delete events
  end

  private getter client : Etcd::Client

  def initialize(@client = Etcd::Client.new)
  end

  # Watches keys by prefix, passing events to a supplied block.
  # Exposes a synchronous interface to the watch session via `Etcd::Watcher`
  #
  # opts
  #  filters         filters filter the events at server side before it sends back to the watcher.                                           [Watch::Filter]
  #  start_revision  start_revision is an optional revision to watch from (inclusive). No start_revision is "now".                           Int64
  #  progress_notify progress_notify is set so that the etcd server will periodically send a WatchResponse with no events to the new watcher
  #                  if there are no recent events. It is useful when clients wish to recover a disconnected watcher starting from
  #                  a recent known revision. The etcd server may decide how often it will send notifications based on current load.         Bool
  #  prev_kv         If prev_kv is set, created watcher gets the previous Kv before the event happens.                                       Bool
  def watch_prefix(prefix, **opts, &block : Array(Model::WatchEvent) -> Void)
    encoded_prefix = Base64.strict_encode(prefix)
    opts = opts.merge({range_end: prefix_range_end(encoded_prefix), base64_keys: false})
    watch(encoded_prefix, **opts, &block)
  end

  # Watch a key in ETCD, returns a `Etcd::Watcher`
  # Exposes a synchronous interface to the watch session via `Etcd::Watcher`
  #
  # opts
  #  range_end       range_end is the end of the range [key, range_end) to watch.
  #  filters         filter the events at server side before it sends back to the watcher.                                           [Watch::Filter]
  #  start_revision  start_revision is an optional revision to watch from (inclusive). No start_revision is "now".                           Int64
  #  progress_notify progress_notify is set so that the etcd server will periodically send a WatchResponse with no events to the new watcher
  #                  if there are no recent events. It is useful when clients wish to recover a disconnected watcher starting from
  #                  a recent known revision. The etcd server may decide how often it will send notifications based on current load.         Bool
  #  prev_kv         If prev_kv is set, created watcher gets the previous Kv before the event happens.                                       Bool
  def watch(
    key,
    range_end : String? = nil,
    filters : Array(Watch::Filter)? = nil,
    start_revision : Int64? = nil,
    progress_notify : Bool? = nil,
    base64_keys : Bool = true,
    &block : Array(Model::WatchEvent) -> Void
  ) : Watcher
    if base64_keys
      key = Base64.strict_encode(key)
      range_end = range_end.try &->Base64.strict_encode(String)
    end

    Watcher.new(
      api: client.spawn_api,
      key: key,
      range_end: range_end,
      filters: filters,
      start_revision: start_revision,
      progress_notify: progress_notify,
      &block
    )
  end

  # Wrapper for a watch session with etcd.
  #
  # ```
  # client = Etcd::Client.new
  # watcher = client.watch(key: "hello") do |e|
  #   # This block will be called upon each etcd event
  #   puts e
  # end
  #
  # spawn { watcher.start }
  # ```
  class Watcher
    getter key : String
    private getter api : Etcd::Api
    private getter block : Proc(Array(Model::WatchEvent), Void)
    private getter range_end : String?
    private getter filters : Array(Watch::Filter)?
    private getter start_revision : Int64?
    private getter progress_notify : Bool?

    getter watching : Bool = false

    def initialize(
      @key,
      @api : Etcd::Api = Etcd::Api.new,
      @range_end = nil,
      @filters = nil,
      @start_revision = nil,
      @progress_notify = nil,
      &@block : Array(Model::WatchEvent) -> Void
    )
    end

    # Start the watcher
    def start
      raise Etcd::WatchError.new "Already watching #{@key}" if watching
      # Check out from the thread pool here
      post_body = {
        create_request: {
          :key             => key,
          :range_end       => range_end,
          :filters         => filters,
          :start_revision  => start_revision,
          :progress_notify => progress_notify,
        }.compact,
      }
      @watching = true
      SimpleRetry.try_to(
        base_interval: 50.milliseconds,
        max_interval: 10.seconds,
        randomise: 100.milliseconds
      ) do
        if watching
          begin
            api.post("/watch", post_body) do |stream|
              consume_io(stream.body_io, json_chunk_tokenizer) do |chunk|
                begin
                  response = Model::WatchResponse.from_json(chunk)
                  raise IO::EOFError.new if response.error

                  # Ignore "created" message, and empty events
                  @block.call response.result.events unless response.created || response.result.events.empty?
                rescue e
                  # Ignore close events
                  raise Etcd::WatchError.new e.message unless e.message.try &.includes?("<EOF>")
                end
              end
            end
          rescue e
            # Ignore timeouts
            unless e.is_a?(IO::Error) && e.message.try(&.includes? "Closed stream")
              Log.error { "Unhandled exception in Etcd::Watcher: #{e.inspect_with_backtrace}" }
            end

            raise e
          end
        end
      end
    end

    # Close the client and stop the watcher
    def stop
      # TODO: When adding pooling, return connection to the conn pool
      @watching = false
      api.connection.close
    end

    # Partitions IO into JSON chunks (only objects!)
    protected def json_chunk_tokenizer
      Tokenizer.new do |io|
        length, unpaired = 0, 0
        loop do
          char = io.read_char
          break unless char
          unpaired += 1 if char == '{'
          unpaired -= 1 if char == '}'
          length += 1
          break if unpaired == 0
        end
        unpaired == 0 && length > 0 ? length : -1
      end
    end

    # Pulls tokens off stream IO, and calls block with tokenized IO
    # io          Streaming IO                                      IO
    # tokenizer   Tokenizer class with which the stream is parsed   Tokenizer
    # block       Block that takes a string                         Block
    protected def consume_io(io, tokenizer, &block : String -> Void)
      raw_data = Bytes.new(4096)
      while !io.closed?
        begin
          bytes_read = io.read(raw_data)
          break if bytes_read == 0 # IO was closed
          tokenizer.extract(raw_data[0, bytes_read]).each do |message|
            spawn { block.call String.new(message) }
          end
        rescue e : Socket::Error
          break
        end
      end
    end
  end
end
