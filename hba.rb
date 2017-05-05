def usage
  <<~USAGE
    =====================
    HoneyBadger Analyser
    =====================

    This script aims to help developers narrow down on frequently occurring HoneyBadger errors.
    It shows you the data in different groupings, sorted by frequency and value in descending order.


    Usage:
    1. Export an error JSON file from HoneyBadger.
    2. Run this script like "ruby hba.rb <path/to/the/file>"
  USAGE
end

require 'JSON'

# tree is a Hash
# path is an Array of keys that represents the position of an element in the hash
def find_in_tree(tree, path)
  t = tree.clone
  path.each do |key|
    t = t[key]
  end
  t
end


def show_table(errs, path_string)
  path = path_string.split('/')
  title = path.last
  values = errs.map { |err| find_in_tree(err, path) }
  puts '--------------------------------------------------------------------------------------------------------------------------------'
  puts title.upcase
  puts '--------------------------------------------------------------------------------------------------------------------------------'
  rows_with_count = values.uniq.map{ |value| [ values.select{|v| value == v}.count, value ] }
  sorted_rows = rows_with_count.sort_by{|count, value| [count, value.inspect]}.reverse
  sorted_rows.each do |row|
    puts "#{row[0]}\t#{row[1] || '-'}"
  end
  puts "\n\n"
end


def show_all(json_file_path)
  lines = File.read(json_file_path).split("\n")
  errs = lines.map{|line| JSON.parse line}
  system('clear')
  %w(message request/cgi_data/HTTP_USER_AGENT request/url request/context component action request/cgi_data/HTTP_REFERRER request/params).each do |path_string|
    show_table(errs, path_string)
  end
  puts "\JSON structure:\n#{JSON.pretty_generate(JSON.parse lines.first)}"
end

if ARGV.length==1
  show_all ARGV[0]
else
  puts usage
end
