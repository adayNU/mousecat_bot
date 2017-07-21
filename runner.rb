require 'selenium-webdriver'
require  "#{File.dirname(__FILE__)}/lib/play_mouse_cat.rb"

driver = Selenium::WebDriver.for(:chrome)
driver.get PlayMouseCat::MOUSECAT_URL

sleep(2)

1000.times do
  PlayMouseCat.run(driver, 6)
end

driver.close
