require 'test_helper'
require 'fileutils'

class ArticlesControllerTest < ActionController::TestCase

  def setup
    @request.env["HTTP_ACCEPT_LANGUAGE"] = "fr-FR;ja;q=0.7,de;q=0.3"
    Locale.clear
  end

  test "localized template with accept_language" do
    @request.env["HTTP_ACCEPT_LANGUAGE"] = "en-US"
    get :index
    assert_equal "index.html.erb", @response.body.chop
    @request.env["HTTP_ACCEPT_LANGUAGE"] = "ja-jp"
    get :index, :lang => "ja"
    assert_equal "index_ja.html.erb", @response.body.chop
    @request.env["HTTP_ACCEPT_LANGUAGE"] = "fr-FR"
    get :index
    assert_equal "index_fr_FR.html.erb", @response.body.chop

    @request.env["HTTP_ACCEPT_LANGUAGE"] = "fr"
    get :index
    assert_equal "index.html.erb", @response.body.chop
  end

  test "localized template with accept_languages" do
    @request.env["HTTP_ACCEPT_LANGUAGE"] = "en,ja;q=0.7,de;q=0.3"
    get :index
    assert_equal "index.html.erb", @response.body.chop

    @request.env["HTTP_ACCEPT_LANGUAGE"] = "fr-FR,ja;q=0.7,de;q=0.3"
    get :index
    assert_equal "index_fr_FR.html.erb", @response.body.chop

    @request.env["HTTP_ACCEPT_LANGUAGE"] = "ja;q=0.7,de;q=0.3"
    get :index
    assert_equal "index_ja.html.erb", @response.body.chop
  end

  test "localized template with query string" do
    @request.env["HTTP_ACCEPT_LANGUAGE"] = "en,ja;q=0.7,de;q=0.3"
    get :index, :lang => "ja"
    assert_equal "index_ja.html.erb", @response.body.chop

    @request.env["HTTP_ACCEPT_LANGUAGE"] = "fr-FR,ja;q=0.7,de;q=0.3"
    get :index, :lang => "ja"
    assert_equal "index_ja.html.erb", @response.body.chop

    @request.env["HTTP_ACCEPT_LANGUAGE"] = "ja;q=0.7,de;q=0.3"
    get :index, :lang => "en"
    assert_equal "index.html.erb", @response.body.chop
  end

  test "localized template with accept_languages and default is de" do
    # index_de.html.erb is existed.
    Locale.default = "de"
    @request.env["HTTP_ACCEPT_LANGUAGE"] = "en,ja;q=0.7,de;q=0.3"
    get :index
    assert_equal "index_ja.html.erb", @response.body.chop

    @request.env["HTTP_ACCEPT_LANGUAGE"] = "fr-FR,ja;q=0.7,de;q=0.3"
    get :index
    assert_equal "index_fr_FR.html.erb", @response.body.chop

    @request.env["HTTP_ACCEPT_LANGUAGE"] = "ja;q=0.7,de;q=0.3"
    get :index
    assert_equal "index_ja.html.erb", @response.body.chop

    @request.env["HTTP_ACCEPT_LANGUAGE"] = "de;q=0.7,en;q=0.3"
    get :index
    assert_equal "index_de.html.erb", @response.body.chop

    @request.env["HTTP_ACCEPT_LANGUAGE"] = "zh"
    get :index
    assert_equal "index_de.html.erb", @response.body.chop
    Locale.default = nil
  end

  test "localized template with accept_languages and default is zh" do
    # index_zh.html.erb is not existed.
    Locale.default = "zh"
    @request.env["HTTP_ACCEPT_LANGUAGE"] = "en,ja;q=0.7,de;q=0.3"
    get :index
    assert_equal "index_ja.html.erb", @response.body.chop

    @request.env["HTTP_ACCEPT_LANGUAGE"] = "fr-FR,ja;q=0.7,de;q=0.3"
    get :index
    assert_equal "index_fr_FR.html.erb", @response.body.chop

    @request.env["HTTP_ACCEPT_LANGUAGE"] = "ja;q=0.7,de;q=0.3"
    get :index
    assert_equal "index_ja.html.erb", @response.body.chop

    @request.env["HTTP_ACCEPT_LANGUAGE"] = "en;q=0.7;nl;q=0.3"
    get :index
    assert_equal "index.html.erb", @response.body.chop

    @request.env["HTTP_ACCEPT_LANGUAGE"] = "zh"
    get :index
    assert_equal "index.html.erb", @response.body.chop
    Locale.default = nil
  end

  test "list.html.erb should be cached" do
    cache_path = RAILS_ROOT + "/tmp/cache/views"
    FileUtils.rm_rf cache_path
    @request.env["HTTP_ACCEPT_LANGUAGE"] = "en,ja;q=0.7,de;q=0.3"
    get :list
    assert_equal "list:en", @response.body.chop

    path = Dir.glob(cache_path + "/**/list_en.cache")[0]
    st = File.stat(path)
    last_modified_en = [st.ctime, st.mtime]

    get :list, :lang => "ja"
    assert_equal "list:ja", @response.body.chop

    path = Dir.glob(cache_path + "/**/list_ja.cache")[0]
    st = File.stat(path)
    last_modified_ja = [st.ctime, st.mtime]

    get :list
    st = File.stat(path)
    assert_equal last_modified_en, [st.ctime, st.mtime]
    assert_equal "list:en", @response.body.chop

    get :list, :lang => "ja"
    st = File.stat(path)
    assert_equal last_modified_ja, [st.ctime, st.mtime]
    assert_equal "list:ja", @response.body.chop

    # expire test
    assert_equal 2, Dir.glob(cache_path + "/**/*.cache").size
    get :expire_cache, :lang => "ja"
    assert_equal [], Dir.glob(cache_path + "/**/*.cache")
  end

end

