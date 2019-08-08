Pod::Spec.new do |s|
  s.name                    = File.basename(__FILE__).chomp(".podspec")
  s.version                 = '1.0.0'
  s.summary                 = 'Image colors palette generation'
  s.homepage                = 'https://github.com/galandezzz/Palette'
  s.license                 = 'MIT'
  s.authors                 = { 'Egor Snitsar' => "fearum@icloud.com" }
  s.swift_versions          = '5.0'

  s.source                  = { :git => 'https://github.com/galandezzz/Palette.git', :tag => "v#{s.version}" }

  s.ios.deployment_target   = '9.0'

  s.source_files            = 'Source'
end
