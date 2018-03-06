project 'Test00008.xcodeproj'
workspace 'Test00008.xcworkspace'
platform :ios, '11.2'
inhibit_all_warnings!

source 'https://github.com/artsy/Specs.git'
source 'https://github.com/CocoaPods/Specs.git'

use_frameworks!

def shared_pods
    pod 'MZDownloadManager', :path => 'Test00008/..'
end

target 'Test00008' do
    shared_pods
end

target 'Test00008Tests' do
    shared_pods
end

target 'Test00008UITests' do
    shared_pods
end
