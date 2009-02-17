=begin
  locale_rails/lib/action_view.rb - Ruby/Locale for "Ruby on Rails"

  Copyright (C) 2008  Masao Mutoh

  You may redistribute it and/or modify it under the same
  license terms as Ruby.

  Original: Ruby-GetText-Package-1.92.0

  $Id: action_view.rb 31 2008-12-04 13:32:25Z mutoh $
=end

require 'action_view'

module ActionView #:nodoc:
  class Base
    def _pick_template_with_locale_main(template_path, tags) #:nodoc:
      path = template_path.sub(/^\//, '')
      if m = path.match(/(.*)\.(\w+)$/)
        template_file_name, template_file_extension = m[1], m[2]
      else
        template_file_name = path
      end
 
      tags.each do |v|
        file_name = "#{template_file_name}_#{v}"
	begin
          return _pick_template_without_locale(file_name)
        rescue MissingTemplate => e
	end
      end
      _pick_template_without_locale(template_path)
    end
    memoize :_pick_template_with_locale_main

    def _pick_template_with_locale(template_path) #:nodoc: shouldn't memoize.
      _pick_template_with_locale_main(template_path, I18n.candidates)
    end
    alias_method_chain :_pick_template, :locale
  end
end

