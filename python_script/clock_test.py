import time
  
# Get the epoch
obj = time.gmtime()
startTime = time.time()
epoch = time.asctime(obj)
print("epoch is:", epoch)
  
# Get the time in seconds
# since the epoch
time_sec = time.time()

# Print the time 
print("Time in seconds since the epoch:", time_sec)
#
#string = "hello world"
#print(string[0:4] == "hell")

while True:
  print(round(time.time() -startTime, 3))
  time.sleep(0.1)