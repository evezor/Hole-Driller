#This script generates GCODE for drilling the holes in the tubes.
#Units are in mm


fOut = "DRILL.gcode"

fo = open(fOut,'w')

START_CODE = """
;This is the start GCODE
G1 E0 F2000
G1 E100
G1 E0 F2000

G1 Z195 F600
G1 X52.54 Y105.85 F2000
"""

END_CODE = """
;This is the END GCODE
G1 Z195 E0 F600
M655
"""

NUM_PECKS = 6
PECK_DEPTH = .45
LAST_PECK = 3
DRILL_CLEARANCE = 7
TRAVEL_SPEED = 1600
DRILL_SPEED = 500
NUM_HOLES = 24
DRILL_ZERO = 152.4

TOP_SKEW = 2.7/12   #this should be the top skew divided by 12
BOTTOM_SKEW = -2.7/12

BOTTOM_OFFSET = 1.7


HOLE_LOCATIONS = (
[52.54,105.85],
[50.452,106.718],
[48.423,107.432],
[46.456,107.993],
[44.552,108.403],
[42.713,108.665],
[40.943,108.777],
[39.243,108.741],
[37.618,108.557],
[36.07,108.224],
[34.603,107.74],
[33.22,107.106],
[32.562,106.731],
[33.9,107.442],
[35.326,108.001],
[36.834,108.409],
[38.421,108.668],
[40.084,108.778],
[41.819,108.739],
[43.624,108.553],
[45.496,108.217],
[47.432,107.731],
[49.43,107.094],
[51.488,106.304])


def moveToNextHole(HOLE_NUM):
    fo.write("G1 X")
    fo.write(str(HOLE_LOCATIONS[HOLE_NUM][0]))
    fo.write(" Y")
    fo.write(str(HOLE_LOCATIONS[HOLE_NUM][1]))
    fo.write(" F200\n")

def drillToDepth(PECK_NUM,HOLE_NUM):
    fo.write("G1 Z")
    if (HOLE_NUM < 12):  #THIS IS FOR DRILLING THE FRONT SIDE
        fo.write(str("%.2f" % (DRILL_ZERO + (TOP_SKEW * (HOLE_NUM+1)))))
        fo.write(" F600\nG1 Z")
        if PECK_NUM == (NUM_PECKS-1):
            print("1")
            fo.write(str("%.2f" % (DRILL_ZERO - ((PECK_NUM+1)*PECK_DEPTH) - LAST_PECK + (TOP_SKEW*(HOLE_NUM+1)))))
        else:
            print("2")
            fo.write(str("%.2f" % (DRILL_ZERO - ((PECK_NUM+1)*PECK_DEPTH) + (TOP_SKEW*(HOLE_NUM+1)))))
        fo.write(" F150\nG1 Z")
        fo.write(str("%.2f" % (DRILL_ZERO + DRILL_CLEARANCE)))
        fo.write(" F606\n")
    else:  #THIS IS FOR DRILLING THE BACK SIDE
        fo.write(str("%.2f" % (DRILL_ZERO + (BOTTOM_SKEW * (HOLE_NUM-12)) + BOTTOM_OFFSET)))
        fo.write(" F600\nG1 Z")
        if PECK_NUM == (NUM_PECKS-1):
            print("3")
            fo.write(str("%.2f" % (DRILL_ZERO + BOTTOM_OFFSET - ((PECK_NUM+1)*PECK_DEPTH) + (BOTTOM_SKEW * (HOLE_NUM-12)) - LAST_PECK)))
        else:
            print("4")
            fo.write(str("%.2f" % (DRILL_ZERO + BOTTOM_OFFSET - ((PECK_NUM+1)*PECK_DEPTH) + (BOTTOM_SKEW * (HOLE_NUM-12)))))
        fo.write(" F150\nG1 Z")
        fo.write(str("%.2f" % ((DRILL_ZERO + DRILL_CLEARANCE) + BOTTOM_OFFSET)))
        fo.write(" F600\n")

    
    #START ROUTINE
fo.write(START_CODE)

for i in range(NUM_PECKS):
    for j in range(NUM_HOLES):
        moveToNextHole(j)
        if j == 12:
            fo.write("G1 E35 F2000\n")
        elif j == 0:
            fo.write("G1 E0 F2000\n")
        drillToDepth(i,j)
    print("next line")
fo.write(END_CODE)    


fo.close()    
      
