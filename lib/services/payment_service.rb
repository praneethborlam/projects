class PaymentProcessor
  def process_payment(customer_info, amount)
    raise NotImplementedError, "Each processor must implement process_payment"
  end
end

class CreditCardProcessor < PaymentProcessor
  def process_payment(customer_info, amount)
    puts "Processing $#{amount} via Credit Card for customer #{customer_info}"
    { success: true, transaction_id: "cc_#{rand(1000)}" }
  end
end

class PaypalProcessor < PaymentProcessor
  def process_payment(customer_info, amount)
    puts "Processing $#{amount} via PayPal for customer #{customer_info}"
    { success: true, transaction_id: "pp_#{rand(1000)}" }
  end
end

# NEW: Payment Service - Single Responsibility: Handle payments
class PaymentService
  PROCESSORS = {
    'credit_card' => CreditCardProcessor.new,
    'paypal' => PaypalProcessor.new
  }.freeze
  
  def initialize(user, notification_service: nil)
    @user = user
    @notification_service = notification_service
  end
  
  def process_payment(amount, payment_method)
    processor = PROCESSORS[payment_method]
    raise "Unknown payment method: #{payment_method}" unless processor
    
    result = processor.process_payment(@user.email, amount)
    
    if result[:success]
      puts "Payment recorded: #{result[:transaction_id]}"
    end
    
    result
  end
  
  def create_subscription(plan)
    puts "Creating #{plan} subscription for user #{@user.id}"
    
    # Notify user if notification service is available
    if @notification_service
      @notification_service.send_notification(:email, "Subscription activated for #{plan}")
    end
    
    { plan: plan, user_id: @user.id, status: 'active' }
  end
  
  private
  
  attr_reader :user, :notification_service
end
