platform :ios, '9.0'
inhibit_all_warnings!


target 'BankexWallet' do
  use_frameworks!
  pod 'web3swift', '<= 1.1.1'
  pod "SugarRecord/CoreData", '<= 3.1'
  pod 'Popover', '~> 1.2.0'
  pod 'Amplitude-iOS', '~> 4.0.4'
  pod 'Firebase/Core', '~> 5.14.0'
  pod 'Firebase/DynamicLinks', '~> 5.14.0'
  pod 'Firebase/RemoteConfig', '~> 5.14.0'
  pod 'Firebase/Messaging', '~> 5.14.0'
  pod 'ReachabilitySwift', '~> 4.2.1'
  pod 'SkeletonView', '~> 1.4'
  pod 'VisualEffectView', '~> 3.1.0'
  pod 'GrowingTextView', '~> 0.6.1'
  pod 'SDWebImage', '~> 4.0'
  pod 'Fabric', '~> 1.7.13'
  pod 'Crashlytics', '~> 3.10.9'

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
    pod 'Fabric', '~> 1.7.13'
    pod 'Crashlytics', '~> 3.10.9'
end


pods_with_specific_swift_versions = {
  'GrowingTextView' => '4.2',
}

post_install do |installer|
    installer.pods_project.targets.each do |target|
      if pods_with_specific_swift_versions.key? target.name
        swift_version = pods_with_specific_swift_versions[target.name]
        target.build_configurations.each do |config|
          config.build_settings['SWIFT_VERSION'] = swift_version
        end
      end
    end
end
