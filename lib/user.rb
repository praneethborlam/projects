require_relative  'services/authentication_service'
require_relative  'services/notification_service'

class User
  attr_accessor :id, :email, :password, :role, :phone_number, :avatar_url
  attr_accessor :auth_token, :token_expires_at, :last_login_at, :login_count
  
  def initialize(id:, email:, password:, role: 'user')
    @id = id
    @email = email
    @password = PasswordHasher.hash(password) # Hash password on creation
    @role = role
    @login_count = 0
    @phone_number = nil
    @avatar_url = nil
  end
  
  # authentication service
  def authenticate(password)
    authentication_service.authenticate(password)
  end
  
  def generate_auth_token
    authentication_service.generate_auth_token
  end
  
  def token_valid?
    authentication_service.token_valid?
  end
  
  def track_login
    authentication_service.track_login
  end
  
  # Notifications service
  def send_welcome_email
    notification_service.send_welcome_email
  end
  
  def send_password_reset_email
    notification_service.send_password_reset_email
  end
  
  def send_notification(type, message)
    notification_service.send_notification(type, message)
  end
  
  # Profile management - violates SRP
  def update_profile(name: nil, phone: nil, avatar: nil)
    @phone_number = phone if phone
    process_avatar(avatar) if avatar
    puts "Profile updated for user #{@id}"
  end
  
  def process_avatar(file_path)
    @avatar_url = "processed_#{file_path}"
    puts "Avatar processed and saved: #{@avatar_url}"
  end
  
  # Permissions and roles - violates SRP and OCP
  def has_permission?(permission)
    case @role
    when 'admin'
      true
    when 'moderator'
      ['read', 'write', 'moderate'].include?(permission)
    when 'user'
      ['read'].include?(permission)
    else
      false
    end
  end
  
  def can_access_resource?(resource)
    return true if admin?
    return true if resource[:user_id] == @id
    return true if resource[:public]
    false
  end
  
  # Analytics and tracking - violates SRP
  def generate_analytics_report
    {
      total_logins: @login_count,
      last_login: @last_login_at,
      activity_score: calculate_activity_score
    }
  end
  
  # Payment processing - violates SRP
  def process_payment(amount, payment_method)
    case payment_method
    when 'credit_card'
      puts "Processing $#{amount} via Credit Card"
    when 'paypal'
      puts "Processing $#{amount} via PayPal"
    else
      puts "Unknown payment method: #{payment_method}"
    end
  end
  
  def create_subscription(plan)
    puts "Creating #{plan} subscription for user #{@id}"
    send_notification(:email, "Subscription activated for #{plan}")
  end
  
  private
  
  def authentication_service
    @authentication_service ||= AuthenticationService.new(self)
  end
  
  def notification_service
    @notification_service ||= NotificationService.new(self)
  end
  
  def calculate_activity_score
    (@login_count * 0.5).round(2)
  end
  
  def admin?
    @role == 'admin'
  end
end

# Example usage
if __FILE__ == $0
  user = User.new(id: 1, email: "john@example.com", password: "password123")
  user.phone_number = "123-456-7890"
  
  puts "=== Notification Service Test ==="
  user.send_welcome_email
  user.send_notification(:email, "Hello via email!")
  user.send_notification(:sms, "Hello via SMS!")
  user.send_notification(:push, "Hello via push!")
  
  # Test broadcast
  puts "\n=== Broadcast Test ==="
  user.send_notification(:email, "This will be broadcast")
end