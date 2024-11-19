require 'nokogiri'
require 'httparty'
require 'json'
require 'optparse'

# Set default proxy option
options = {
  proxy: nil
}

# Parse the single proxy argument
OptionParser.new do |opts|
  opts.on("--proxy PROXY", "Set the proxy in the format 'address:port' (e.g., 'localhost:8080')") do |proxy|
    options[:proxy] = proxy
  end
end.parse!

def get_string_value(xml, setting_name)
  value = xml.xpath("/resources/string[@name='#{setting_name}']").first
  unless value.nil? || value.content.empty?
    puts "[+] Found value for '#{setting_name}': #{value.content}'"
    value.content
  else
    puts "[-] No value found for '#{setting_name}'"
  end
end

strings_path = "res/values/strings.xml"
if File.exist?(strings_path)
  xml = File.open(strings_path) { |f| Nokogiri::XML(f) }
  google_api_key = get_string_value(xml, 'google_api_key')
  google_app_id = get_string_value(xml, 'google_app_id')
  if google_app_id.nil? || google_api_key.nil?
    puts "[-] Missing 'google_api_key' or 'google_app_id' values. Exiting."
    exit
  end

  project_id = google_app_id.split(':')[1]
  puts '[*] Recovering Firebase Remote Config'
  
  # Build HTTParty options
  httparty_options = {
    body: JSON.generate(appId: google_app_id, appInstanceId: 'required_but_unused_value'),
    headers: { 'Content-Type' => 'application/json' },
    verify: false  # Disable SSL verification
  }

  # If proxy option is provided, split it into address and port
  if options[:proxy]
    proxy_addr, proxy_port = options[:proxy].split(':')
    httparty_options[:http_proxyaddr] = proxy_addr
    httparty_options[:http_proxyport] = proxy_port.to_i
    puts "[*] Using proxy at #{proxy_addr}:#{proxy_port}"
  else
    puts "[*] No proxy specified, connecting directly"
  end

  # Send the request with error handling
  begin
    response = HTTParty.post("https://firebaseremoteconfig.googleapis.com/v1/projects/#{project_id}/namespaces/firebase:fetch?key=#{google_api_key}",
                             httparty_options)

    puts "[+] Response received:"
    puts response.body
  rescue StandardError => e
    puts "[-] Error occurred: #{e.message}"
  end
else
  puts "[-] XML file not found at path: #{strings_path}"
end
