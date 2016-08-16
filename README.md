# OodReservations

Library that queries a cluster for active reservations of the current user.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ood_reservations'
```

And then execute:

```sh
$ bundle
```

Or install it yourself as:

```sh
$ gem install ood_reservations
```

## Usage

Given an `OodCluster::Cluster` object you can build a query object that can
query all reservations on the cluster or a specified reservation id:

```ruby
# Create a query object (creates a TorqueMoab query object)
query = OodReservations::Query.build(cluster: my_torque_moab_cluster)
#=> #<OodReservations::Queries::TorqueMoab>

# Create a query object (this cluster has no scheduler to query)
query = OodReservations::Query.build(cluster: my_cluster_w_no_scheduler)
#=> nil
```

To query reservations:

```ruby
# Query all reservations you have on that cluster
rsvs = query.reservations
#=>
#[
#  #<OodReservations::Reservation>,
#  #<OodReservations::Reservation>
#]

# Query for unique reservation id
my_rsv = query.reservation(id: 'my_rsv.23874')
#=> #<OodReservations::Reservation>
```

An `OodReservations::Reservation` object has information about the given
reservation:

```ruby
# Has this reservation started yet?
my_rsv.has_started?
#=> true

# Has this reservation ended yet?
my_rsv.has_ended?
#=> false

# Get list of users/groups that have access to this reservation
my_rsv.users.map(&:name)
#=> ["bob", "sally", "me"]

my_rsv.groups.map(&:name)
#=> ["group1", "group2"]

# List all nodes on reservation
my_rsv.nodes.map(&:id)
#=> ["n0001", "n0002"]

# List nodes that have no jobs running on them
my_rsv.free_nodes.map(&:id)
#=> ["n0002"]
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/ood_reservations/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
