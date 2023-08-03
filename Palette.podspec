Pod::Spec.new do |spec|
  spec.name           = 'Palette'
  spec.version        = '1.0.6'
  spec.summary        = 'Color palette generation from image written in Swift'
  spec.homepage       = 'https://github.com/tqtifnypmb/Palette'
  spec.license        = 'MIT'
  spec.author         = { 'Egor Snitsar' => 'fearum@icloud.com' }
  spec.ios.deployment_target = '10.0'
  spec.osx.deployment_target = '10.12'
  spec.swift_version  = '5.0'
  spec.source         = { :git => 'https://github.com/tqtifnypmb/Palette', :tag => "v#{spec.version}" }
  spec.source_files   = 'Source/*', 'Source/*/*'
end
