module Etcd::Utils
  # Calculate range_end for given prefix
  def prefix_range_end(prefix)
    prefix.size > 0 ? prefix.sub(-1, prefix[-1] + 1) : ""
  end
end
