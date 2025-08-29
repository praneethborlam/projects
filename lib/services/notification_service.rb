require_relative '../channels/notification_channel'
require_relative '../channels/email_channel'
require_relative '../channels/sms_channel'

class NotificationService
  def initialize(user)
    @user = user
    @channels = {
      email: EmailChannel.new,
      sms: SmsChannel.new,
    }
  end
  
  def send_notification(type, message)
    channel = @channels[type]
    return puts "Unknown notification type: #{type}" unless channel
    
    recipient = get_recipient_for_channel(type)
    channel.send(recipient, message)
  end
  
  def send_welcome_email
    @channels[:email].send_welcome_email(@user.email)
  end
  
  def send_password_reset_email
    @channels[:email].send_password_reset_email(@user.email)
  end
  
  def broadcast_notification(message, channels: [:email])
    channels.each do |channel_type|
      send_notification(channel_type, message)
    end
  end
  
  private
  
  def get_recipient_for_channel(type)
    case type
    when :email
      @user.email
    when :sms
      @user.phone_number
    end
  end
  
  attr_reader :user, :channels
end
