#!/usr/local/env ruby

require 'nokogiri'
require 'open-uri'
require 'semantic'
require 'json'
require 'set'
require 'csv'

PAGE_URL_TEMPLATE = 'http://facebook.github.io/react-native/releases/%s/docs/getting-started.html'
RN_MIN_VERSION = '0.18'

CHECK_MARK = "\u2713"
CROSS_MARK = "\u2715"

class RNVersion
  def initialize(version)
    version = version.to_s
    components = version.split('.')
    components_len = components.length
    if components_len > 3
      version = components[0..1].join('.')
    elsif components_len == 2
        version += '.0'
    end
    @version = Semantic::Version.new version
  end
  
  def next_minor
    "#{@version.major}.#{@version.minor+1}"
  end
  
  def next_major
    "#{@version.major+1}.#{@version.minor}"
  end
  
  def version
    "#{@version.major}.#{@version.minor}"
  end
end

def extract_title(ele)
  if /h\d+/i.match(ele.children.first.name) != nil
    ele.children.first.inner_text
  end
end

def extract_list(ele)
  ele.xpath('ul/li/a').map { |e| 
    e.inner_text
  }
end

contents = {}
all_components = Set.new([])
all_apis = Set.new([])

last_version = nil
last_not_found = false
version = RN_MIN_VERSION

while true do
  begin
    doc = Nokogiri::HTML(open(PAGE_URL_TEMPLATE % [version]))
  rescue OpenURI::HTTPError => e
    next if e.message != '404 Not Found'
    break if last_not_found && RNVersion.new(last_version).next_major == RNVersion.new(version).version
    last_not_found = true
    last_version = version
    version = RNVersion.new(version).next_major
    next
  end
  
  results = {}
  doc.css("div.nav-docs-section").each do |ele|
    title = extract_title(ele)
    next if title == nil
    title = title.downcase
    next if not ['components', 'apis'].include?(title)
    array = extract_list(ele)
    results = results.merge(Hash[title, array])
    case title
    when 'components'
      all_components.merge(array)
    when 'apis'
      all_apis.merge(array)
    end
  end
  contents = contents.merge(Hash[version, results])
  
  last_version = version
  version = RNVersion.new(version).next_minor
end

all_components = all_components.sort
all_apis = all_apis.sort

def do_exists(whole_set, compare)
  whole_set.map { |e| 
    if compare.include?e
      CHECK_MARK
    else
      CROSS_MARK
    end
  }
end

CSV.open('rn-components-evolution.csv', 'wb') do |csv|
  csv << ['Version'] + all_components
  contents.each do |version, results| 
    csv << [version] + do_exists(all_components, results['components'])
  end
end

CSV.open('rn-apis-evolution.csv', 'wb') do |csv|
  csv << ['Version'] + all_apis
  contents.each do |version, results| 
    csv << [version] + do_exists(all_apis, results['apis'])
  end
end