Pod::Spec.new do |s|

  s.name         = "SWMultiController"

  s.version      = "2.1.0.1"

  s.homepage      = 'https://github.com/zhoushaowen/SWMultiController'

  s.ios.deployment_target = '8.0'

  s.summary      = "可以左右滑动的多控制器,支持屏幕旋转和storyboard"

  s.license      = { :type => 'MIT', :file => 'LICENSE' }

  s.author       = { "Zhoushaowen" => "348345883@qq.com" }

  s.source       = { :git => "https://github.com/zhoushaowen/SWMultiController.git", :tag => s.version }
  
  s.source_files  = "SWMultiControllerDemo/SWMultiController/*.{h,m}"

  s.dependency 'ReactiveObjC'
  s.dependency 'MJRefresh'
  
  s.requires_arc = true

end