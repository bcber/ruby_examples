# encoding: utf-8
# #验证如下一些信息：1.类的初始化函数是否会自动调用父类的初始化函数
#
#结论：
# * 不显示调用super的话，不会自动调用父类的初始化函数
# * super不带参数的话是表示本类函数所有接受到的参数都往上层传递
#require 'pp'

class A
	def initialize
		puts "A initialize"
	end
	def print
		puts "A"
	end
end

class B < A
	def initialize(call_super=false)
		puts "B initialize"
		super() if call_super
	end
	def print
		puts "B"
	end
end

a = A.new
puts a.class.superclass
puts a.class.superclass.superclass
puts a.class.superclass.superclass.superclass
puts BasicObject.methods
#puts a.methods
puts "=============="
b = B.new
b1 = B.new(true)
#puts b.methods
