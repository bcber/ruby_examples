# encoding: utf-8
# #验证如下一些信息：函数参数传递，变参
#
#结论：
# 如果变参后面还有一个参数，那么就类似于正则匹配一样，进行贪婪模式匹配，把最后一个参数流出来

#require 'pp'

def p2(a,*b)
  puts a
  puts b.inspect
end

def p3(a,*b,c)
  puts a
  puts b.inspect
  puts c
end

p2('a','b','c')
# a
# ["b", "c"]
p3('a','b','c')
#a
#["b"]
#c