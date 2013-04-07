require 'resource_has/version'

module ResourceHas
  
  def self.included(base)
    base.extend(ClassMethods)
  end
  ## Class methods
  module ClassMethods
    def resource_has(*args, &block)
      options = args.pop if args.last.is_a? Hash
      if args.length == 1
        modifier = :at_most
        amount = 1
      else
        modifier = args.shift() unless args[0].is_a? Integer
        amount = args.shift()
      end
      relation_name = args.shift()
      args = {
        :modifier => modifier,
        :amount => amount,
        :block => block,
        :options => { :increment_by => amount, :on => %w(edit) }.merge(options || {})
      }
      before_filter :only => (args[:options].delete(:only) || args[:options].delete(:on)) do |controller| controller.send('__build_relation', relation_name, args) end
    end
  end
  ## Instance methods
  protected

  def __build_relation(relation_name, args)
    __quantify(relation_name, args).times do
      nested_resource = resource_method_chain __get_builder_method(relation_name)
      args[:block].call(nested_resource) if args[:block]
    end
  end

  def __quantify(relation_name, args)
    #args.merge!({ :modifier => :at_most, :amount => 1, :increment_by => 1 }) if __is_single_relation? relation_name
    return args[:options][:increment_by] unless args[:modifier]
    quantifier = args[:amount] - __get_existing_relation_length(relation_name)
    if args[:modifier].to_sym === :at_least
      return args[:options][:increment_by] if quantifier < args[:options][:increment_by]
      quantifier
    elsif args[:modifier].to_sym === :at_most
      args[:options][:increment_by] < quantifier ? args[:options][:increment_by] : quantifier
    end
  end

  def __get_builder_method(relation_name)
    return 'build_%s' % relation_name if __is_single_relation?(relation_name)
    return '%s.build' % relation_name
  end

  def resource_method_chain(method_chain)
    return resource if method_chain.empty?
    method_chain.split('.').flatten.inject(self.resource){ |object, method| object.send(method.to_sym) }
  end

  def __is_single_relation? relation_name
    [:has_one].include?(resource.class.reflect_on_association(relation_name).macro)
  end
  
  def __get_existing_relation_length(relation_name)
    relation = resource.send(relation_name)
    return relation.length.to_i if relation.respond_to?(:length)
    relation.blank? ? 0 : 1
  end
end

ActionController::Base.send(:include, ResourceHas)