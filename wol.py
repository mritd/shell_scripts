#!/usr/bin/env python
#coding=utf-8
 
import socket, sys
import struct
def to_hex_int(s):
    return int(s.upper(), 16)
  
dest = ('192.168.1.255', 9)
  
if len(sys.argv) < 2:
 print("usage: %s <MAC Address to wakeup>" % sys.argv[0])
 sys.exit()
  
mac = sys.argv[1]
  
spliter = ""
if mac.count(":") == 5: spliter = ":"
if mac.count("-") == 5: spliter = "-"
  
if spliter == "":
 print("MAC address should be like XX:XX:XX:XX:XX:XX / XX-XX-XX-XX-XX-XX")
 sys.exit()
  
parts = mac.split(spliter)
a1 = to_hex_int(parts[0])
a2 = to_hex_int(parts[1])
a3 = to_hex_int(parts[2])
a4 = to_hex_int(parts[3])
a5 = to_hex_int(parts[4])
a6 = to_hex_int(parts[5])
addr = [a1, a2, a3, a4, a5, a6]
  
packet = chr(255) + chr(255) + chr(255) + chr(255) + chr(255) + chr(255)
  
for n in range(0,16):
 for a in addr:
  packet = packet + chr(a)
  
packet = packet + chr(0) + chr(0) + chr(0) + chr(0) + chr(0) + chr(0)
  
s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
s.setsockopt(socket.SOL_SOCKET,socket.SO_BROADCAST,1)
s.sendto(packet,dest)
  
print("WOL packet %d bytes sent !" % len(packet))
