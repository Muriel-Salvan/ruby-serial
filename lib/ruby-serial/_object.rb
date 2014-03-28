class Object

  # Get the list of instance variables that are meant to be serialized
  #
  # Result::
  # * <em>map<String,Object></em>: Set of instance variables, per name
  def get_instance_vars_to_rubyserial
    # Compute the list of attributes to serialize
    instance_var_names = []
    klass = self.class
    if klass.rubyserial_only_lst != nil
      if klass.dont_rubyserial_lst != nil
        instance_var_names = klass.rubyserial_only_lst - klass.dont_rubyserial_lst
      else
        instance_var_names = klass.rubyserial_only_lst
      end
    elsif klass.dont_rubyserial_lst != nil
      instance_var_names = instance_variables - klass.dont_rubyserial_lst
    else
      instance_var_names = instance_variables
    end
    # Compute the resulting map
    instance_vars = {}
    instance_var_names.each do |sym_var|
      instance_vars[sym_var.to_s] = instance_variable_get(sym_var)
    end
    instance_vars
  end

  # Set the list of instance variables that were serialized
  #
  # Parameters::
  # * *instance_vars* (<em>map<String,Object></em>): Set of instance variables, per name
  def set_instance_vars_from_rubyserial(instance_vars)
    instance_vars.each do |var_name, value|
      instance_variable_set(var_name.to_sym, value)
    end
  end

end
