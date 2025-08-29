require 'digest'

class User
  attr_accessor :id, :email, :password, :role, :phone_number, :avatar_url
  attr_accessor :auth_token, :token_expires_at, :last_login_at, :login_count
  
  def initialize(id:, email:, password:, role: 'user')
    @id = id
    @email = email
    @password = password
    @role = role
    @login_count = 0
    @phone_number = nil
    @avatar_url = nil
  end
  
  # Authentication concerns - violates SRP
  def authenticate(password)
    hash_password(password) == @password
  end
  
  def generate_auth_token
    @auth_token = generate_random_token
    @token_expires_at = Time.now + (24 * 60 * 60) # 24 hours
  end
  
  def token_valid?
    @auth_token && @token_expires_at > Time.now
  end
  
  def hash_password(password)
    Digest::SHA256.hexdigest(password + 'salt')
  end
  
  # Email/Notification concerns - violates SRP
  def send_welcome_email
    puts "Sending welcome email to #{@email}"
  end
  
  def send_password_reset_email
    puts "Sending password reset email to #{@email}"
  end
  
  def send_notification(type, message)
    case type
    when :email
      puts "EMAIL to #{@email}: #{message}"
    when :sms
      puts "SMS to #{@phone_number}: #{message}"
    when :push
      puts "PUSH notification: #{message}"
    else
      puts "Unknown notification type: #{type}"
    end
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
  def track_login
    @last_login_at = Time.now
    @login_count += 1
    puts "Login tracked for user #{@id}. Total logins: #{@login_count}"
  end
  
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
  
  def generate_random_token
    (0...32).map { ('a'..'z').to_a[rand(26)] }.join
  end
  
  def calculate_activity_score
    (@login_count * 0.5).round(2)
  end
  
  def admin?
    @role == 'admin'
  end
end