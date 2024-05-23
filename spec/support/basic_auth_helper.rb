module BasicAuthHelper
    def basic_auth_login
        name = ENV['BASIC_AUTH_USERNAME']
        password = ENV['BASIC_AUTH_PASSWORD']
        if page.driver.respond_to?(:basic_auth)
            page.driver.basic_auth(name, password)
        elsif page.driver.respond_to?(:basic_authorize)
            page.driver.basic_authorize(name, password)
        elsif page.driver.respond_to?(:browser) && page.driver.browser.respond_to?(:basic_authorize)
            page.driver.browser.basic_authorize(name, password)
        else
            raise "I don't know how to log in!"
        end
    end  
  end