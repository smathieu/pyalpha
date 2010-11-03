'''
Created on 23 oct. 2010

@author: maximeboucher
'''
import xmlrpclib

s = xmlrpclib.ServerProxy('http://localhost:8000')

print s.system.listMethods()
print s.eval("if (1<3):")
print s.eval(' import sys')
print s.eval("else:")
print s.eval("    x=2")
print s.eval('')
print s.expectingMoreInput()
print s.eval('x')
print s.expectingMoreInput()
