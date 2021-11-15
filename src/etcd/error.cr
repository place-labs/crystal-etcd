require "http"

module Etcd
  class Error < ::Exception
    getter message
  end

  class ApiError < Error
    def initialize(@status_code : Int32, message = "", cause = nil)
      super(message, cause: cause)
    end

    def self.from_response(response)
      new(response.status_code, response.body)
    end
  end

  class WatchError < Error
  end
end
