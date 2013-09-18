# encoding: utf-8
#
# 检查goagent php server，用到了一些编程技巧
require 'net/http'
require 'uri'
require 'zlib'
require 'hexdump'

if !ARGV[0]
	puts "Usage : check.rb <url>"
	exit
end

@uri = URI(ARGV[0])

def parse_v2_content(body)
	compressed = body[0].to_s
	rawdata = body[1..-1]
	if compressed == '1'
		rawdata = Zlib::Inflate.inflate(rawdata)
	end
	code,hlen,clen = rawdata[0..11].unpack('N3')
	header = rawdata[12, hlen]
	content = rawdata[12+hlen, clen]
	{'code' => code, 'content' => content}
end

def do_request_v2(url)
	params = {'url'=>url, 'method'=>'GET', 'headers'=>'', 'payload'=>''}
	query = params.map { |k,v| '%s=%s' % [k, v.each_byte.map { |b| b.to_s(16) }.join] }.join('&') #<<< 重点
	query = Zlib::Deflate.deflate(query)
	Net::HTTP.start(@uri.host, @uri.port) {|http|
	  res = http.post(@uri.path, query)
	  body = res.body
	  content = parse_v2_content(body)
	  content
	}
end

def do_request_v3(url)
	u = URI(ARGV[0])
	metadata = "G-Method:GET\nG-Url:#{url}\nHost: #{u.host}\n\n"
	metadata = Zlib::Deflate.deflate(metadata)
	metadata = metadata[2..-5]
	app_payload = "\x00#{[metadata.size].pack("C")}#{metadata}"
	Net::HTTP.start(@uri.host, @uri.port) {|http|
	  res = http.post(@uri.path, app_payload)
	  res.body
	}
end

def check_version(res)
	code = res.code.to_i
	body = res.body
	if code==200 and body[0,2] == '-f'
		puts "goagent 2.x without password"
		#puts do_request_v2 "http://www.qq.com"
	elsif code == 200 and body[0,2] == '1x'
		res = do_request_v2 "http://www.qq.com"
		#puts res['content']
		if res['code'].to_i == 200
			puts "goagent 2.x without password"
		elsif res['code'].to_i == 403
			puts "goagent 1.x [WITH] password"
		else
			puts "Unknown"
		end
	elsif code==200 and body.include?('502 Urlfetch Error')
		puts "goagent 3.x without password"
		#puts do_request_v3 "http://www.qq.com"
	elsif code==403 and body.include?('403 Forbidden')
		puts "goagent 3.x [WITH] password"
	else
		puts "not goagent server"
	end
end

Net::HTTP.start(@uri.host, @uri.port) {|http|
  res = http.post(@uri.path, '1')
  check_version(res)
}

