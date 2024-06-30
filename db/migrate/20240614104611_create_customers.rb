class CreateCustomers < ActiveRecord::Migration[5.1]
  def change
    create_table :customers do |t|
      t.string :appointment_type
      t.boolean :is_family
      t.integer :family_id
      t.integer :number_of_appointments
      t.string :centre_city
      t.string :appointment_category
      t.string :phone_number
      t.string :verification_code
      t.date :appointment_date
      t.time :appointment_time
      t.string :visa_type
      t.string :first_name
      t.string :last_name
      t.date :birth_date
      t.string :customer_phone_number
      t.string :nationality
      t.string :passport_type
      t.string :passport_number
      t.date :passport_issue_date
      t.date :passport_expiry_date
      t.string :passport_issue_place
      t.boolean :is_sms
      t.boolean :is_prime_time_service
      t.boolean :is_form_filling
      t.boolean :is_photocopy_b_w
      t.boolean :is_photograph
      t.boolean :is_premium_lounge

      t.timestamps
    end
  end
end
