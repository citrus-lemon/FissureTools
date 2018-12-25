require 'mkmf'

File.open(File.expand_path('constant.h', __dir__), 'w') do |file|
  def header_path(framework, header)
    "/Applications/Xcode.app/Contents" \
    "/Developer/Platforms/MacOSX.platform" \
    "/Developer/SDKs/MacOSX.sdk" \
    "/System/Library/Frameworks/#{framework}.framework" \
    "/Versions/Current/Headers/" \
    "#{header}"
  end
  constant_header = File.readlines \
    header_path "SystemConfiguration", "SCSchemaDefinitions.h"
  constant_header.grep(/\s*\*\s{2,}kSC(\w+)\s+"(.*?)"/).map do |key|
    key =~ /\s*\*\s{2,}kSC(\w+)\s+"(.*?)"/
    const, _ = $1, $2
    if constant_header.grep(/const CFStringRef kSC#{const}\s+API_AVAILABLE/).empty?.!
      file.puts "ADD_CONST(\"#{const}\", kSC#{const})"
    end
  end
  constant_header = File.readlines \
    header_path "CFNetwork", "CFProxySupport.h"
  constant_header.grep(/CFStringRef kCF(\w+)\s*CF_AVAILABLE/).map do |key|
    key =~ /CFN_EXPORT const CFStringRef kCF(\w+)\s*CF_AVAILABLE/
    file.puts "ADD_CONST(\"#{$1}\", kCF#{$1})"
  end
end

create_makefile 'SystemConfig/binding'
