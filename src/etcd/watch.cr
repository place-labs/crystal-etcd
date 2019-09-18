require "tokenizer"

require "./utils"
require "./model/watch"

class Etcd::Watch
  include Utils
  private getter api : Etcd::Api

  def initialize(@api = Etcd::Api.new)
  end

  # Watches keys by prefix, passing events to a supplied block.
  # Exposes a synchronous interface to the watch session via `Etcd::Watcher`
  #
  # opts
  #  filters         filters filter the events at server side before it sends back to the watcher.                                           [WatchFilter]
  #  start_revision  start_revision is an optional revision to watch from (inclusive). No start_revision is "now".                           Int64
  #  progress_notify progress_notify is set so that the etcd server will periodically send a WatchResponse with no events to the new watcher
  #                  if there are no recent events. It is useful when clients wish to recover a disconnected watcher starting from
  #                  a recent known revision. The etcd server may decide how often it will send notifications based on current load.         Bool
  #  prev_kv         If prev_kv is set, created watcher gets the previous Kv before the event happens.                                       Bool
  def watch_prefix(prefix, **opts, &block : Array(Model::WatchEvent) -> Void)
    opts = opts.merge({range_end: prefix_range_end prefix})
    watch(prefix, **opts, &block)
  end

  # Watch a key in ETCD, returns a `Etcd::Watcher`
  # Exposes a synchronous interface to the watch session via `Etcd::Watcher`
  #
  # opts
  #  range_end       range_end is the end of the range [key, range_end) to watch.
  #  filters         filters filter the events at server side before it sends back to the watcher.                                           [WatchFilter]
  #  start_revision  start_revision is an optional revision to watch from (inclusive). No start_revision is "now".                           Int64
  #  progress_notify progress_notify is set so that the etcd server will periodically send a WatchResponse with no events to the new watcher
  #                  if there are no recent events. It is useful when clients wish to recover a disconnected watcher starting from
  #                  a recent known revision. The etcd server may decide how often it will send notifications based on current load.         Bool
  #  prev_kv         If prev_kv is set, created watcher gets the previous Kv before the event happens.                                       Bool
  def watch(key, **opts, &block : Array(Model::WatchEvent) -> Void) : Watcher
    opts = {
      key: key,
    }.merge(opts)

    options = {} of Symbol => String | Int64 | Bool | Array(Watcher::WatchFilter)
    {:key, :range_end, :prev_kv, :progress_notify, :start_revision, :filters}.each do |k|
      options[k] = opts[k] if opts.has_key?(k)
    end

    # Base64 key and range_end
    {:key, :range_end}.each do |k|
      option = options[k]?
      options[k] = Base64.strict_encode(option) if option && option.is_a?(String)
    end

    Watcher.new(key: key, api: api, options: options, &block)
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
    getter options : Hash(Symbol, String | Int64 | Bool | Array(WatchFilter))?
    private getter api : Etcd::Api
    private getter block : Proc(Array(Model::WatchEvent), Void)

    # Types for watch event filters
    enum WatchFilter
      NOPUT    # filter put events
      NODELETE # filter delete events
    end

    getter watching : Bool = false

    def initialize(
      @key,
      @options = nil,
      @api : Etcd::Api = Etcd::Api.new,
      &@block : Array(Model::WatchEvent) -> Void
    )
    end

    # Start the watcher
    def start
      raise Etcd::WatchError.new "Already watching #{@key}" if watching

      # Check out from the thread pool here
      post_body = {create_request: @options}
      api.post("/watch", body: post_body) do |stream|
        consume_io(stream.body_io, json_chunk_tokenizer) do |chunk|
          begin
            response = Model::WatchResponse.from_json(chunk)
            raise IO::EOFError.new if response.error

            # Pick off events
            events = response.try(&.result.try(&.events)) || [] of Model::WatchEvent

            # Ignore "created" message
            @block.call events unless response.created
          rescue e
            raise Etcd::WatchError.new e.message
          end
        end
      end
    end

    # Close the client and stop the watcher
    def stop
      # TODO: When adding pooling, return connection to the conn pool
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
        bytes_read = io.read(raw_data)
        break if bytes_read == 0 # IO was closed
        tokenizer.extract(raw_data[0, bytes_read]).each do |message|
          spawn { block.call String.new(message) }
        end
      end
    end
  end
end
