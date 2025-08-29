class AnalyticsService
  def initialize(user)
    @user = user
  end
  
  def generate_analytics_report
    {
      total_logins: @user.login_count,
      last_login: @user.last_login_at,
      activity_score: calculate_activity_score,
      user_id: @user.id,
      account_created: @user.created_at
    }
  end
  
  def track_event(event_name, properties = {})
    puts "Analytics: User #{@user.id} - #{event_name} with #{properties}"
  end
  
  private
  
  def calculate_activity_score
    (@user.login_count * 0.5).round(2)
  end
  
  attr_reader :user
end
