# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

def shared_pods
  pod 'Alamofire', '~> 5.5'
  pod 'AlertToast'
  pod 'SwiftyJSON', '~> 4.0'
  pod "PromiseKit", "~> 6.8"
end

target 'Covet' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  shared_pods

  # Pods for Covet
  pod 'FirebaseUI', '~> 8.0'       # Pull in all Firebase UI features

  # Add the Firebase pod for Google Analytics
  pod 'Firebase/Analytics'

  # For Analytics without IDFA collection capability, use this pod instead
  # pod ‘Firebase/AnalyticsWithoutAdIdSupport’

  # Add the pods for any other Firebase products you want to use in your app
  # For example, to use Firebase Authentication and Cloud Firestore
  pod 'Firebase/Auth'
  
  target 'CovetTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'CovetUITests' do
    # Pods for testing
  end
  
end

target 'CovetIt' do
  use_frameworks!
  shared_pods
  pod 'SDWebImage', '~> 5.0'
  pod 'SwiftSoup'
  pod 'Socket.IO-Client-Swift', '~> 16.0.1'
end
