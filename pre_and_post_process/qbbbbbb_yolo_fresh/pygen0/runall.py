# coding=utf-8
import os,sys
# loadimage()
os.system("gcc -o testrunall0 loadimg.c -lm")
os.system("./testrunall0")

# head_short
os.system("gcc -o testrunall1 head_short.c -lm")
os.system("./testrunall1")

# sort_input
os.system("gcc -o testrunall2 sort_input.c -lm")
os.system("./testrunall2")

# padchannel
os.system("gcc -o testrunall3 padchannel.c -lm")
os.system("./testrunall3")
