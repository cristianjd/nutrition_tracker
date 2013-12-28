require 'spec_helper'

describe ApiTokensController do

  describe "GET 'create'" do
    it "returns http success" do
      get 'create'
      response.should be_success
    end
  end

  describe "GET 'destroy'" do
    it "returns http success" do
      get 'destroy'
      response.should be_success
    end
  end

  describe "GET 'omniauth'" do
    it "returns http success" do
      get 'omniauth'
      response.should be_success
    end
  end

end
