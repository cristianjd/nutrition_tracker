Given(/^I am on the home page$/) do
  visit '/'
end

Then(/^I should see a welcome message$/) do
  expect(page).to have_content('Getting Started')
end

Then(/^I should see a link to (.+)$/) do |link_name|
  expect(page).to have_link(link_name)
end