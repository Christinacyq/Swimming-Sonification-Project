import beads.*;
import org.jaudiolibs.beads.*;
import java.util.*;
import controlP5.*;
//to use text to speech functionality, copy text_to_speech.pde from this sketch to yours
//example usage below

//IMPORTANT (notice from text_to_speech.pde):
//to use this you must import 'ttslib' into Processing, as this code uses the included FreeTTS library
//e.g. from the Menu Bar select Sketch -> Import Library... -> ttslib

TextToSpeechMaker ttsMaker; 

//<import statements here>
//AudioContext ac;
ControlP5 p5;
Button b1, b2, b3;
int waveCount = 10;
float baseFrequency = 440.0;
Glide freqGlide;
Gain wg;
//Glide cutoffGlide;
//BiquadFilter filter;
Reverb reverb;
boolean reverbOn = false;
Gain[] waveGain = new Gain[2];
//Gain waveGain2;
//to use this, copy notification.pde, notification_listener.pde and notification_server.pde from this sketch to yours.
//Example usage below.

//name of a file to load from the data directory
String eventDataJSON1 = "swimmer_data1.json";
String eventDataJSON2 = "swimmer_data2.json";
String eventDataJSON3 = "swimmer_data3.json";

int exampleNum = 1;
boolean inWater = false;
NotificationServer server;
ArrayList<Notification> notifications;
Gain masterGain;
Glide masterGainGlide;
ArrayList<Notification> waveTone;
Example example;
WavePlayer[] wp = new WavePlayer[2];
//WavePlayer wp2;
Envelope envelope;
SamplePlayer sp;
//Comparator<Notification> comparator;
//PriorityQueue<Notification> queue;
//PriorityQueue<Notification> q2;

void setup() {
  size(600,600);
  
  //NotificationComparator priorityComp = new NotificationComparator();
  
  //q2 = new PriorityQueue<Notification>(10, priorityComp);
  ac = new AudioContext(); //ac is defined in helper_functions.pde
  notifications = new ArrayList<Notification>(10);
  p5 = new ControlP5(this);
  sp = getSamplePlayer("water_sound.mp3");
  sp.setLoopType(SamplePlayer.LoopType.LOOP_FORWARDS);
  freqGlide = new Glide(ac, 440.0, 10);
  //p5.addSlider("FreqSlider")
  // .setPosition(150, 100)
  // .setSize(200, 20)
  // .setRange(20.0, 1500.0)
  // .setValue(440.0)
  // .setLabel("Frequency");
  
  //wp = new WavePlayer(ac, freqGlide, Buffer.SINE);
  //comparator = new NotificationComparator();
  //queue = new PriorityQueue<Notification>(10, comparator);
  masterGainGlide = new Glide(ac, 1, 200);
  masterGain = new Gain(ac, 1, masterGainGlide);
  envelope = new Envelope(ac, 0.0);
  wg = new Gain(ac, 1, 1);
  //this will create WAV files in your data directory from input speech 
  //which you will then need to hook up to SamplePlayer Beads
  ttsMaker = new TextToSpeechMaker();

  ttsExamplePlayback("Example One");

  wg.addInput(sp);
  //String exampleSpeech = "Text to speech is okay, I guess.";
  
  //ttsExamplePlayback(exampleSpeech); //see ttsExamplePlayback below for usage
  
  //START NotificationServer setup
  server = new NotificationServer();
  
  //instantiating a custom class (seen below) and registering it as a listener to the server
  example = new Example();
  server.addListener(example);
  
  //loading the event stream, which also starts the timer serving events
  server.loadEventStream(eventDataJSON1);
  
  //END NotificationServer setup
  masterGain.addInput(wg);
  
  reverb = new Reverb(ac);
  reverb.setSize(0.8);
  reverb.setDamping(0.03);
  //reverb.setEarlyReflectionsLevel(0.1);
  p5.addButton("WaterSound")
   .setPosition(330, 160)
   .setSize(100, 30)
   .setLabel("Water Sound");
  
  p5.addButton("Reverb")
   .setPosition(150, 160)
   .setSize(100, 30)
   .setLabel("Reverb Toggle");
   
  b1 = p5.addButton("exampleOne").setPosition(150, 300).setSize(250, 30).setLabel("Example 1: less accurate but enough force").activateBy((ControlP5.RELEASE));
  b2 = p5.addButton("exampleTwo").setPosition(150, 350).setSize(250, 30).setLabel("Example 2: average swimming strokes").activateBy((ControlP5.RELEASE));
  b3 = p5.addButton("exampleThree").setPosition(150, 400).setSize(250, 30).setLabel("Example 3: more accurate but less force").activateBy((ControlP5.RELEASE));
  
  p5.addSlider("masterGainGlide")
   .setPosition(150, 100)
   .setSize(200, 20)
   .setRange(0, 1.0)
   .setValue(1.0)
   .setLabel("Volume");

  ac.out.addInput(masterGain);  
  ac.start();
  //if (ac.getTime() == 18000 && ac.getTime() != 0) {
  //wp[0].pause(true);
  //wp[1].pause(true);
  //}

}

public void exampleOne() {
   exampleNum = 1;
   ttsExamplePlayback("Example One");
   server.stopEventStream(); //always call this before loading a new stream
   server.loadEventStream(eventDataJSON1);
   println("**** New event stream loaded: " + eventDataJSON1 + " ****");
}

public void exampleTwo() {
   exampleNum = 2;
   ttsExamplePlayback("Example Two");
   server.stopEventStream(); //always call this before loading a new stream
   server.loadEventStream(eventDataJSON2);
   println("**** New event stream loaded: " + eventDataJSON2 + " ****");
}

public void exampleThree() {
   exampleNum = 3;
   ttsExamplePlayback("Example Three");
   server.stopEventStream(); //always call this before loading a new stream
   server.loadEventStream(eventDataJSON3);
   println("**** New event stream loaded: " + eventDataJSON3 + " ****");
}

public void WaterSound() {
  if (inWater) {
    inWater = !inWater;
    sp.pause(false);
    
  } else {
    inWater = !inWater;
    sp.pause(true);
  }
  
}

public void Reverb(){
  if (reverbOn) {
    reverbOn = false;
    reverb.clearInputConnections();
    masterGain.clearInputConnections();
    masterGain.addInput(wg);
  } else {
    reverbOn = true;
    masterGain.clearInputConnections();
    reverb.addInput(wg);
    masterGain.addInput(reverb);
  }
}


public void masterGainGlide(float value) {
  println("gain");
  masterGainGlide.setValue(value);
}

void draw() {
  //this method must be present (even if empty) to process events such as keyPressed()  
  background(100, 130, 220);
  text("Swimming Training Sonification for Arm Motions", 130, 50);
  text("For Breaststroke", 150, 80);
  text("Use Enter/Return key to switch examples \nor use buttons below.", 150 , 240);
  textSize(15);
}

void keyPressed() {
  //example of stopping the current event stream and loading the second one
  if ((key == RETURN || key == ENTER) && exampleNum == 1) {
    exampleNum = 2;
    ttsExamplePlayback("Example Two");
    server.stopEventStream(); //always call this before loading a new stream
    server.loadEventStream(eventDataJSON2);
    println("**** New event stream loaded: " + eventDataJSON2 + " ****");
  } else if ((key == RETURN || key == ENTER) && exampleNum == 2) {
    exampleNum = 3;
    ttsExamplePlayback("Example Three");
    server.stopEventStream(); //always call this before loading a new stream
    server.loadEventStream(eventDataJSON3);
    println("**** New event stream loaded: " + eventDataJSON3 + " ****");
  } else if ((key == RETURN || key == ENTER) && exampleNum == 3) {
    exampleNum = 1;
    ttsExamplePlayback("Example One");
    server.stopEventStream(); //always call this before loading a new stream
    server.loadEventStream(eventDataJSON1);
    println("**** New event stream loaded: " + eventDataJSON1 + " ****");
  }
    
}

//in your own custom class, you will implement the NotificationListener interface 
//(with the notificationReceived() method) to receive Notification events as they come in
class Example implements NotificationListener {
  //private SamplePlayer sp1;
  private SamplePlayer sp2;
  private Envelope gainEnvelope;
  //private Envelope freqEnvelope;
  public Example() {
    //setup here
      wp[0] = new WavePlayer(ac, 440.0, Buffer.SINE);
      wp[1] = new WavePlayer(ac, freqGlide, Buffer.SQUARE);
      gainEnvelope = new Envelope(ac, 0.0);
      //WaveAdd waveAdd = new WaveAdd(ac, 2, player1, player2);
      waveGain[0] = new Gain(ac,1, gainEnvelope);
      waveGain[1] = new Gain(ac,1, 0.01);
      waveGain[0].addInput(wp[0]);
      waveGain[1].addInput(wp[1]);
      wg.addInput(waveGain[0]);
      wg.addInput(waveGain[1]);

    }
  
  //this method must be implemented to receive notifications
  public void notificationReceived(Notification notification) { 
    println("<Example> " + notification.getType().toString() + " notification received at " 
    + Integer.toString(notification.getTimestamp()) + " ms");
    
    String debugOutput = ">>> ";
    switch (notification.getType()) {
      case Glide:
        debugOutput += "Glide: ";
        //sp1 = getSamplePlayer("D.wav", true);
        //wp1.setGain(notification.getForce()/400.0);
        //ac.out.addInput(sp1);
        break;
      case Outsweep:
        debugOutput += "OutSweep: ";
        break;
      case Catch:
        debugOutput += "Catch: ";
        break;
      case Insweep:
        debugOutput += "InSweep: ";
        break;
      case Recovery:
        debugOutput += "Recovery: ";
        break;
    }
    debugOutput += notification.toString();
    //debugOutput += notification.getLocation() + ", " + notification.getTag();
    
    println(debugOutput);
    
   //You can experiment with the timing by altering the timestamp values (in ms) in the exampleData.json file
    //(located in the data directory)
    gainEnvelope.addSegment(notification.getForce()/350.0, notification.getDuration());
    freqGlide.setValue(notification.getAccuracy() * 440.0);
    if (notification.getOxygen() < 0.94) {
      sp2 = getSamplePlayer("alarm.wav", true);
      ac.out.addInput(sp2);
    }
  }
}

void ttsExamplePlayback(String inputSpeech) {
  //create TTS file and play it back immediately
  //the SamplePlayer will remove itself when it is finished in this case
  
  String ttsFilePath = ttsMaker.createTTSWavFile(inputSpeech);
  println("File created at " + ttsFilePath);
  
  //createTTSWavFile makes a new WAV file of name ttsX.wav, where X is a unique integer
  //it returns the path relative to the sketch's data directory to the wav file
  
  //see helper_functions.pde for actual loading of the WAV file into a SamplePlayer
  
  SamplePlayer sp = getSamplePlayer(ttsFilePath, true); 
  //true means it will delete itself when it is finished playing
  //you may or may not want this behavior!
  
  ac.out.addInput(sp);
  sp.setToLoopStart();
  sp.start();
  println("TTS: " + inputSpeech);
}
