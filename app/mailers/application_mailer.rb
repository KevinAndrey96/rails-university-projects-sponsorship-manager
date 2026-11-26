class ApplicationMailer < ActionMailer::Base
  default from: -> { ENV.fetch("MAILER_FROM", "Patrocinios Universitarios <no-reply@example.com>") }
  layout "mailer"
end
