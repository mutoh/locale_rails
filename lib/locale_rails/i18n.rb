=begin
  locale_rails/lib/i18n.rb - Ruby/Locale for "Ruby on Rails"

  Copyright (C) 2008,2009  Masao Mutoh

  You may redistribute it and/or modify it under the same
  license terms as Ruby.

  $Id: i18n.rb 25 2008-11-30 15:44:24Z mutoh $
=end

module I18n
  module_function

  # Gets the supported locales.
  def supported_locales 
    Locale.app_language_tags
  end

  # Sets the supported locales.
  #  I18n.set_supported_locales("ja-JP", "ko-KR", ...)
  def set_supported_locales(*tags)
    Locale.set_app_language_tags(*tags)
  end

  # Sets the supported locales as an Array.
  #  I18n.supported_locales = ["ja-JP", "ko-KR", ...]
  def supported_locales=(tags)
    Locale.set_app_language_tags(*tags)
  end

  # Sets the locale.
  #  I18n.locale = "ja-JP"
  def locale=(tag)
    Locale.clear
    tag = Locale::Tag::Rfc.parse(tag.to_s) if tag.kind_of? Symbol
    Locale.current = tag
    Thread.current[:locale] = candidates(:rfc)[0]
  end
  
  class << self

    # MissingTranslationData is overrided to fallback messages in candidate locales.
    def locale_rails_exception_handler(exception, locale, key, options) #:nodoc:
      ret = nil
      candidates(:rfc).each do |loc|
        begin
          ret = backend.translate(loc, key, options)
          break
        rescue I18n::MissingTranslationData 
          ret = I18n.default_exception_handler(exception, locale, key, options)
        end
      end
      ret
    end
    I18n.exception_handler = :locale_rails_exception_handler
  end

end

