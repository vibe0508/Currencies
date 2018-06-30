# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'Currencies' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Currencies

  pod 'ReactiveCocoa', :git => 'git@github.com:ReactiveCocoa/ReactiveCocoa.git', :branch => 'xcode-10'

  post_install do |installer|

      installer.pods_project.targets.each do |target|
          if target.name == 'ReactiveCocoa'
              target.build_configurations.each do |config|
                  config.build_settings['SWIFT_VERSION'] = '4.1'
              end
          end
      end
  end

end
