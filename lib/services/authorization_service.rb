class AuthorizationService
  ROLE_PERMISSIONS = {
    'admin' => {
      permissions: :all,  
      resource_access: :all  
    },
    'user' => {
      permissions: ['read'],
      resource_access: :owner_and_public  # Can access own resources and public ones
    },
  }.freeze

  def initialize(user, custom_role_permissions: {})
    @user = user
    @role_permissions = ROLE_PERMISSIONS.merge(custom_role_permissions)
  end

  def has_permission?(permission)
    role = get_user_role
    role_config = @role_permissions[role]
    
    return false unless role_config
    
    # Check if role has all permissions
    return true if role_config[:permissions] == :all
    
    # Check if specific permission is allowed
    Array(role_config[:permissions]).include?(permission)
  end

  def can_access_resource?(resource)
    role = get_user_role
    role_config = @role_permissions[role]
    
    return false unless role_config
    
    access_level = role_config[:resource_access]
    
    case access_level
    when :all
      true
    when :public_only
      resource[:public] == true
    else
      false
    end
  end

  def authorize!(permission)
    unless has_permission?(permission)
      raise "User #{@user.id} does not have permission: #{permission}"
    end
  end

  def authorize_resource!(resource)
    unless can_access_resource?(resource)
      raise "User #{@user.id} cannot access resource"
    end
  end

  # Query methods for easier understanding
  def admin?
    get_user_role == 'admin'
  end

  def regular_user?
    get_user_role == 'user'
  end


  # Get all permissions for current user (useful for UI)
  def user_permissions
    role = get_user_role
    role_config = @role_permissions[role]
    
    return [] unless role_config
    return ['all'] if role_config[:permissions] == :all
    
    Array(role_config[:permissions])
  end

  private

  def get_user_role
    @user&.role
  end

  def can_access_as_user?(resource)
    return true if resource[:public]
    return true if resource[:user_id] == @user.id
    false
  end
end