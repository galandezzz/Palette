Pod::Spec.new do |spec|
  spec.name           = 'Palette'
  spec.version        = '1.0.5'
  spec.summary        = 'Color palette generation from image written in Swift'
  spec.homepage       = 'https://github.com/galandezzz/ios-Palette'
  spec.license        = 'MIT'
  spec.author         = { 'Egor Snitsar' => 'fearum@icloud.com' }
  spec.platform       = :ios, '9.0'
  spec.swift_version  = '5.0'
  spec.source         = { :git => 'https://github.com/galandezzz/ios-Palette.git', :tag => "v#{spec.version}" }
  spec.source_files   = 'Source/*/*.swift'
end
