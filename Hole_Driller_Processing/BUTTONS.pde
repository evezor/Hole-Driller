public void STOP(int theValue) {
  println("a button event from THE STOP BUTTON: "+theValue);
  evezorPort.write("M999\n");
}



void DRILL(boolean theFlag) {
 drillOn(theFlag);
}


void CSINK(boolean theFlag) {
 ctrsnkOn(theFlag);
}

void VISE(boolean theFlag) {
 openVise(theFlag);
} 

void BLOWER(boolean theFlag) {
 Blower(theFlag);
} 

void CSNK_ROUTINE(int theValue) {
 //cycleHopper();
}

void DRILL_ROUTINE(int theValue) {
 evezorPort.write("M655\n");
}

void HOME(int theValue) {
 evezorPort.write("G28 Z0\nG28 X0\nG28 Y0\nG92 X0 Y0\nM121\nM302\n");
}

void CYCLE_HOPPER(int theValue) {
 //cycleHopper();
}


public boolean SOFT_STOP(int theValue) {
 println("Will stop when done");
 RUN_STATE = false;
 runState(false);
 return(RUN_STATE);
}

public void START(int theValue) {
 println("Will stop when done");
 IS_RUNNING = true;
 runState(true);
 
 delay(5000);
 openVise(true);
 delay(11000);
 println("routine start");
 Routine(0);
}