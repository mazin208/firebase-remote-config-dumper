# Firebase Remote Config Fetcher

This Ruby script retrieves Firebase Remote Config data by extracting the `google_api_key` and `google_app_id` from an XML file (e.g., `strings.xml`). It can optionally run through BurpSuite proxy if provided as an argument.

## Features
- Fetch Firebase Remote Config data with minimal setup.
- Optional BurpSuite proxy support (in the format `localhost:8080`) .

## Usage
1. Decompile your APK file and check that `strings.xml` file exist `res/values/strings.xml`.
2. Run the script with or without a proxy.

### Running the Script
Without a proxy:
```bash
ruby firebase-fetcher.rb
```
With a proxy:
```bash
ruby firebase-fetcher.rb --proxy 127.0.0.1:8080
```

### **Requirements**
* Ruby
* nokogiri
* httparty gem
```bash
gem install nokogiri httparty
```

## Credits
This script was inspired by the article Dump Firebase Remote Config using API.
https://blog.deesee.xyz/android/automation/2019/08/03/firebase-remote-config-dump.html
