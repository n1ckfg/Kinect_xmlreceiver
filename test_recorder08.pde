import processing.opengl.*;
import oscP5.*;
import netP5.*;
import proxml.*;
import ddf.minim.*;

int stageWidth = 640;
int stageHeight = 480;
int fps = 24;

Countdown countdown;

Minim minim;
OscP5 oscP5;
boolean found=false;

XMLInOut xmlIO;
proxml.XMLElement xmlFile;
String xmlFileName = "mocapData.xml";

int counter = 0;
int counterMax = 400;
boolean limitReached = false;

String[] oscNames = {
  "r_hand","r_elbow","r_shoulder", "l_hand","l_elbow","l_shoulder","head"
};
proxml.XMLElement[] oscXmlTags = new proxml.XMLElement[oscNames.length];

float[] x = new float[oscNames.length];
float[] y = new float[oscNames.length];
float[] z = new float[oscNames.length];
float depth = 200;
int circleSize = 50;

void setup() {
  size(stageWidth,stageHeight,OPENGL);
  frameRate(fps);
  minim = new Minim(this);
  countdown = new Countdown(8,2);
  oscP5 = new OscP5(this, "127.0.0.1", 7110);
  xmlInit();
  ellipseMode(CENTER);
}

void draw() {
  background(0);
  if(found) {
    fill(255,200);
    stroke(0);
    strokeWeight(5);
    for(int i=0;i<oscNames.length;i++) {
      pushMatrix();
      translate(width*x[i],height*y[i],(-depth*z[i])+abs(depth/2));
      ellipse(0,0,circleSize,circleSize);
      popMatrix();
    }
  } 
  if(countdown.go) {
    if(counter<counterMax) {
      xmlAdd();
      counter++;
    } 
    else {
      if(!limitReached) {
        limitReached = true;
        xmlSaveToDisk();
        println("saved file " + xmlFileName);
      }
    }
  }
  countdown.update();
}

void oscEvent(OscMessage msg) {
  if (msg.checkAddrPattern("/joint") && msg.checkTypetag("sifff")) {
    found = true;
    for(int i=0;i<oscNames.length;i++) {
      if (msg.get(0).stringValue().equals(oscNames[i])) {
        x[i] = msg.get(2).floatValue();
        y[i] = msg.get(3).floatValue();
        z[i] = msg.get(4).floatValue();
      }
    }
  }
}

void xmlInit() {
  xmlIO = new XMLInOut(this);
  xmlFile = new proxml.XMLElement("keyFrameList");
}

void xmlAdd() {
  proxml.XMLElement frameData = new proxml.XMLElement("frameData");
  xmlFile.addChild(frameData);
  proxml.XMLElement frameNum = new proxml.XMLElement("frameNum");
  frameData.addChild(frameNum);
  frameNum.addChild(new proxml.XMLElement(""+counter,true));
  for(int i=0;i<oscNames.length;i++) {
    oscXmlTags[i] = new proxml.XMLElement(oscNames[i]);
    frameData.addChild(oscXmlTags[i]);
    proxml.XMLElement posX = new proxml.XMLElement("x");
    oscXmlTags[i].addChild(posX);
    posX.addChild(new proxml.XMLElement(""+x[i],true));
    proxml.XMLElement posY = new proxml.XMLElement("y");
    oscXmlTags[i].addChild(posY);
    posY.addChild(new proxml.XMLElement(""+y[i],true)); 
    proxml.XMLElement posZ = new proxml.XMLElement("z");
    oscXmlTags[i].addChild(posZ);
    posZ.addChild(new proxml.XMLElement(""+z[i],true));
  }
}

/* saves the XML list to disk */
void xmlSaveToDisk() {
  xmlIO.saveElement(xmlFile, xmlFileName);
}  

void stop() {
  countdown.stop();
  minim.stop();
  super.stop();
}

