module OodReservations
  # Object used to communicate with a batch server to retrieve reservation
  # information for current user
  class Query
    # An exception raised when querying reservation information
    class Error < StandardError; end

    # Build a query object choosing the class of the object based on the
    # servers available in the cluster object
    # @param (see Query#initialize)
    # @return [Query,nil] query object used to query reservations from cluster
    def self.build(**kwargs)
      if Queries::TorqueMoab.match(**kwargs)
        Queries::TorqueMoab.new(**kwargs)
      else
        nil
      end
    end

    # @param cluster [OodCluster::Cluster] the cluster to query
    def initialize(cluster:, **_)
      @cluster = cluster
    end

    # Queries the batch server for a given reservation
    # @param id [#to_s] the id of the reservation
    # @return [Reservation] the requested reservation
    # @abstract This should be implemented by the adapter
    def reservation(id:)
      raise NotImplementedError
    end

    # Queries the batch server for a list of reservations
    # @return [Array<Reservation>] list of reservations
    # @abstract This should be implemented by the adapter
    def reservations
      raise NotImplementedError
    end
  end
end
