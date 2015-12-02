#!/usr/bin/python3
import sys

def echoLines(n):
    for i in range(1, n + 1):
        print('XxXxXxXxXxXxXxXxXxXxXxXxXxXxXxXxXxXxXxXxXxXxXxXxXxXxXxXxXxXxXxXxXxXxXxXxXxXxXxXx', i)

echoLines(int(sys.argv[1]))
