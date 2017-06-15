
//evezorPort;                       
//skirtPort;




void serialEvent( Serial thisPort) {
//put the incoming data into a String - 
//the '\n' is our end delimiter indicating the end of a complete packet
String inString = thisPort.readStringUntil('\n');
//make sure our data isn't empty before continuing
  if (inString != null) {
    //trim whitespace and formatting characters (like carriage return)
    inString = trim(inString);
    //println(inString);
    //look for our 'A' string to start the handshake
    //if it's there, clear the buffer, and send a request for data
    if(thisPort == skirtPort){
       if (firstContactARM == false) {
          if (inString.equals("im here")) {
            skirtPort.clear();
            firstContactARM = true;
            skirtPort.write("A");
            println("contact");
          }
        }
       if(IS_RUNNING == true && inString.equals("SKIRT_DONE")){
        println("starting next job");
        Increment();
        Routine(ROUTINE_NUM);   
       }
       else { //if we've already established contact, keep getting and parsing data
          println("SKT SRL: "+inString);
        }
         println("SKRT SRL: "+inString);
       }
    if(thisPort == evezorPort){
        println("EVZR SRL: "+inString);
      
   
      if(IS_RUNNING == true && inString.equals("JOB_DONE")){
        println("starting next job");
        Increment();
        Routine(ROUTINE_NUM);
      }
      
    }
  }
}