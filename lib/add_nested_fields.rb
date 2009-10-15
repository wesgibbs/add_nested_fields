module AddNestedFields
  module ViewHelper

    def add_nested_fields_for(form_builder, field, selector, *args)
      options = {
        :partial => field.to_s.singularize,
        :label => "Add #{field.to_s.singularize.titleize}",
        :label_class => "",
        :object => field.to_s.classify.constantize.new
      }.merge(args.extract_options!)

      link_to_function("#{options[:label]}", :class => options[:label_class]) do |page|
        form_builder.fields_for field, options[:object] , :child_index => 'NEW_RECORD' do |f|
          html = render(:partial => options[:partial], :locals => { :f => f })
          page << "$('#{selector}').append('#{escape_javascript(html)}'.replace(/NEW_RECORD/g, new Date().getTime())).trigger('nested.field.added');"
        end
      end
    end

    def remove_nested_fields_for(form_builder, selector, *args)
      options = {
        :label => 'remove',
        :label_class => ''
      }.merge(args.extract_options!)
      confirm = "if (confirm('Are you sure you would like to delete this #{form_builder.object.class.to_s.underscore.humanize.downcase}?'))"
      if form_builder.object.new_record?
        link_to_function(options[:label], :class => options[:label_class]) do |page|
          page << "#{confirm} $(this).parents('#{selector}').hide().trigger('nested.field.removed').remove();"
        end
      else
        form_builder.hidden_field( :_delete, :value => "0") + link_to_function(options[:label], :class => options[:label_class]) do |page|
          page << "#{confirm} $(this).parents('#{selector}').hide().trigger('nested.field.removed');$(this).prev(':hidden').val(1)"
        end
      end
    end

  end
end
ActionView::Base.send(:include, AddNestedFields::ViewHelper)
