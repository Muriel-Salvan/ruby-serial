class Object

  # Get the list of instance variables that are meant to be serialized
  #
  # Result::
  # * <em>map<String,Object></em>: Set of instance variables, per name
  def get_instance_vars_to_rubyserial
    instance_vars = {}
    self.instance_variables.each do |sym_var|
      instance_vars[sym_var.to_s] = self.instance_variable_get(sym_var)
    end
    return instance_vars
  end

  # Set the list of instance variables that were serialized
  #
  # Parameters::
  # * *instance_vars* (<em>map<String,Object></em>): Set of instance variables, per name
  def set_instance_vars_from_rubyserial(instance_vars)
    instance_vars.each do |var_name, value|
      self.instance_variable_set(var_name.to_sym, value)
    end
  end

end
