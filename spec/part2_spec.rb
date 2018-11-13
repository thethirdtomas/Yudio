# spec/app_spec.rb
require File.expand_path '../spec_helper.rb', __FILE__

describe "My application" do
  before(:all) do 
    @u = User.new
    @u.email = "abc@abc.com"
    @u.password = "abc"
    @u.save

    @admin = User.new
    @admin.email = "administrator@administrator.com"
    @admin.password = "administrator"
    @admin.administrator = true
    @admin.save
  end

  it "should allow accessing the home page" do
    get '/'
    # Rspec 2.x
    expect(last_response).to be_ok
  end

  it "should not be signed in by default" do
    visit '/'
    expect{ page.get_rack_session_key('user_id')}.to raise_error(KeyError)
  end

  it "should allow signing up for accounts" do
    visit '/sign_up'
    fill_in 'email', with: "test@test.com"
    fill_in 'password', with: "test"

    form = page.find("form")
    class << form
      def submit!
        Capybara::RackTest::Form.new(driver, native).submit({})
      end
    end
    form.submit!
    u = User.last
    expect(u).not_to be_nil
    expect(u.email).to eq("test@test.com")
    expect(u.password).to eq("test")
    expect(u.administrator).to eq(false)
  end

  it "should allow logging in" do
    visit '/login'
    fill_in 'email', with: "abc@abc.com"
    fill_in 'password', with: "abc"

    form = page.find("form")
    class << form
      def submit!
        Capybara::RackTest::Form.new(driver, native).submit({})
      end
    end
    form.submit!
    expect(page.get_rack_session_key('user_id')).to eq(@u.id)
  end

  it "should allow signing out" do
    visit '/'
    page.set_rack_session(user_id: @u.id)
    expect(page.get_rack_session_key('user_id')).to eq(@u.id)
    visit '/logout'
    expect{ page.get_rack_session_key('user_id')}.to raise_error(KeyError)
  end

  it "should allow requests to /videos/new" do
    page.set_rack_session(user_id: @admin.id)
    visit '/videos/new'
    # Rspec 2.x
    expect(page).to have_current_path("/videos/new")
  end

  it "should allow POST requests to /videos/create" do
    page.set_rack_session(user_id: @admin.id)
    page.driver.browser.post('/videos/create')

    expect(page.status_code).to eq(200)
    expect(page).to have_current_path("/videos/create")
  end

  it "should allow creation of PRO videos" do
    page.set_rack_session(user_id: @admin.id)
    visit '/videos/new'
    fill_in 'title', with: "TestTitle"
    fill_in 'description', with: "TestDescription"
    fill_in 'video_url', with: "https://www.youtube.com/watch?v=WwTpPd_efdM"
    check 'pro'

    form = page.find("form")
    class << form
      def submit!
        Capybara::RackTest::Form.new(driver, native).submit({})
      end
    end
    form.submit!

    v = Video.last
    expect(v.title).to eq("TestTitle")
    expect(v.description).to eq("TestDescription")
    expect(v.video_url).to eq("https://www.youtube.com/watch?v=WwTpPd_efdM")
    expect(v.pro).to eq(true)
  end

  it "should allow creation of FREE videos" do
    page.set_rack_session(user_id: @admin.id)
    visit '/videos/new'
    fill_in 'title', with: "TestTitle"
    fill_in 'description', with: "TestDescription"
    fill_in 'video_url', with: "https://www.youtube.com/watch?v=WwTpPd_efdM"

    form = page.find("form")
    class << form
      def submit!
        Capybara::RackTest::Form.new(driver, native).submit({})
      end
    end
    form.submit!

    v = Video.last
    expect(v.title).to eq("TestTitle")
    expect(v.description).to eq("TestDescription")
    expect(v.video_url).to eq("https://www.youtube.com/watch?v=WwTpPd_efdM")
    expect(v.pro).to eq(false)
  end

  it "should allow requests to /videos" do
    page.set_rack_session(user_id: @admin.id)
    visit '/videos'
    expect(page.status_code).to eq(200)
    expect(page).to have_current_path("/videos")
  end

  it "should have each free video listed on /videos" do
    page.set_rack_session(user_id: @admin.id)
    free_videos = Video.all(pro: false)
    visit '/videos'
    free_videos.each do |v|
      expect(page.body).to include(v.title)
    end
  end
end