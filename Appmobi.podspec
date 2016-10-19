
Pod::Spec.new do |s|
s.name             = 'Appmobi'
s.version          = '1.0.0'
s.summary          = 'Appmobi Security Kit.'

s.description      = <<-DESC
Appmobi secures hybrid and native mobile applications for the enterprise market.
DESC

s.homepage         = 'https://appmobi.com'
s.license          = { :type => '', :file => 'LICENSE' }
s.author           = { 'inderpreet-singh' => 'inderpreet@appmobi.com' }
s.source           = { :git => 'https://github.com/appMobiGithub/appmobi-sdk-ios.git', :tag => '1.0.0' }

s.ios.deployment_target = '8.0'

s.frameworks = ''
s.ios.vendored_framework   = 'Appmobi/Appmobi.framework'

end
