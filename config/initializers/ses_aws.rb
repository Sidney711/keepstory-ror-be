require 'aws-sdk-ses'

class AwsSesDelivery
  def initialize(options = {})
    @client = Aws::SES::Client.new(
      region: options[:region],
      credentials: options[:credentials]
    )
  end

  def deliver!(mail)
    @client.send_email(
      source: mail.from.first,
      destination: { to_addresses: mail.to },
      message: {
        subject: { data: mail.subject },
        body: { text: { data: mail.body.decoded } }
      }
    )
  end
end

ActionMailer::Base.add_delivery_method :aws_ses, AwsSesDelivery,
                                       region: 'eu-central-1',
                                       credentials: Aws::Credentials.new(Rails.application.credentials[:aws_access_key_id],
                                                                         Rails.application.credentials[:aws_secret_access_key])