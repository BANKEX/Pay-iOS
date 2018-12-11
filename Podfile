platform :ios, '9.0'

target 'BankexWallet' do
  use_frameworks!
  pod 'web3swift', '<= 1.1.1'
  pod "SugarRecord/CoreData", '<= 3.1'
  pod 'Popover'
  pod 'Amplitude-iOS', '~> 4.0.4'
  pod 'Firebase/Core'
  pod 'Firebase/DynamicLinks'
  pod 'Firebase/RemoteConfig'
  pod 'Firebase/Messaging'
  pod 'ReachabilitySwift'
  pod 'SkeletonView'
  pod 'VisualEffectView'
  pod 'GrowingTextView', '0.6.1'
  pod 'SDWebImage', '~> 4.0'
  pod 'Fabric'
  pod 'Crashlytics'

  target 'BankexWalletTests' do
    inherit! :search_paths
    pod 'KIF', :configurations => ['Debug']
  end

  target 'BankexWalletUITests' do
    inherit! :search_paths
  end

end


target 'Wallet Widget' do
    use_frameworks!
    pod 'Fabric'
    pod 'Crashlytics'
end
