require_relative  'services/authentication_service'
require_relative  'services/notification_service'
require_relative  'services/authorization_service'
require_relative  'services/payment_service'
require_relative  'services/profile_service'
require_relative  'services/analytics_service'

class User
  attr_accessor :id, :email, :password, :role, :phone_number, :avatar_url
  attr_accessor :auth_token, :token_expires_at, :last_login_at, :login_count, :created_at
  
  def initialize(id:, email:, password:, role: 'user')
    @id = id
    @email = email
    @password = PasswordHasher.hash(password)
    @role = role
    @login_count = 0
    @created_at = Time.now
  end
  
  # Authentication methods - delegated
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
    analytics_service.track_event('login')
  end
  
  # Notification methods - delegated
  def send_welcome_email
    notification_service.send_welcome_email
  end
  
  def send_password_reset_email
    notification_service.send_password_reset_email
  end
  
  def send_notification(type, message)
    notification_service.send_notification(type, message)
  end
  
  # Authorization methods - delegated
  def has_permission?(permission)
    authorization_service.has_permission?(permission)
  end
  
  def can_access_resource?(resource)
    authorization_service.can_access_resource?(resource)
  end
  
  # Profile methods - delegated
  def update_profile(name: nil, phone: nil, avatar: nil)
    profile_service.update_profile(name: name, phone: phone, avatar: avatar)
  end
  
  # Payment methods - delegated
  def process_payment(amount, payment_method)
    payment_service.process_payment(amount, payment_method)
  end
  
  def create_subscription(plan)
    payment_service.create_subscription(plan)
  end
  
  # Analytics methods - delegated
  def generate_analytics_report
    analytics_service.generate_analytics_report
  end
  
  # Simple methods that can stay in the model
  def admin?
    @role == 'admin'
  end
  
  def full_name
    @email.split('@').first.capitalize # Simple implementation
  end
  
  private
  
  def authentication_service
    @authentication_service ||= AuthenticationService.new(self)
  end
  
  def notification_service
    @notification_service ||= NotificationService.new(self)
  end
  
  def authorization_service
    @authorization_service ||= AuthorizationService.new(self)
  end
  
  def profile_service
    @profile_service ||= ProfileService.new(self)
  end
  
  def payment_service
    @payment_service ||= PaymentService.new(self, notification_service: notification_service)
  end
  
  def analytics_service
    @analytics_service ||= AnalyticsService.new(self)
  end
end

# Example usage
if __FILE__ == $0
  user = User.new(id: 1, email: "john@example.com", password: "password123")
  user.phone_number = "123-456-7890"
  
  # Test all services working together
  puts "\n Authentication:"
  puts "Valid login: #{user.authenticate('password123')}"
  user.track_login
  
  puts "\n Profile Management:"
  user.update_profile(phone: "555-1234", avatar: "new_avatar.jpg")
  
  puts "\n Notifications:"
  user.send_welcome_email
  user.send_notification(:sms, "Profile updated!")
  
  puts "\n Authorization:"
  puts "Can read: #{user.has_permission?('read')}"
  puts "Can write: #{user.has_permission?('write')}"
  
  puts "\n Payments:"
  result = user.process_payment(99.99, 'credit_card')
  user.create_subscription('premium')
  
  puts "\n Analytics:"
  puts user.generate_analytics_report
end
