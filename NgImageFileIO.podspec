Pod::Spec.new do |spec|
  spec.name         = 'NgImageFileIO'
  spec.version      = '1.1'
  spec.summary      = 'Simple objective-c ImageIO wrapper for iOS and Mac.'
  spec.homepage     = 'https://github.com/meiwin/NgImageFileIO'
  spec.author       = { 'Meiwin Fu' => 'meiwin@blockthirty.com' }
  spec.source       = { :git => 'https://github.com/meiwin/ngimagefileio.git', :tag => "v#{spec.version}" }
  spec.source_files = 'NgImageFileIO/*.{h,m}'
  spec.requires_arc = true
  spec.license      = { :type => 'MIT', :file => 'LICENSE' }
  spec.frameworks = 'Foundation', 'UIKit', 'MobileCoreServices', 'ImageIO'
  spec.ios.deployment_target = "5.0"
end