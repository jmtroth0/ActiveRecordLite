class AttrAccessorObject
  def self.my_attr_accessor(*names)
    names.each do |name|
      define_method(name) do
        instance_variable_get("@#{name}")
      end

      define_method("#{name}=") do |value|
        instance_variable_set("@#{name}", value)
      end
    end
  end
end


#WHY DOES THIS WORK???
# class AttrAccessorObject
#   def self.my_attr_accessor(*names)
#     names.each do |name|
#       define_method(name) do
#         name
#       end
#
#       define_method("#{name}=") do |value|
#         name = value
#       end
#
#     end
#   end
# end
