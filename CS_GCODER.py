#This script generates GCODE for drilling the holes in the tubes.
#Units are in mm


fOut = "CS.gcode"

fo = open(fOut,'w')

START_CODE = """
;This is the start GCODE
G1 Z195 F600
G1 E1
G1 X101.37 Y-69.52 F2000

"""

END_CODE = """
;This is the END GCODE
G1 Z165
G1 E0 F2000
M655

"""

NUM_PECKS = 2
PECK_DEPTH = .25
LAST_PECK = .12
DRILL_CLEARANCE = 7
TRAVEL_SPEED = 1600
DRILL_SPEED = 500
NUM_HOLES = 24
DRILL_ZERO = 140.1

TOP_SKEW = 2.7/12   #this should be the top skew divided by 12
BOTTOM_SKEW = -2.7/12

BOTTOM_OFFSET = 2.15


HOLE_LOCATIONS = (
[101.37,-69.52],
[100.411,-71.247],
[99.293,-72.626],
[98.031,-73.688],
[96.638,-74.454],
[95.123,-74.936],
[93.491,-75.142],
[91.747,-75.076],
[89.894,-74.737],
[87.933,-74.119],
[85.861,-73.213],
[83.676,-72],
[82.538,-71.272],
[84.783,-72.646],
[86.911,-73.703],
[88.927,-74.464],
[90.834,-74.941],
[92.633,-75.143],
[94.321,-75.073],
[95.895,-74.729],
[97.351,-74.107],
[98.679,-73.195],
[99.871,-71.978],
[100.912,-70.43])


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
        fo.write(" F75\nG1 Z")
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
        fo.write(" F75\nG1 Z")
        fo.write(str("%.2f" % ((DRILL_ZERO + DRILL_CLEARANCE) + BOTTOM_OFFSET)))
        fo.write(" F600\n")

    
    #START ROUTINE
fo.write(START_CODE)

for i in range(NUM_PECKS):
    for j in range(NUM_HOLES):
        moveToNextHole(j)
        if j == 12:
            fo.write("G1 E36 F2000\n")
        elif j == 0:
            fo.write("G1 E1 F2000\n")
        drillToDepth(i,j)
    print("next line")
fo.write(END_CODE)    


fo.close()    
      
