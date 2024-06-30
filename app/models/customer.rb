class Customer < ApplicationRecord
    validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }

    attribute :is_appointment_booked, :boolean, default: false

    has_many :family_members, dependent: :destroy
end
