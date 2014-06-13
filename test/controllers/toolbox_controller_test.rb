require 'test_helper'

describe ToolboxController do

  let(:user) { FactoryGirl.create :user }

  #render_views

  describe "GET 'session_expired'" do
    context "as json" do
      it "should be successful" do
        get :session_expired, format: :json
        response.should be_success
      end
    end

    context "as html" do
      it "should fail" do
        expect { get :session_expired }.to raise_error
      end
    end
  end

   describe "GET 'confirm'" do
    context "as js" do
      it "should be successful" do
        xhr :get, :confirm, format: :js
        response.should be_success
      end
    end

    context "as html" do
      it "should fail" do
        expect { get :confirm }.to raise_error
      end
    end
  end

  describe "GET 'rss'" do
    before(:each) do
      FakeWeb.register_uri(:get, 'https://info.fairnopoly.de/?feed=rss', :body => "<?xml version=\"1.0\" encoding=\"UTF-8\" ?><rss version=\"2.0\"></rss>")
    end

    context "as html" do
      it "should be successful" do
        get :rss
        response.should be_success
      end
    end

    context "as json" do
      it "should fail" do
        expect { get :rss, format: :json }.to raise_error
      end
    end

    context "on timeout" do
      it "should be sucessful and return nothing" do
        Timeout.stub(:timeout).and_raise(Timeout::Error)
        get :rss
        response.should be_success
      end
    end
  end

  describe "GET 'reload'" do
    it "should be successful" do
      get :reload
      response.should be_success
    end

    it "should not render a layout" do
      get :reload
      response.should_not render_template("layouts/application")
    end
  end

  describe "GET 'healthcheck'" do
    it "should be successful" do
      get :healthcheck
      response.should be_success
    end

    it "should not render a layout" do
      get :healthcheck
      response.should_not render_template("layouts/application")
    end
  end

  describe "GET 'newsletter_status'" do
    context "when logged in" do
      before do
        sign_in user
      end
      it "should be successful" do
        fixture = File.read("spec/fixtures/cleverreach_get_by_mail_success.xml")
        savon.expects(:receiver_get_by_email).with(message: :any).returns(fixture)
        get :newsletter_status, format: :json
        response.should be_success
      end

      it "should not render a layout" do
        fixture = File.read("spec/fixtures/cleverreach_get_by_mail_success.xml")
        savon.expects(:receiver_get_by_email).with(message: :any).returns(fixture)
        get :newsletter_status, format: :json
        response.should_not render_template("layouts/application")
      end

      it "should call the Cleverreach API with the logged in user" do
        CleverreachAPI.should_receive(:get_status).with(user)
        get :newsletter_status, format: :json
      end
    end
  end

  describe "GET 'notice'" do
    before do
      @notice = FactoryGirl.create :notice
      sign_in user
    end

    it "should redirect to the notice path and close it" do
      get :notice, :id => @notice.id
      response.should redirect_to(@notice.path)
      @notice.reload.open.should be false
    end
  end

  describe "PUT reindex" do
    before do
      sign_in user
    end

    context "for normal users" do
      it "should not be allowed" do
        expect { put :reindex, article_id: 1 }.to raise_error Pundit::NotAuthorizedError
      end
    end

    context "for admin users" do
      let(:user) { FactoryGirl.create :admin_user }
      it "should do something" do
        article = FactoryGirl.create :article
        Indexer.should_receive(:index_article).with(article)

        request.env["HTTP_REFERER"] = '/'
        put :reindex, article_id: article.id
      end
    end
  end
end
