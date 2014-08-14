Pod::Spec.new do |s|
  s.name         = "RJOperationQueueManaging"
  s.version      = "0.0.1"
  s.homepage     = "https://bitbucket.org/rjakecastro/rjoperationqueuemanaging"
  s.license      = "MIT"
  s.author       = { "Ryan Jake Castro" => "jcastro@stratpoint.com" }
  # s.platform   = :ios
  s.source       = { :git => "https://rjakecastro@bitbucket.org/rjakecastro/rjoperationqueuemanaging.git", :tag => "0.0.1" }
  s.source_files  = "RJOperationQueueManaging/operationQueueManagingDemo/RJOperationQueueManaging"
  s.requires_arc = true
end
