platform :ios, '9.0'

target 'BankexWallet' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  # Pods for BankexWallet
  #pod 'web3swift', :path => '../web3swift'
  pod 'web3swift', '<= 1.1.1'
  pod "SugarRecord/CoreData", '<= 3.1'
  pod 'QRCodeReader.swift', '~> 8.1.1'
  pod 'Popover'
  pod 'Amplitude-iOS', '~> 4.0.4'
  pod 'Firebase/Core'
  pod 'Firebase/DynamicLinks'
  pod 'Firebase/RemoteConfig'
  pod 'Firebase/Messaging'
  pod 'Firebase/Crash'
  pod 'ReachabilitySwift'
  pod 'Hero'
  pod 'SkeletonView'
  pod 'VisualEffectView'
  pod 'GrowingTextView', '0.6.1'

  target 'BankexWalletTests' do
    inherit! :search_paths
    pod 'KIF', :configurations => ['Debug']
  end

  target 'BankexWalletUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end


target 'Wallet Widget' do
    use_frameworks!
    pod 'Fabric'
    pod 'Crashlytics'
end
