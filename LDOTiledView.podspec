Pod::Spec.new do |s|
  s.name             = "LDOTiledView"
  s.version          = "1.0.0"
  s.summary          = "Makes CATiledLayer simple to use."

  s.description      = <<-DESC
There is no better way to display huge images than CATiledLayer. However it can be a tricky to use.
LDOTiledView does the heavy lifing, handles it quirks and provides a minimal and easy to use interface.
                       DESC

  s.homepage         = "https://github.com/lurado/LDOTiledView"
  s.screenshots      = "https://github.com/lurado/LDOTiledView/blob/master/Screenshots/LDOTiledView.png?raw=true"
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { "Julian Raschke und Sebastian Ludwig GbR" => "info@lurado.com" }
  s.source           = { :git => "https://github.com/lurado/LDOTiledView.git", :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = "LDOTiledView/Classes/**/*"
end
