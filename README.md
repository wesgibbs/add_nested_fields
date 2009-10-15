AddNestedFields
===============

Adds two RJS helper methods to help work with accepts_nested_attributes_for and partials. Based on the method suggested by Marsvin on [RailsForum.com](http://railsforum.com/viewtopic.php?pid=91229)

This branch is for use with jQuery. Requires jQuery 1.3.2.

Installation
============

To install as a plugin (Rails)

  cd into your Rails root folder
  script/plugin install git://github.com/miletbaker/add_nested_fields.git

Usage
=====

Example form

  <% form_for @product do |f| %>
    ...
    <div id="variations">
      <% f.fields_for :product_variations do |prod_var| %>
          <%= render :partial => 'product_variation', :locals => { :f => prod_var } %>
      <% end %>
    </div>
    <%= add_nested_fields_for(f, :product_variations, '#variations') %>
  <% end %>

example _product_variation.rb

  <li class="product_variation">
    ...
      <%= remove_nested_fields_for(f, '.product_variation') %>
    ...
  </li>

add_nested_fields_for(form_builder, field, selector, options = {})
--------------------------------------------------------------------
add_nested_fields_for adds a link to a javascript function that adds an additional nested model form, based on a partial.

*form_builder* is the current form_for builder

*field* is the property of the model that holds the relationship, i.e. in the link above Product has a has_many relationship to product_variations and hence :product_variations is its attribute.

*selector* is the DOM selector of the HTML element to append the partial into the bottom of.

You can optionally also supply:

*:partial =>* defaults to the singular name of the field, in the above example 'product_variation'

*:label =>* defaults to "Add" plus the title case, singular name of the field

*:label_class =>* CSS class(es) to add to the label.  Defaults to ''

*:object =>* defaults to creating a new instance of an object using the camel-cased name of the field i.e. above that would be ProductVariation.new

remove_nested_fields_for(form_builder, selector, options = {})
------------------------------------------------
remove_nested_fields_for adds a link to a javascript function that if new, removes the partial, and if existing sets a hidden field _marking it's removal _delete=1, informing rails to delete the record and hides the partial.

*form_builder* is the fields_for builder, passed to the partial via the locals option.

*selector* is the selector for the HTML parent element that forms the whole of the partial, the function searches parents from the link for an HTML element with the matching class and removes or hides it as above.

You can optionally also supply:

*:label =>* text for the remove link. Defaults to 'remove'

*:label_class =>* CSS class attribute for the remove link. Defaults to ''

Validation
==========
Your models should validate the nested models as expected however there are a couple of issues around the order validation is done and models are saved.

If you would like to validate the presence of nested attributes, for example, with the above code, if you wanted to ensure that there was at least one ProductVariation present when saving the Product model, you could add something along the lines of the following to your validate method override in your Product model

  def validate
    ...
    # TODO: create validates_presence_of_nested_attributes
    errors.add(:product_variations, " must have at least one variation.") unless product_variations.select {|var| var._delete != true}.length > 0
    ...
  end

This is needed because models are not removed until the save so in some cases the user may have requested to delete a nested model by setting _delete to true but at the time of validation the model is still present.

There are also some issues validating that the parent_id is present in the child. [See the RailsForum.com thread for details](http://railsforum.com/viewtopic.php?pid=91229)

Copyright (c) 2009 Go Tripod Ltd, released under the MIT license
