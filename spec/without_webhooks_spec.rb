require 'capybara_support'

RSpec.describe "Without webhooks", type: :system do
  example "With a valid card, the payment should be completed successfully" do
    visit server_url('/')

    within_frame find('iframe[name*=__privateStripeFrame]') do
      fill_in "cardnumber", with: '4242424242424242'
      fill_in "exp-date", with: "12 / 33"
      fill_in "cvc", with: "123"
      fill_in "postal", with: "10000"
    end

    click_on "Pay"

    expect(page).to have_content "Payment completed"
  end

  example "If the authentication failed, the payment should not be completed" do
    visit server_url('/')

    within_frame find('iframe[name*=__privateStripeFrame]') do
      fill_in "cardnumber", with: '4000000000003220'
      fill_in "exp-date", with: "12 / 33"
      fill_in "cvc", with: "123"
      fill_in "postal", with: "10000"
    end

    click_on "Pay"

    within_frame find('iframe[src*=three-ds]') do
      within_frame find('iframe#challengeFrame') do
        click_on "Fail"
      end
    end

    expect(page).to have_no_content "Payment completed"
    expect(page).to have_content "Your card was not authenticated, please try again"
  end
end
