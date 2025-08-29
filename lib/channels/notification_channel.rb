class NotificationChannel
  def send(recipient, message)
    raise NotImplementedError, "Each channel must implement send method"
  end
end