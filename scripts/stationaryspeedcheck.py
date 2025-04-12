"""
Script to better understand false speed readings from stationary Garmin devices.

Hopefully to improve this algorithm:
https://github.com/thisdougb/SinceStopped/blob/1b583755079b8ce4a75db4102aff6fe102e6a5ce/source/SinceStoppedView.mc#L48

I will add a .fit parser to the Python script, but for now:

1. Start an activity on your Garmin, while leaving is stationary
2. If SinceStopped registers some time, then upload .fit file to https://www.fitfileviewer.com
2. download Records section to .csv
3. cat Downloads/2025-04-12-10-24-18-stationary-record.csv | cut -f7 -d',' > dev/Garmin/testfitfiles/exampleofstationaryspeeds.txt

"""

test_file = "exampleofstationaryspeeds.txt"

jitterCount = 0

for line in open(test_file):
    li=line.strip()

    if li.startswith("#"):
        continue

    # if there is speed it may or may not be fake, so we try and reduce the jitter count
    if float(li.rstrip()) > 0.0:
        if jitterCount > 0:
            jitterCount=jitterCount-1
    
    # if there is a no-speed reading then we may be stopped, increase jitter count
    if float(li.rstrip()) == 0.0:
        if jitterCount <= 20:
            jitterCount=jitterCount+1
    
    if jitterCount > 0:
        # we have registered more no-speed and speed readings
        print("[STOP] ", end='')
        for j in range (jitterCount):
            print('*', end='')
        print()

    if jitterCount == 0:
        # we have registered more speed readings that no-speed readings
        print("[MOVE] ", end='')
        for j in range (jitterCount):
            print('*', end='')
        print()