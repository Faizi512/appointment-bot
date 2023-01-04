class UserMailer < ApplicationMailer
    # Subject can be set in your I18n file at config/locales/en.yml
    # with the following lookup:
    #
    #   en.client_mailer.sendMail.subject
    #
    # default from: "faizan.haider@aldaimsolutions.com"

    def issue_in_script
        mail(to: ENV["MAILER_ADDRESS"], subject: "Issue detected in script")
        # mail(to: "noman.saleem@aldaimsolutions.com", subject: "Issue detected in script")
        # mail(to: "faizan.haider@aldaimsolutions.com", subject: "Issue detected in script")
    end

    def completion_alert
        mail(to: ENV["MAILER_ADDRESS"], subject: "Script completed!")
    end
end
