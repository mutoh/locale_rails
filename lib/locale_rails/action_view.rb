=begin
  locale_rails/lib/action_view.rb - Ruby/Locale for "Ruby on Rails"

  Copyright (C) 2008  Masao Mutoh

  You may redistribute it and/or modify it under the same
  license terms as Ruby.

  Original: Ruby-GetText-Package-1.92.0

=end

require 'action_view'

module ActionView #:nodoc:
   class PathSet < Array
     include Locale::Util::Memoizable

     def find_template_with_locale_rails(original_template_path, format = nil, html_fallback = true)
      return original_template_path if original_template_path.respond_to?(:render)

      path = original_template_path.sub(/^\//, '')
      if m = path.match(/(.*)\.(\w+)$/)
        template_file_name, template_file_extension = m[1], m[2]
      else
        template_file_name = path
      end
 
      I18n.candidates.each do |v|
        file_name = "#{template_file_name}_#{v}"
	begin
          return find_template_without_locale_rails(file_name, format, false)
        rescue MissingTemplate => e
	end
      end
      find_template_without_locale_rails(original_template_path, format, html_fallback)
    end
    alias_method_chain :find_template, :locale_rails

  end
end

