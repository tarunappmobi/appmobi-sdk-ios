
Pod::Spec.new do |s|
s.name             = 'AppmobiSecurity'
s.version          = '1.0.0'
s.summary          = 'Appmobi provides real time monitoring of in app activity.'

s.description      = <<-DESC
Appmobi provides real time monitoring of in app activity using a set of predefined and customizable rules capable of identifying suspicious behavior that may lead to an application breach or data hack.
DESC

s.homepage         = 'https://appmobi.com'
s.license          = { :type => '', :file => 'LICENSE' }
s.author           = { 'Appmobi' => 'cocoapod@appmobi.com' }
s.source           = { :git => 'https://github.com/appMobiGithub/appmobi-sdk-ios.git', :tag => '1.0.0' }

s.ios.deployment_target = '8.0'

s.frameworks = ''
s.ios.vendored_framework   = 'Appmobi/Appmobi.framework'

end
