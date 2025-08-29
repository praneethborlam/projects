require_relative 'notification_channel'

class SmsChannel < NotificationChannel
  def send(recipient, message)
    return puts "SMS failed: No phone number" unless recipient
    puts "SMS to #{recipient}: #{message}"
  end
end