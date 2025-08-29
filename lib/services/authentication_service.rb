require 'digest'

# Single Responsibility: Handle only password hashing
class PasswordHasher
  def self.hash(password)
    Digest::SHA256.hexdigest(password + 'salt')
  end
  
  def self.verify(password, hashed_password)
    hash(password) == hashed_password
  end
end

# Single Responsibility: Handle only token generation
class TokenGenerator
  def self.generate
    (0...32).map { ('a'..'z').to_a[rand(26)] }.join
  end
end

# Single Responsibility: Handle only user authentication
class AuthenticationService
  def initialize(user, password_hasher: PasswordHasher, token_generator: TokenGenerator)
    @user = user
    @password_hasher = password_hasher
    @token_generator = token_generator
  end
  
  def authenticate(password)
    @password_hasher.verify(password, @user.password)
  end
  
  def generate_auth_token
    @user.auth_token = @token_generator.generate
    @user.token_expires_at = Time.now + (24 * 60 * 60) # 24 hours
  end
  
  def token_valid?
    @user.auth_token && @user.token_expires_at > Time.now
  end
  
  def track_login
    @user.last_login_at = Time.now
    @user.login_count += 1
    puts "Login tracked for user #{@user.id}. Total logins: #{@user.login_count}"
  end
  
  private
  
  attr_reader :user, :password_hasher, :token_generator
end