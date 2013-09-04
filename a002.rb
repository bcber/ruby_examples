# encoding: utf-8
# #验证如下一些信息：method_missing是class method还是instance method
#
#结论：
# 是实例方法而非类方法，这里的示例应该是错的：
# * http://technicalpickles.com/posts/using-method_missing-and-respond_to-to-create-dynamic-methods/
#require 'pp'

class A
	def initialize
		puts "A initialize"
	end
	def print
		puts "A"
	end
	def method_missing(name, *args, &block)   
		puts "call "+name.to_s
	end
end

class B
	def initialize
		puts "B initialize"
	end
	def print
		puts "B"
	end

	def self.method_missing(name, *args, &block)   
		puts "call "+name.to_s
	end
end

a = A.new
puts a.respond_to? :method_missing
puts a.abc


puts "=============="

b = B.new
puts b.respond_to? :method_missing
puts b.abc
