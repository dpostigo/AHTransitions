Pod::Spec.new do |s|
  s.name         = "AHTransitions"
  s.version      = "0.0.1"
  s.summary      = "AHTransitions"
  s.homepage     = "http://www.alfiehanssen.com"
  s.license      = 'BSD'
  s.author       = { "Dani Postigo" => "dani@firstperson.is" }


  s.source       = { :git => "https://github.com/dpostigo/AHTransitions.git", :tag => s.version.to_s }
  s.platform     = :ios, '7.0'
  s.frameworks   = 'Foundation', 'QuartzCore'
  s.requires_arc = true

  s.source_files = 'AHTransitions/**/*.{h,m}'

  
end
