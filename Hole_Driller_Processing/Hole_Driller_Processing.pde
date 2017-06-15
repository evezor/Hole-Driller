
/*
This Program was written by Andrew Wingate to automate the drilling of holes into tubes with the Evezor Robotic Arm

Special MCODES are as follows

M650: Part Loaded
M651: Drill Routine Finished
M652: Countersink Routine Finished
M653: Part Unloaded
M654: Area Cleaned
M655: JOB_DONE

M655: Vise Closed
M656: Hopper Cycled


*/
 
import controlP5.*;
import processing.serial.*;
ControlP5 cp5;



//SET UP SERIAL COMMUNICATIONS
Serial evezorPort;                       
Serial skirtPort;


String evezorString;
String skirtString;


int NUM_STATUS_PICS = 11;
PImage np, dr, cr, rp, ca, ch, co, d_o, rs, ov, bl, npg, drg, crg, rpg, cag, chg, cog, d_og, rsg, ovg, blg;
PImage statusPics [] = new PImage [NUM_STATUS_PICS*2];
boolean statusFlags [] = {false, false, false, false, false, false, false, false, false, false, false};
boolean firstContactARM = false;
boolean IS_RUNNING = false;

int statusPicLocations [][]= {
    {11,10},
    {11,87},
    {11,164},
    {11,241},
    {11,318},
    {142,10},
    {142,87},
    {142,164},
    {273,10},
    {273,87},
    {273,164},
};
 


PImage bg; 
PFont f;
PFont f2;

boolean RUN_STATE;
boolean DRILL_STATE = true;
boolean ERROR_STATE = false;
int ROUTINE_NUM = 0;

void setup() {
  //frameRate(4);
  size(700, 400);
  bg = loadImage("HD_BG.jpg");
  noStroke();
  f = createFont("OCR A Extended", 150, true); 
  f2 = createFont("Arial Rounded MT Bold", 150, true);
  
  printArray(Serial.list());
 /*
  String portEvezor = Serial.list()[0];
  String portSkirt = Serial.list()[1];

  evezorPort = new Serial(this, portEvezor, 115200);
  skirtPort = new Serial(this, portSkirt, 115200);
  
  evezorPort.bufferUntil('\n');
  skirtPort.bufferUntil('\n');
  */
cp5 = new ControlP5(this);


np = loadImage("NEW_PART.png");
dr = loadImage("DRILL_ROUTINE.png");
cr = loadImage("CTRSNK_ROUTINE.png");
rp = loadImage("REMOVE_PART.png");
ca = loadImage("CLEAN_AREA.png");
ch = loadImage("CYCLE_HOPPER.png");
co = loadImage("CNTRSINK_ON.png");
d_o = loadImage("DRILL_ON.png");
rs = loadImage("RUN_STATE.png");
ov = loadImage("OPEN_VISE.png");
bl = loadImage("BLOWER.png");

npg = loadImage("NEW_PART.png");
drg = loadImage("DRILL_ROUTINE.png");
crg = loadImage("CTRSNK_ROUTINE.png");
rpg = loadImage("REMOVE_PART.png");
cag = loadImage("CLEAN_AREA.png");
chg = loadImage("CYCLE_HOPPER.png");
cog = loadImage("CNTRSINK_ON.png");
d_og = loadImage("DRILL_ON.png");
rsg = loadImage("RUN_STATE.png");
ovg = loadImage("OPEN_VISE.png");
blg = loadImage("BLOWER.png");

npg.filter(GRAY);
drg.filter(GRAY);
crg.filter(GRAY);
rpg.filter(GRAY);
cag.filter(GRAY);
chg.filter(GRAY);
cog.filter(GRAY);
d_og.filter(GRAY);
rsg.filter(GRAY);
ovg.filter(GRAY);
blg.filter(GRAY);

statusPics[0] = np;
statusPics[1] = dr;
statusPics[2] = cr;
statusPics[3] = rp;
statusPics[4] = ca;
statusPics[5] = ch;
statusPics[6] = co;
statusPics[7] = d_o;
statusPics[8] = rs;
statusPics[9] = ov;
statusPics[10] = bl;
statusPics[11] = npg;
statusPics[12] = drg;
statusPics[13] = crg;
statusPics[14] = rpg;
statusPics[15] = cag;
statusPics[16] = chg;
statusPics[17] = cog;
statusPics[18] = d_og;
statusPics[19] = rsg;
statusPics[20] = ovg;
statusPics[21] = blg;

PImage[] STOP_imgs = {loadImage("STOP.png"),loadImage("STOP_MO.png"),loadImage("STOP_PR.png")};
cp5.addButton("STOP")
   .setBroadcast(false)
   .setValue(128)
   .setPosition(480,10)
   .setImages(STOP_imgs)
   .setBroadcast(true)
   .updateSize()
   ;

cp5.addToggle("DRILL")
   .setPosition(620,100)
   .setSize(50,50)
   ;

cp5.addToggle("CSINK")
   .setPosition(540,100)
   .setSize(50,50)
   ;
     
cp5.addToggle("VISE")
   .setPosition(620,170)
   .setSize(50,50)
   ;

     
cp5.addToggle("BLOWER")
   .setPosition(540,240)
   .setSize(50,50)
   ;
   
   
cp5.addButton("SOFT_STOP")
    .setBroadcast(false)
    .setPosition(620,240)
    .setSize(50,50)
    .setValue(1)
    .setBroadcast(true)
    .getCaptionLabel().align(CENTER,CENTER)
    ;
    
cp5.addButton("START")
    .setBroadcast(false)
    .setPosition(400,15)
    .setSize(70,70)
    .setValue(1)
    .setBroadcast(true)
    .getCaptionLabel().align(CENTER,CENTER)
    ;
     
cp5.addButton("CYCLE_HOPPER")
    .setBroadcast(false)
    .setPosition(540,170)
    .setSize(50,50)
    .setValue(1)
    .setBroadcast(true)
    .getCaptionLabel().align(CENTER,CENTER)
    ;

cp5.addButton("HOME")
    .setBroadcast(false)
    .setPosition(400,100)
    .setSize(120,40)
    .setValue(1)
    .setBroadcast(true)
    .getCaptionLabel().align(CENTER,CENTER)
    ;

cp5.addButton("DRILL_ROUTINE")
    .setBroadcast(false)
    .setPosition(400,150)
    .setSize(120,40)
    .setValue(1)
    .setBroadcast(true)
    .getCaptionLabel().align(CENTER,CENTER)
    ;

cp5.addButton("CSNK_ROUTINE")
    .setBroadcast(false)
    .setPosition(400,200)
    .setSize(120,40)
    .setValue(1)
    .setBroadcast(true)
    .getCaptionLabel().align(CENTER,CENTER)
    ;

cp5.addButton("REMOVE_PART")
    .setBroadcast(false)
    .setPosition(400,250)
    .setSize(120,40)
    .setValue(1)
    .setBroadcast(true)
    .getCaptionLabel().align(CENTER,CENTER)
    ;

cp5.addButton("CLEAN_AREA")
    .setBroadcast(false)
    .setPosition(400,300)
    .setSize(120,40)
    .setValue(1)
    .setBroadcast(true)
    .getCaptionLabel().align(CENTER,CENTER)
    ;

}






void draw() {
  background(bg);
  stroke(226, 204, 0);
  for (int i = 0; i < NUM_STATUS_PICS; i = i+1) {
      if (statusFlags[i] == false) {
         image(statusPics[i+NUM_STATUS_PICS],statusPicLocations[i][0],statusPicLocations[i][1]); 
      }
      else {
         image(statusPics[i],statusPicLocations[i][0],statusPicLocations[i][1]);  
      }
  }
}


void Routine(int INDEX) {
    print("index ");
    println(INDEX);
    
    switch(INDEX) {
      case 0: 
        println("cycle hopper");
        Blower(false);
        cleanArea(false);
        cycleHopper(true);
        skirtPort.write("H");
        openVise(true);
        evezorPort.write("M655\n");
        break;
      
      case 1: 
        println("move for load and open gripper");
        loadPart(true);
        cycleHopper(false);
        skirtPort.write("G");  //open gripper
        evezorPort.write("G1 Y-90 F800\nG1 X-17.8 Y-93.4 F1200\nG1 Z89\nG1 X-38.2 Y-55\nG1 Z29\nM655\n");
        break;
      
      case 2:
        println("close gripper and move for vise closing");
        skirtPort.write("g"); //close gripper
        evezorPort.write("G04 P1000\nG1 Z89\nG1 X-17.8 Y-93.4\nG1 Z195\nG1 X133.4 Y-95.3\nG1 Z52.8\nG1 X135.5 Y-95.3 F200\nM655\n");  //finish writing for load routine
        break;
      
      case 3:
        println("close vise");
        openVise(false);
        drillOn(true);
        delay(9000);
        skirtPort.write("G");  //open gripper
        delay(2500);
        evezorPort.write("G04 P2000\nG1 Z195 F600\nM655\n");
        
        break;
      
      case 4:
        println("drill routine");
        loadPart(false);
        skirtPort.write("g"); //close gripper
        drillRoutine(true);
        evezorPort.write("M23 drill~1.gco\nM24\n");
        break;
      
      case 5:
        println("countersink routine");
        drillRoutine(false);
        drillOn(false);
        ctrsnkOn(true);
        ctrsnkRoutine(true);
        evezorPort.write("M23 cse4cb~1.gco\nM24\n");
        break;
      
      case 6:
      println("clean area");
        ctrsnkRoutine(false);
        ctrsnkOn(false);
        cleanArea(true);
        Blower(true);
        openVise(true);
        delay(11000);
        evezorPort.write("M655\n");
        break;
      
    }
}


int Increment(){
    if (ROUTINE_NUM == 6){
      ROUTINE_NUM = 0;
    }
    else {
        ROUTINE_NUM = ROUTINE_NUM + 1;
    }
  return(ROUTINE_NUM);
}


boolean loadPart(boolean theFlag){
   statusFlags[0] = theFlag;
   return(statusFlags[0]);
}


boolean drillRoutine(boolean theFlag){
    statusFlags[1] = theFlag;
    return(statusFlags[1]);
}

boolean ctrsnkRoutine(boolean theFlag){
    statusFlags[2] = theFlag;
    return(statusFlags[2]);
}

boolean removePart(boolean theFlag){
    statusFlags[3] = theFlag;
    return(statusFlags[3]);
}

boolean cleanArea(boolean theFlag){
    statusFlags[4] = theFlag;
    return(statusFlags[3]);
}

boolean cycleHopper(boolean theFlag){
    statusFlags[5] = theFlag;
    return(statusFlags[5]);
}

boolean ctrsnkOn(boolean theFlag){
 if(theFlag == true){
  println("Countersink ON");
  statusFlags[6] = true;
  skirtPort.write("S"); //turn countersink on
  return(statusFlags[6]);
  }
 else{
  println("Countersink OFF");
  statusFlags[6] = false;
  skirtPort.write("s"); //turn countersink off
  return(statusFlags[6]);    
 }
}

boolean drillOn(boolean theFlag){
 if(theFlag == true){
  println("Drill ON");
  statusFlags[7] = true;
  skirtPort.write("D"); //turn drill on
  return(statusFlags[7]);
  }
 else{
  println("Drill OFF");
  statusFlags[7] = false;
  skirtPort.write("d"); //turn drill off
 return(statusFlags[7]);
 }
}

boolean runState(boolean theFlag){
 if(theFlag == true){
  println("SYSTEM IS ACTIVE");
  statusFlags[8] = true;
  
 return(statusFlags[8]);
  }
 else{
  println("WILL STOP WHEN ROUTINE IS FINISHED");
  statusFlags[8] = false;
 
 return(statusFlags[8]);  
 }
}

boolean openVise(boolean theFlag){
 if(theFlag == true){
  println("OPEN VISE");
  statusFlags[9] = true;
  skirtPort.write("O");
  return(statusFlags[9]);
  }
 else{
  println("CLOSE_VISE");
  statusFlags[9] = false;
  skirtPort.write("C");
  return(statusFlags[9]);  
 }
}

boolean Blower(boolean theFlag){
 if(theFlag == true){
  println("Drill ON");
  statusFlags[10] = true;
  skirtPort.write("B");
  return(statusFlags[10]);
  }
 else{
  println("Drill OFF");
  statusFlags[10] = false;
  skirtPort.write("b");
  return(statusFlags[10]);
 } 
}




void errorChecking(){
    if (ERROR_STATE == false){
        println("good to go start drilling");
    }
    else{
        println("ERROR ON PART LOAD");
        exit();
    }
}

/*
Special MCODES are as follows
From Evezor
M650: Part Loaded
M651: Drill Routine Finished
M652: Countersink Routine Finished
M653: Part Unloaded
M654: Area Cleaned
M656: Error checking on part pick
M657: Error checking on part place

From Skirt
M675: Vise Closed
M676: Hopper Cycled


*/

boolean M650(){
    println("Part Loaded");
    statusFlags[0] = false;
    return(statusFlags[0]);
}

boolean M651(){
    println("Drill Routine Finished");
    statusFlags[1] = false;
    return(statusFlags[1]);
}

boolean M652(){
    println("Countersink Routine Finished");
    statusFlags[2] = false;
    return(statusFlags[2]);
}

boolean M653(){
    println("Part Unloaded");
    statusFlags[3] = false;
    return(statusFlags[3]);
}

boolean M654(){
    println("area cleaned");
    statusFlags[4] = false;
    return(statusFlags[4]);
}

boolean M656(){
    println("Error checking on part place");
    statusFlags[8] = false;
    return(statusFlags[8]);
}

boolean M675(){
    println("Vise Closed");
    statusFlags[9] = false;
    return(statusFlags[9]);
}

boolean M676(){
    println("Hopper Cycled");
    statusFlags[5] = false;
    return(statusFlags[5]);
}