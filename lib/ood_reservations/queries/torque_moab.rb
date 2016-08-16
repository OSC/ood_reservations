module OodReservations
  module Queries
    # Object used for querying reservations on a batch server that uses Torque
    # for the resource manager and Moab for the scheduler
    class TorqueMoab < Query
      # Valid reservation subtypes, other subtypes will be ignored
      # NB: used to filter out running jobs that appear in reservation list
      VALID_SUBTYPES = %i( StandingReservation )

      # Whether this cluster matches this Query adapter for use
      # @param cluster [OodCluster::Cluster] the cluster to query
      # @return [Boolean] whether this cluster can be used by this query object
      def self.match(cluster:, **_)
        cluster.resource_mgr_server? &&
          cluster.scheduler_server? &&
          cluster.resource_mgr_server.respond_to?(:pbs) &&
          cluster.scheduler_server.respond_to?(:moab)
      end

      # Queries the Moab scheduler for a given reservation and builds
      # reservation object with help of Torque resource manager
      # @param (see Query#reservation)
      # @return [Reservation] the requested reservation
      # @see Query#reservation
      def reservation(id:)
        xml = moab(@cluster).call("mrsvctl", "-q", "#{id}")
        parse_rsv_xml @cluster, xml.xpath(rsv_xpath)
      rescue OodCluster::Servers::Moab::Scheduler::Error => e
        raise Error, e.message
      end

      # Queries the Moab scheduler for a list of reservations and builds
      # reservation objects with help of Torque resource manager
      # @param (see Query#reservations)
      # @return [Array<Reservation>] list of reservations
      # @see Query#reservations
      def reservations
        xml = moab(@cluster).call("mrsvctl", "-q", "ALL")
        xml.xpath(rsv_xpath).map {|r_xml| parse_rsv_xml @cluster, r_xml}
      rescue OodCluster::Servers::Moab::Scheduler::Error
        raise Error, e.message
      end

      private
        # PBS object used to communicate with Torque batch server
        def pbs(cluster)
          cluster.resource_mgr_server.pbs
        end

        # Moab object used to communicate with Moab scheduler server
        def moab(cluster)
          cluster.scheduler_server.moab
        end

        # XPath used to find reservations from xml
        def rsv_xpath
          %(//rsv[#{VALID_SUBTYPES.map{|s| "@SubType='#{s}'"}.join(" or ")}])
        end

        # Parse the xml output
        def parse_rsv_xml(cluster, xml)
          h = {
            id: xml.xpath("@Name").to_s,
            start_time: xml.xpath("@starttime").to_s,
            end_time: xml.xpath("@endtime").to_s,
            users: xml.xpath("ACL[@type='USER']/@name").map(&:value),
            groups: xml.xpath("ACL[@type='GROUP']/@name").map(&:value),
            nodes: xml.xpath("@AllocNodeList").to_s.split(",")
          }

          # Map the nodes to hashes that describe the nodes
          h[:nodes].map! do |n|
            nh = pbs(cluster).get_node(n).fetch(n, {})
            jobs = []
            # "9,11/7191718.oak-batch.osc.edu,0-3/7194494.oak-batch.osc.edu,4-8,10/7196466.oak-batch.osc.edu"
            nh.fetch(:jobs, "").scan %r{([\d,-]+)/([^,]+)} do |rng, jid|
              # Count cores used in range expansion
              cnt = rng.split(",").inject(0) do |sum, x|
                sum + (x =~ /^(\d+)-(\d+)$/ ? ($2.to_i - $1.to_i) : 0) + 1
              end
              jobs << [jid, cnt]  # ["7196466.oak-batch.osc.edu", 6]
            end
            {
              id: n,
              ppn: nh.fetch(:np, "0"),
              ppn_used: jobs.inject(0) {|sum, x| sum + x[1]},
              props: nh.fetch(:properties, "").split(","),
              jobs: jobs.map {|x| x[0]}
            }
          end

          Reservation.new(h)
        end
    end
  end
end
