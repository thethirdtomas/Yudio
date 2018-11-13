# spec/app_spec.rb
require File.expand_path '../spec_helper.rb', __FILE__


describe "When User, my application" do

  before(:all) do
    #make user
    @u = User.new
    @u.email = "user@user.com"
    @u.password = "user"
    @u.save
    visit "/"
    page.set_rack_session(user_id: @u.id)

    #make free videos
    v=Video.new
    v.title="Video1"
    v.description="Description1"
    v.video_url="https://www.youtube.com/watch?v=WwTpPd_efdM"
    v.save

    v=Video.new
    v.title="Video2"
    v.description="Description2"
    v.video_url="https://www.youtube.com/watch?v=WwTpPd_efdM"
    v.save

    #make pro videos
    v=Video.new
    v.title="Video3"
    v.description="Description3"
    v.video_url="https://www.youtube.com/watch?v=WwTpPd_efdM"
    v.pro = true
    v.save

    v=Video.new
    v.title="Video4"
    v.description="Description4"
    v.video_url="https://www.youtube.com/watch?v=WwTpPd_efdM"
    v.pro = true
    v.save
  end

  it "should not allow requests to /videos/new (should redirect to '/')" do
    visit '/videos/new'
    expect(page).to have_current_path("/")
  end


  it "should display free videos on /videos" do
    free_videos = Video.all(pro: false)
    visit '/videos'
    free_videos.each do |v|
      expect(page.body).to include(v.title)
    end
  end

  it "should not display pro videos on /videos" do
    pro_videos = Video.all(pro: true)
    visit '/videos'
    pro_videos.each do |v|
      expect(page.body).not_to include(v.title)
    end
  end
end

describe "When Pro User, my application" do
    before(:all) do
      #make user
      @u = User.new
      @u.email = "pro@pro.com"
      @u.password = "pro"
      @u.pro = true
      @u.save
      page.set_rack_session(user_id: @u.id)
    end

  it "should not allow requests to /videos/new (should redirect to '/')" do
    visit '/videos/new'
    expect(page).to have_current_path("/")
  end


  it "should display free videos on /videos" do
    free_videos = Video.all(pro: false)
    visit '/videos'
    free_videos.each do |v|
      expect(page.body).to include(v.title)
    end
  end

  it "should display pro videos on /videos" do
    pro_videos = Video.all(pro: true)
    visit '/videos'
    pro_videos.each do |v|
      expect(page.body).to include(v.title)
    end
  end
end

describe "When Admin, my application" do
  before(:all) do
    #make user
    @u = User.new
    @u.email = "admin@admin.com"
    @u.password = "admin"
    @u.administrator = true
    @u.save
    page.set_rack_session(user_id: @u.id)

  end

  it "should allow admins to create videos" do
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

  it "should display free videos on /videos" do
    free_videos = Video.all(pro: false)
    visit '/videos'
    free_videos.each do |v|
      expect(page.body).to include(v.title)
    end
  end

  it "should display pro videos on /videos" do
    pro_videos = Video.all(pro: true)
    visit '/videos'
    pro_videos.each do |v|
      expect(page.body).to include(v.title)
    end
  end
end

describe "When not signed in, my application" do
  it "should not allow requests to /videos (should redirect to '/login')" do
    page.set_rack_session(user_id: nil)
    visit '/videos'
    expect(page).to have_current_path("/login")
  end

  it "should not allow requests to /videos/new (should redirect to '/login')" do
    page.set_rack_session(user_id: nil)
    visit '/videos/new'
    expect(page).to have_current_path("/login").or have_current_path("/")
  end
end