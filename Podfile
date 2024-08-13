# Uncomment the next line to define a global platform for your project

# pod install --no-repo-update  更新Pods
 source 'https://github.com/CocoaPods/Specs.git'
# source 'https://cdn.cocoapods.org/'
install! 'cocoapods', :disable_input_output_paths => true
inhibit_all_warnings!
use_frameworks! :linkage => :static

post_install do |installer|
  # Fix warning: The iOS Simulator deployment target is set to x.x, but the range of supported deployment target versions for this platform is x.x to x.x. (in target 'xxx')
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      if config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'].to_f < 16.0
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '16.0'
      end
    end
  end
end

plugin 'cocoapods-jxedt'
options = {
    'all_binary': false, # 全部组件使用二进制。默认为false
    'binary_dir': '../_Prebuild', # 二进制文件的保存路径，'Pods/Pods.xcodeproj'文件的相对路径。默认为'../_Prebuild'
    'binary_switch': true, # 插件开关，设置为false则关闭插件二进制功能。默认为true
    'prebuild_job': true, # 开启编译任务，设置为false则不触发编译功能。默认为true
    'keep_source_project': false, # 保留源码的pods工程，方便查看源码，文件目录为Podfile文件同级目录下'Pods-Source'。默认为false
    'excluded_pods': [], # 排除binary的pods，是一个数组。默认是[]
#    'framework_header_search_enabled': true, # 开启binary的组件是否配置HEADER_SEARCH_PATH头文件搜索，兼容头文件引用的问题。默认为false
    'configurations': ['Release'], # 支持的configuration配置，可以写字符串'Debug'或'Release'，也可以写多个'['Debug', 'Release']'。默认为'Release'
    'xcframework': true, # 编译结果是否为xcframework。默认false
    'clean_build': true, # 编译的时候是否clean build。默认true
    'device_build_enabled': true, # 编译真机架构。默认true
    'simulator_build_enabled': true, # 编译模拟器架构。默认false
    'disable_resource_compilable_pods': false, # 禁止编译有特殊resource文件(xib、xcdatamodeld等)的pod。默认为false
    'build_args': {
        'default': ["ONLY_ACTIVE_ARCH=NO", "BUILD_LIBRARY_FOR_DISTRIBUTION=YES"],
        'device': ["ARCHS='arm64'"],
        'simulator': ["ARCHS='x86_64'"]
    }
}
cocoapods_jxedt_config(options)

target 'ImageWizard' do
  # Comment the next line if you don't want to use dynamic frameworks
  platform :ios, '16.0'
  # Pods for ImageWizard
  pod 'BBMetalImage'
  pod 'Harbeth', :git => 'https://github.com/yangKJ/Harbeth.git'
  pod 'SQLite.swift'
  pod 'SVProgressHUD'
  pod 'MetalPetal/Swift'
  pod 'TesseractOCRiOS'

end
