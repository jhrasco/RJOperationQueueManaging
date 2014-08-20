Pod::Spec.new do |s|
  s.name         = "RJOperationQueueManaging"
  s.version      = "1.0.0"
  s.summary      = 'Networking library for iOS.'
  s.homepage     = "https://github.com/jhrasco/RJOperationQueueManaging"
  s.license      = "MIT"
  s.author       = { "Ryan Jake Castro" => "jcastro@stratpoint.com" }
  # s.platform   = :ios
  s.source       = { :git => "https://github.com/jhrasco/RJOperationQueueManaging.git", :tag => s.version.to_s }
  s.source_files  = "operationQueueManagingDemo/RJOperationQueueManaging"
  s.requires_arc = true
end
