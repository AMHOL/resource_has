# resource_has
============
Build resource dependencies in controllers that inherit from InheritedResources::Base

# Usage
----
```ruby
class Something < ActiveRecord::Base
  has_one :image
  has_many :users
end
```
```ruby
class SomeThingsController < InheritedResource::Base

  resource_has :image, :only => %w(edit update) # resource.build_image on edit and update (defaults to edit only)
  resource_has 3, :users # 3.times.do resource.users.build on edit
  resource_has 3, :users, do |user|
    user.build_dependency # build a dependency of user
    user.name = 'Default'
  end
  resource_has :at_least, 3, :users, { :increments_of => 2 } # will build 3 times if there are no existing users
                                                             # that relate, twice otherwise
  resource_has :at_most, 3, :users # will only build up to 3 users (i.e. if 3 users already exist as relations, no 
                                   # more will be built)
end
```
<pre>
Parameters:
  [ OPTIONAL ] Symbol  Modifier (:at_least | :at_most), at least will ensure that there are at least this 
                       many of the relation class, at most will ensure a maximum 
                       of quantifier relation classes)
  [ OPTIONAL ] Integer Quantifier (i.e. how many to build)
  [ REQUIRED ] Symbol  Relation Name (i.e. :images)
  [ OPTIONAL ] Hash    Options ( :increment_by, :only || :on 
</pre>
----

# Why?
I always found myself writing a protected method called build_dependencies and calling it as a before_filter when 
using Web app theme for Admin sections

