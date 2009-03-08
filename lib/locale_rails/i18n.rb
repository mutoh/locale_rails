=begin
  locale_rails/lib/i18n.rb - Ruby/Locale for "Ruby on Rails"

  Copyright (C) 2008,2009  Masao Mutoh

  You may redistribute it and/or modify it under the same
  license terms as Ruby.

  $Id: i18n.rb 25 2008-11-30 15:44:24Z mutoh $
=end

module I18n
  @@supported_locales = nil
  module_function

  # Gets the supported locales.
  def supported_locales 
    @@supported_locales
  end

  # Sets the supported locales as an Array.
  #  I18n.supported_locales = ["ja-JP", "ko-KR"]
  def supported_locales=(tags)
    @@supported_locales = tags
  end

  # Sets the locale.
  #  I18n.locale = "ja-JP"
  def locale=(tag)
    Locale.clear
    tag = Locale::Tag::Rfc.parse(tag.to_s) if tag.kind_of? Symbol
    Locale.current = tag
    Thread.current[:locale] = candidates(:rfc)[0]
  end
  
  # Get the locale candidates as a Locale::TagList.
  # This is the utility function which calls Locale.candidates with
  # supported_language_tags.
  #
  # I18n.locale is also overrided by Ruby-Locale and it returns 
  # the result of this method with :rfc option.
  # 
  # +type+ :simple, :common(default), :rfc, :cldr.
  # 
  # This is used by Rails application, but it may be better not to
  # use this method in Rails plugins/libraries, because they have their
  # own supported languages. 
  def candidates(type = :common)
    default = [I18n.default_locale.to_s]
    default = ["en-US", "en"] if default[0] == "en-US"
    Locale.candidates(:type => type, 
                      :supported_language_tags => supported_locales,
                      :default_language_tags => default)
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

