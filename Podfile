source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '7.0'

inhibit_all_warnings!

def import_pods
    pod 'AFNetworking', '~> 1.3.2'
    pod 'DCKeyValueObjectMapping'
    pod 'ISO8601DateFormatter', '~> 0.7'
    pod 'MRProgress', '~> 0.8.0'
    pod 'Masonry', '~> 0.5.3'
    pod 'PSAlertView', '~> 1.1'
    pod 'GVUserDefaults', '~> 0.9.4'
    pod 'Appirater', '~> 2.0.2'
    pod 'NewRelicAgent'
    pod 'MiawKit'
    pod 'FormatterKit', '~> 1.7.1'
    pod 'KeepLayout', :git => 'https://github.com/iMartinKiss/KeepLayout.git'
    pod 'CrashlyticsFramework'
    pod 'SDWebImage', '~>3.6'
    pod 'Reveal-iOS-SDK', :configurations => ['Debug']
end

target 'BeMyEyes' do
    import_pods
end

target 'BeMyEyes Tests' do
    import_pods
    pod 'FBSnapshotTestCase'
end