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
