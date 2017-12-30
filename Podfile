# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'Burst Dissertation' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # ignore all warnings from all pods
  inhibit_all_warnings!

  # Pods for Burst Dissertation
   pod ‘Firebase/Core’
   pod ‘Firebase/Database’
   pod ‘Firebase/Auth’
   pod ‘Firebase/Storage'
   pod 'Firebase/Messaging'
   pod 'SCLAlertView'
   pod 'NMessenger'

  target 'Burst DissertationTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'Burst DissertationUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.2'
        end
    end
end
