require File.expand_path '../spec_helper.rb', __FILE__

describe Video do
  it { should have_property           :id }
  it { should have_property           :title  }
  it { should have_property           :description  }
  it { should have_property           :video_url  }
  it { should have_property           :pro }
end

describe User do
  it { should have_property           :id }
  it { should have_property           :email }
  it { should have_property           :password }
  it { should have_property           :pro }
  it { should have_property           :administrator }
end