=begin
  locale_rails/lib/action_controller.rb - Ruby/Locale for "Ruby on Rails"

  Copyright (C) 2008  Masao Mutoh

  You may redistribute it and/or modify it under the same
  license terms as Ruby.

  $Id: action_controller.rb 25 2008-11-30 15:44:24Z mutoh $
=end

require 'action_controller'

module ActionController #:nodoc:
  class Base
    
    prepend_before_filter :init_locale

    def self.locale_filter_chain # :nodoc:
      if chain = read_inheritable_attribute('locale_filter_chain')
	return chain
      else
        write_inheritable_attribute('locale_filter_chain', FilterChain.new)
        return locale_filter_chain
      end
    end

    def init_locale # :nodoc:
      cgi = nil
      if defined? request.cgi
        cgi = request.cgi
      end

      fchain = self.class.locale_filter_chain
      run_before_filters(fchain.select(&:before?), 0, 0)

      cgi.params["lang"] = [params["lang"]] if params["lang"]
      Locale.set_cgi(cgi)
      if cgi.params["lang"]
        I18n.locale = cgi.params["lang"][0]
      else
        I18n.locale = nil
      end

      run_after_filters(fchain.select(&:after?), 0)
    end

    # Append a block which is called before initializing locale on each WWW request.
    #
    # (e.g.)
    #   class ApplicationController < ActionController::Base
    #     def before_init_i18n
    #       if (cookies["lang"].nil? or cookies["lang"].empty?)
    #         params["lang"] = "ko_KR"
    #       end
    #     end
    #     before_init_locale :before_init_i18n
    #     # ...
    #   end
    def self.before_init_locale(*filters, &block)
      locale_filter_chain.append_filter_to_chain(filters, :before, &block)
    end

    # Append a block which is called after initializing locale on each WWW request.
    #
    # (e.g.)
    #   class ApplicationController < ActionController::Base
    #     def after_init_i18n
    #       L10nClass.new(locale_candidates)
    #     end
    #     after_init_locale :after_init_i18n
    #     # ...
    #   end
    def self.after_init_locale(*filters, &block)
      locale_filter_chain.append_filter_to_chain(filters, :after, &block)
    end
  end

  class TestRequest < AbstractRequest  #:nodoc:
    class LocaleMockCGI < CGI #:nodoc:
      attr_accessor :stdinput, :stdoutput, :env_table
      
      def initialize(env, input=nil)
        self.env_table = env
        self.stdinput = StringIO.new(input || "")
        self.stdoutput = StringIO.new
        
        super()
      end
    end

    @cgi = nil
    def cgi
      unless @cgi
        @cgi = LocaleMockCGI.new("REQUEST_METHOD" => "GET",
                                  "QUERY_STRING"   => "",
                                  "REQUEST_URI"    => "/",
                                  "HTTP_HOST"      => "www.example.com",
                                  "SERVER_PORT"    => "80",
                                  "HTTPS"          => "off")
      end
      @cgi
    end
  end

  module Caching
    module Fragments
      def fragment_cache_key_with_locale(name) 
        ret = fragment_cache_key_without_locale(name)
        if ret.is_a? String
          ret.gsub(/:/, ".") << "_#{I18n.candidates}"
        else
          ret
        end
      end
      alias_method_chain :fragment_cache_key, :locale

      def expire_fragment_with_locale(name, options = nil)
        return unless perform_caching

        fc_store = (respond_to? :cache_store) ? cache_store : fragment_cache_store
        key = name.is_a?(Regexp) ? name : fragment_cache_key_without_locale(name)
        if key.is_a?(Regexp)
          self.class.benchmark "Expired fragments matching: #{key.source}" do
            fc_store.delete_matched(key, options)
          end
        else
          key = key.gsub(/:/, ".")
          self.class.benchmark "Expired fragment: #{key}, lang = #{I18n.supported_locales}" do
            supported_locales.each do |lang|
              fc_store.delete("#{key}_#{lang}", options)
            end
          end
        end
      end
      alias_method_chain :expire_fragment, :locale
    end
  end
end


