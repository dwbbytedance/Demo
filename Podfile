source 'https://cdn.cocoapods.org/'
source 'https://github.com/CocoaPods/Specs.git'
install! 'cocoapods', :disable_input_output_paths => true
platform :ios, '10.0'

target 'Demo' do
  pod 'RangersAppLog','4.4.0'
  pod 'RxDataSources', '~> 4.0'
  pod 'TestHook',:path => '.'
end


post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      if config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'].to_f < 10.0
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '10.0'
      end
    end
  end
  
end
