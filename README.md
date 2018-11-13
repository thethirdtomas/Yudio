## Introduction

The goal in this assignment is to learn how to make a modern Software as a Service (SaaS) product. The goal is walk the student through the process of incrementally developing each feature and ending with billing. Students will learn how to make simple application features protected by authentication (signing in) and authorization (only seeing what you're allowed to). Students will then use Stripe to allow customers to make purchases and have those purchases trigger application code. This HW will be based on the idea of making a commercial online video platform. Similar examples include: Netflix, Hulu, Art of Jiu-Jitsu Online, Yoga for BJJ, Udemy, and more.



## The Task

Make an online video platform where people must sign-in to view the videos on the platform. Users who are *pro* users are allowed to view *pro* videos. Users become *pro* by paying money to upgrade their membership. Admins are allowed to see all the videos. Admins are also allowed to add new videos to the platform.



## Getting Started

* Clone project

* Navigate to directory in command line

* Install required gems: `bundle install --without production`

* Run server with: `bundle exec ruby app.rb`

  ​



## Part 1 - Model the Data Correctly

For part 1 your job is to add to the Video and User classes such that they have all the properties we need.

Run tests with: `bundle exec rspec spec/part1_spec.rb`

#### Video

* should have property **id**

* should have property **title**, for ex: Schweller Kills Guy in Tournament

* should have property **description**, for ex: Guy didn't stand a chance

* should have property **video_url**, for ex: https://www.youtube.com/watch?v=e7-v0wymn-g

* should have *boolean* property **pro** which defaults to *false*, signifies whether a video is a *pro* video or not

  ​

#### User

* should have property **id**
* should have property **email**, for ex: eric@eric.com
* should have property **password**, for ex: eric123
* should have property **pro**, which defaults to false, signifies whether the user has paid for upgraded privileges. for ex: *false*
* should have boolean property **administrator**, which defaults to *false*, signifies whether a user is in administrator or not




## Part 2 - Make Basic User Interface for Videos

The goal here is to make a basic User Interface for viewing and adding Video objects to the database.

Run tests with: `bundle exec rspec spec/part2_spec.rb`

#### GET /videos

On GET requests to /videos you should output every FREE video in the database. Output the title, description, and embed the video.



#### POST /videos/create

On POST requests to /videos/create you should accept the following parameters: title, description, video_url, pro. **<u>Only title, description, and video_url are required.</u>** <u>*The pro parameter is optional.*</u> When handed those things, you should make and save a new Video object with that information.



#### GET /videos/new

On GET requests to /videos/new you should show a form that helps the user submit a POST request to /videos/create. The form should have some type of input tag for: title, description, video_url, and pro.

**HINT: ** Here's just one way to do it. Make the input tag for the *pro* parameter a checkbox. `<input type="checkbox" name="pro">` If the box is checked it will set `params["pro"]="on"`, if not checked the `params` hash with not have a key `"pro"`.



#### In short

* should allow GET requests to /videos/new
* should allow POST requests to /videos/create
* should allow creation of FREE videos
* should allow creation of PRO videos
* should display all FREE videos on GET /videos



## Part 3

Add proper authentication and authorization checks for routes.

Use `authenticate!` to protect routes from not signed in users. Write your own function to protect against non-admin users. 

Run tests with: `bundle exec rspec spec/part3_spec.rb`

* Protect /videos from not signed-in users
* Protect /videos/new from anyone who is not an admin
* Protect /videos/create from anyone who is not an admin
* Non-Pro and Non-Admin users should only see free videos on /videos
* Admin users should see all videos on /videos
* Pro users should see all videos on /videos



## Part 4 - Adding Billing

Make an account on Stripe.com and follow use this as a reference guide: https://stripe.com/docs/checkout/sinatra



* Make a GET /upgrade route which displays a Stripe payment form to signed-in users who are not admins and are not pro
* Make successful charges go to POST /charge
  * In here, upgrade the current signed-in user to pro
  * Charge the card
  * Display the user a success message
* For testing Stripe Checkout, use "customer@example.com" for  email, "4242 4242 4242 4242" as Card Number, any future date as expiration, and any CVC.



#### Running Part 4 tests:

* Install PhantomJS via instructions here: https://github.com/teampoltergeist/poltergeist

* You need PhantomJS for the poltergeist gem (to properly test Stripe)

* Run: `bundle exec rspec spec/part4_spec.rb`

* Note: These tests take about 1 minute to run

  ​



## Submitting

#### Submit to Github Classroom

Do the normal thing, add all your changes, commit, and push.

#### Deploy to Heroku (Submit link on Blackboard)

1. Do these ONCE only per project
   1. Create a Heroku server: `heroku create`
   2. Create a database for your server: `heroku addons:create heroku-postgresql:hobby-dev`
2. Add all your changes on git and commit those changes
3. Push the code to Heroku: `git push heroku master`
4. I preconfigured the necessary files for this to work.
5. Verify all is working and submit your links (github and heroku) to me.