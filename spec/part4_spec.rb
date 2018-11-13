# spec/app_spec.rb
require File.expand_path '../spec_helper.rb', __FILE__


describe "My application" do

  before(:all) do
Capybara.register_driver :poltergeist_test do |app|
  options = {
    phantomjs_options: ['--ssl-protocol=any', '--ignore-ssl-errors=yes'],
    inspector: false
  }
  Capybara::Poltergeist::Driver.new(app, options)
end

  		Capybara.current_driver = :poltergeist_test
  	  @u = User.new
	    @u.email = "user@user.com"
	    @u.password = "user"
	    @u.save

      @u2 = User.new
      @u2.email = "user2@user2.com"
      @u2.password = "user2"
      @u2.save

	    @admin = User.new
	    @admin.email = "administrator@administrator.com"
	    @admin.password = "admin"
	    @admin.administrator = true
	    @admin.save

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


  it "should allow requests to /upgrade by users who are not admins or pro" do
  	page.set_rack_session(user_id: @u.id)
  	visit '/upgrade'
  	expect(page.status_code).to eq(200)
    expect(page).to have_current_path("/upgrade")
  end

  it "should not allow requests to /upgrade for non-signed in users" do
  	page.set_rack_session(user_id: nil)
  	visit '/upgrade'
  	expect(page.status_code).to eq(200)
    expect(page).not_to have_current_path("/upgrade")
  end

  it "should not allow requests to /upgrade for admins" do
  	page.set_rack_session(user_id: @admin.id)
  	visit '/upgrade'
  	expect(page.status_code).to eq(200)
    expect(page).not_to have_current_path("/upgrade")
  end

  it "should allow free user to upgrade to pro by paying money", js: true do
  	page.set_rack_session(user_id: @u.id)
  	Capybara.default_max_wait_time = 10
  	visit '/upgrade'
  	sleep(5)
  	click_button 'Pay with Card'
    expect(page).to have_css('iframe[name="stripe_checkout_app"]')
	  stripe_iframe = all('iframe[name=stripe_checkout_app]').last

      Capybara.within_frame stripe_iframe do
        # Set values by placeholders
        fill_in 'Email', with: "customer@example.com"
        fill_in 'Card number', with: '4242424242424242'
        fill_in 'MM / YY', with: '0829'
        fill_in 'CVC', with: '123'
        # You might need to fill more fields...

        click_button 'Pay $5.00'
      end
    sleep(30)
    u = User.get(@u.id)
    expect(u.pro).to eq(true)
  end

  it "should allow not all free user to upgrade to pro by paying money with invalid card", js: true do
    page.set_rack_session(user_id: @u2.id)
    Capybara.default_max_wait_time = 10
    visit '/upgrade'
    sleep(5)
    click_button 'Pay with Card'
    expect(page).to have_css('iframe[name="stripe_checkout_app"]')
    stripe_iframe = all('iframe[name=stripe_checkout_app]').last

      Capybara.within_frame stripe_iframe do
        # Set values by placeholders
        fill_in 'Email', with: "customer@example.com"
        fill_in 'Card number', with: '4242424242424243'
        fill_in 'MM / YY', with: '0829'
        fill_in 'CVC', with: '123'
        # You might need to fill more fields...

        click_button 'Pay $5.00'
      end
    sleep(30)
    u = User.get(@u2.id)
    expect(u.pro).to eq(false)
  end

end