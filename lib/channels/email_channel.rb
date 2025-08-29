require_relative 'notification_channel'

class EmailChannel < NotificationChannel
  def send(recipient, message)
    puts "EMAIL to #{recipient}: #{message}"
  end
  
  def send_welcome_email(recipient)
    puts "Sending welcome email to #{recipient}"
  end
  
  def send_password_reset_email(recipient)
    puts "Sending password reset email to #{recipient}"
  end
end