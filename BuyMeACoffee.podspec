Pod::Spec.new do |spec|
  spec.name                  = 'BuyMeACoffee'
  spec.version               = '1.0.5'
  spec.license               = { :type => "MIT", :file => "LICENSE" }
                               
  spec.homepage              = 'https://www.buymeacoffee.com'
  spec.author                = { 'François Boulais' => 'francois@appcraftstudio.com' }
  spec.social_media_url      = 'https://twitter.com/frboulais'

  spec.summary               = 'Buy Me a Coffee framework for iOS'
  spec.source                = { :git => 'https://github.com/appcraftstudio/buymeacoffee.git', :tag => "#{spec.version}" }
  
  spec.screenshots           = [ 'https://github.com/appcraftstudio/buymeacoffee/raw/master/Images/screenshot-buymeacoffee-home.png',
                                 'https://github.com/appcraftstudio/buymeacoffee/raw/master/Images/screenshot-buymeacoffee-apple-pay.png' ]
                                 
  spec.ios.deployment_target = '11.0'
  spec.platform              = :ios, '11.0'
  spec.swift_version         = '5.0'

  spec.source_files          = 'Sources/**/*.swift', 'Bundle.swift'
  spec.resources             = 'Sources/**/Resources/*'

  spec.ios.framework         = 'UIKit', 'WebKit', 'SwiftUI'
  
  spec.test_spec 'BuyMeACoffeeTests' do |test_spec|
    test_spec.source_files   = 'Tests/BuyMeACoffeeTests/*.{swift}'
  end
end
