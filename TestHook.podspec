Pod::Spec.new do |s|
  s.name             = 'TestHook'
  s.version          = '0.1.0'
  s.summary          = 'ByteDance TestHook Demo.'
  s.description      = 'ByteDance TestHook Demo..'
  s.homepage         = 'https://github.com/dwbbytedance/Demo.git'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'duanwenbin' => 'duanwenbin@bytedance.com' }
  s.source           = { :git => 'https://github.com/dwbbytedance/Demo.git', :tag => s.version.to_s }
  s.ios.deployment_target = '8.0'
  s.requires_arc = true
  s.static_framework = true
  s.default_subspecs = 'Base'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES'}
  s.dependency 'Aspects'
  s.subspec 'Base' do |bd|
    bd.source_files = 'TestHook/**/*.{h,m,c}'
    bd.frameworks = 'Foundation','UIKit'
  end
  
end
