Pod::Spec.new do |spec|
  spec.name                       = 'Palette'
  spec.version                    = '2.0.0'
  spec.summary                    = 'Color palette generation from image written in Swift'
  spec.homepage                   = 'https://github.com/galandezzz/Palette'
  spec.license                    = 'MIT'
  spec.author                     = { 'Egor Snitsar' => 'fearum@icloud.com' }
  spec.ios.deployment_target      = '12.0'
  spec.osx.deployment_target      = '10.13'
  spec.tvos.deployment_target     = '12.0'
  spec.visionos.deployment_target = '1.0'
  spec.watchos.deployment_target  = '4.0'
  spec.swift_version              = '5.5'
  spec.source                     = { :git => 'https://github.com/galandezzz/Palette.git', :tag => "v#{spec.version}" }
  spec.source_files               = 'Sources/**/*'
end
