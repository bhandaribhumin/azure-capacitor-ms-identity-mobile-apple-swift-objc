
  Pod::Spec.new do |s|
    s.name = 'AdalAzureIosPlugin'
    s.version = '0.0.2'
    s.summary = 'this is custome plugin'
    s.license = 'null'
    s.homepage = 'https://github.com/bhandaribhumin/azure-capacitor-ms-identity-mobile-apple-swift-objc.git'
    s.author = 'bhumin'
    s.source = { :git => 'https://github.com/bhandaribhumin/azure-capacitor-ms-identity-mobile-apple-swift-objc.git', :tag => s.version.to_s }
    s.source_files = 'ios/Plugin/**/*.{swift,h,m,c,cc,mm,cpp}'
    s.ios.deployment_target  = '11.0'
    s.dependency 'Capacitor'
    s.dependency 'MSAL'
  end