class <%= class_name %> < ActiveRecord::Base
<% for attribute in attributes -%>
<%= "belongs_to :#{attribute.name}" if attribute.type.to_s == "references" %>
<% end -%>
end
