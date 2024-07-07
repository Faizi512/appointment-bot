# app/admin/customers.rb
ActiveAdmin.register Customer do
  permit_params :appointment_type, :is_family, :family_id, :number_of_appointments, :centre_city,
                :appointment_category, :phone_number, :verification_code, :appointment_date,
                :appointment_time, :visa_type, :first_name, :last_name, :birth_date,
                :customer_phone_number, :nationality, :passport_type, :passport_number,
                :passport_issue_date, :passport_expiry_date, :passport_issue_place,
                :is_sms, :is_prime_time_service, :is_form_filling, :is_photocopy_b_w,
                :is_photograph, :is_premium_lounge, :email, :is_appointment_booked

  index do
    selectable_column
    id_column
    column :first_name
    column :last_name
    column :email
    column :appointment_date
    column :appointment_time
    column :visa_type
    column :phone_number
    column :is_appointment_booked
    actions
  end

  filter :first_name
  filter :last_name
  filter :email
  filter :appointment_date
  filter :visa_type
  filter :centre_city
  filter :is_appointment_booked

  form do |f|
    f.inputs 'Customer Details' do
      f.input :first_name
      f.input :last_name
      f.input :email
      f.input :appointment_type
      f.input :is_family
      f.input :family_id
      f.input :number_of_appointments
      f.input :centre_city
      f.input :appointment_category
      f.input :phone_number
      f.input :verification_code
      f.input :appointment_date, as: :datepicker
      f.input :appointment_time, as: :time_picker
      f.input :visa_type
      f.input :birth_date, as: :datepicker
      f.input :customer_phone_number
      f.input :nationality
      f.input :passport_type
      f.input :passport_number
      f.input :passport_issue_date, as: :datepicker
      f.input :passport_expiry_date, as: :datepicker
      f.input :passport_issue_place
      f.input :is_sms
      f.input :is_prime_time_service
      f.input :is_form_filling
      f.input :is_photocopy_b_w
      f.input :is_photograph
      f.input :is_premium_lounge
      f.input :is_appointment_booked, as: :boolean
    end
    f.actions
  end

  action_item :get_otp, only: :show do
    link_to 'Enter OTP', get_otp_admin_customer_path(customer)
  end

  member_action :get_otp, method: [:get, :post] do
    @customer = Customer.find(params[:id])
    if request.post?
      if @customer.update(verification_code: params[:customer][:verification_code])
        redirect_to admin_customer_path(@customer), notice: 'OTP saved successfully!'
      else
        flash[:error] = 'Failed to save OTP!'
      end
    end
  end

  sidebar "OTP", only: :show do
    render 'admin/customers/otp_form', customer: customer
  end



  batch_action :book_appointment do |selection|
    # Use the service to book appointments
    job = BookAppointmentJob.perform_later(selection.map(&:to_s))
    redirect_to admin_customers_path, notice: "Appointment booking job has been enqueued for #{selection.size} customers!"
  end
end