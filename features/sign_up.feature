Feature: Visitor
  As a fitness conscious person
  In order to maintain a consistent diet
  I want to sign up for Nutrition Tracker

  Scenario: Visit Home Page
    Given I am on the home page
    Then I should see a welcome message
    And I should see a link to Sign Up
    And I should see a link to FatSecret