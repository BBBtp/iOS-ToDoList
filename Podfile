# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'ToDoList' do
  
  use_frameworks!
  pod 'SnapKit'
  pod 'SkeletonView'
  pod 'SwiftGen'

  target 'ToDoListTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'ToDoListUITests' do
    # Pods for testing
  end

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
    end
  end
end
