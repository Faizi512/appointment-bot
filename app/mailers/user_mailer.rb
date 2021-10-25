class UserMailer < ApplicationMailer
    # Subject can be set in your I18n file at config/locales/en.yml
    # with the following lookup:
    #
    #   en.client_mailer.sendMail.subject
    #
    default from: "faizan.haider@aldaimsolutions.com"

    def issue_in_script
        # mail(to: ENV["Notify_Email"], subject: "Issue detected in script")
        # mail(to: "noman.saleem@aldaimsolutions.com", subject: "Issue detected in script")
        mail(to: "faizan.haider@aldaimsolutions.com", subject: "Issue detected in script")
    end
end
