platform :ios, '11.0'


def main_pods
  #Layout
  pod 'SnapKit'
  
  #Tool
  pod 'SwiftLint'
  
  #Networking
  pod 'Magpie', :git => 'https://github.com/Hipo/magpie.git'
  
  #Persistance
  pod 'KeychainAccess'
  
  #Date
  pod 'SwiftDate'
  
  #UI
  pod 'SVProgressHUD'
  pod 'Charts'
  pod 'lottie-ios'
  pod 'NotificationBannerSwift'
  
  #Analytics
  pod 'Firebase/Core'
  pod 'Fabric'
  pod 'Crashlytics'
end

target 'algorand' do

  use_frameworks!
  
  main_pods
end

target 'algorand-staging' do
  
  use_frameworks!
  
  main_pods
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['EXPANDED_CODE_SIGN_IDENTITY'] = ""
            config.build_settings['CODE_SIGNING_REQUIRED'] = "NO"
            config.build_settings['CODE_SIGNING_ALLOWED'] = "NO"
        end
    end
end
