require 'ood_support'

module OodReservations
  # Object that describes a generic scheduler reservation
  class Reservation
    include Comparable

    # The id of the reservation
    # @return [String] reservation id
    attr_reader :id

    # The time when this reservation begins
    # @return [Time] reservation start time
    attr_reader :start_time

    # The time when this reservation ends
    # @return [Time] reservation end time
    attr_reader :end_time

    # The list of users who have access to this reservation
    # @return [Array<OodSupport::User>] list of users with reservation access
    attr_reader :users

    # The list of groups who have access to this reservation
    # @return [Array<OodSupport::Group>] list of groups with reservation access
    attr_reader :groups

    # The list of nodes reserved under this reservation
    # @return [Array<Node>] reserved nodes
    attr_reader :nodes

    # @param id [#to_s] reservation id
    # @param start_time [#to_i] reservation start time
    # @param end_time [#to_i] reservation end time
    # @param users [Array<#to_s>] list of users w/ reservation access
    # @param groups [Array<#to_s>] list of groups w/ reservation access
    # @param nodes [Array<#to_h>] reserved nodes
    def initialize(id:, start_time:, end_time:, users:, groups:, nodes:)
      @id         = id.to_s
      @start_time = Time.at(start_time.to_i)
      @end_time   = Time.at(end_time.to_i)
      @nodes      = nodes.map  {|n| Node.new(n.to_h)}

      # Be careful, groups or users can be specified here but not exist anymore
      @users      = users.map  {|u| OodSupport::User.new(u.to_s) rescue nil}.reject(&:nil?)
      @groups     = groups.map {|g| OodSupport::Group.new(g.to_s) rescue nil}.reject(&:nil?)
    end

    # Whether this reservation has started yet?
    # @return [Boolean] whether reservation has started
    def has_started?
      Time.now >= start_time
    end

    # Whether this reservation has ended yet?
    # @return [Boolean] whether reservation has ended
    def has_ended?
      Time.now >= end_time
    end

    # The list of nodes that are completely free to use
    # @return [Array<Node>] free nodes
    def free_nodes
      nodes.select(&:is_free?)
    end

    # Convert object to string
    # @return [String] the string describing this object
    def to_s
      id
    end

    # The comparison operator for sorting values
    # @param other [#to_s] object to compare against
    # @return [Boolean] how objects compare
    def <=>(other)
      to_s <=> other.to_s
    end

    # Check whether objects are identical to each other
    # @param other [#to_h] object to compare against
    # @return [Boolean] whether objects are identical
    def eql?(other)
      self.class == other.class && self == other
    end

    # Generate a hash value for this object
    # @return [Fixnum] hash value of object
    def hash
      [self.class, to_s].hash
    end

    # Object that describes a reserved node on a generic batch server
    # FIXME: This should be generalized in some other gem
    class Node
      include Comparable

      # The id of the node
      # @return [String] id of node
      attr_reader :id

      # The number of cores on this node
      # @return [Fixnum] number of cores
      attr_reader :ppn

      # The number of cores used on this node
      # @return [Fixnum] number of cores used
      attr_reader :ppn_used

      # A list of properties describing this node
      # @return [Array<Symbol>] list of properties
      attr_reader :props

      # A list of jobs running on this node
      # @return [Array<String>] list of jobs running on node
      attr_reader :jobs

      # @param id [#to_s] id of node
      # @param ppn [#to_i] number of cores
      # @param ppn_used [#to_i] number of used cores
      # @param props [Array<#to_sym>] list of properties of node
      # @param jobs [Array<#to_s>] list of jobs on node
      def initialize(id:, ppn:, ppn_used:, props:, jobs:)
        @id       = id.to_s
        @ppn      = ppn.to_i
        @ppn_used = ppn_used.to_i
        @props    = props.map(&:to_sym)
        @jobs     = jobs.map(&:to_s)
      end

      # Is this node free to be used?
      # @return [Boolean] free to use?
      def is_free?
        ppn_used == 0
      end

      # Convert object to string
      # @return [String] the string describing this object
      def to_s
        id
      end

      # The comparison operator for sorting values
      # @param other [#to_s] object to compare against
      # @return [Boolean] how objects compare
      def <=>(other)
        to_s <=> other.to_s
      end

      # Check whether objects are identical to each other
      # @param other [#to_h] object to compare against
      # @return [Boolean] whether objects are identical
      def eql?(other)
        self.class == other.class && self == other
      end

      # Generate a hash value for this object
      # @return [Fixnum] hash value of object
      def hash
        [self.class, to_s].hash
      end
    end
  end
end
