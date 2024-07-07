class BookAppointmentJob < ApplicationJob
  queue_as :default

  def perform(customer_ids)
    customers = Customer.where(id: customer_ids)
    service = AppointmentBookingService.new(customers)
    if service.call
      flash[:notice] = "#{customers.count} appointments booking service called!"
    else
      error_messages = service.errors.map { |error| "Appointment #{error[:appointment_id]}: #{error[:error]}" }.join(", ")
      flash[:error] = "Booking failed for some appointments: #{error_messages}"
    end
  end
end
