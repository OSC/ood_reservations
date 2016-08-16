require 'ood_reservations/version'
require 'ood_reservations/query'
require 'ood_reservations/reservation'

# The main namespace for {OodReservations}
module OodReservations
  # A namespace to hold all subclasses of {Query}
  module Queries
    require 'ood_reservations/queries/torque_moab'
  end
end
