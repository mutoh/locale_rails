require 'test_helper'

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

end

