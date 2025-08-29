class SimpleImageProcessor
  def self.process(file_path, width, height)
    # Simulated image processing
    "processed_#{width}x#{height}_#{file_path}"
  end
end

# NEW: Profile Service - Single Responsibility: Handle user profile management
class ProfileService
  def initialize(user, image_processor: SimpleImageProcessor)
    @user = user
    @image_processor = image_processor
  end
  
  def update_profile(name: nil, phone: nil, avatar: nil)
    @user.phone_number = phone if phone
    process_avatar(avatar) if avatar
    puts "Profile updated for user #{@user.id}"
  end
  
  def process_avatar(file_path)
    processed_avatar = @image_processor.process(file_path, 200, 200)
    @user.avatar_url = processed_avatar
    puts "Avatar processed and saved: #{@user.avatar_url}"
  end
  
  private
  
  attr_reader :user, :image_processor
end