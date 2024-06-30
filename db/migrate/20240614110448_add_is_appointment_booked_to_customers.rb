class AddIsAppointmentBookedToCustomers < ActiveRecord::Migration[5.1]
  def change
    add_column :customers, :is_appointment_booked, :boolean
  end
end
