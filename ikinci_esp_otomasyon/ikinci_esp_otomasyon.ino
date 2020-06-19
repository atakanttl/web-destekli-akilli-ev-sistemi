#include <WiFi.h>
#include <FirebaseESP32.h>
#include <FastLED.h>

// FIREBASE AND WIFI DEFINITIOUNS
#define FIREBASE_HOST "xxxxxxxxxx" // Put your Firebase Host name
#define FIREBASE_AUTH "xxxxxxxxxx" // Put your Firebase secret key

#define WIFI_SSID "xxxxxxxxxxx" // Put your WiFi SSID
#define WIFI_PASSWORD "xxxxxxxxxx" // Put your WiFi password

// Define FirebaseESP32 data object
FirebaseData firebaseData;

String path = "/SensorValues";

// LED & 'FastLED.h' DEFINITIONS
#define LED_PIN     33
#define NUM_LEDS    16
#define BRIGHTNESS  255
#define LED_TYPE    WS2811
#define COLOR_ORDER GRB
CRGB leds[NUM_LEDS];
CRGBPalette16 currentPalette;
TBlendType    currentBlending;
int r;
int g;
int b;
uint32_t rgbValue;
int brightnessValue = 255;
bool LEDSwitch = false;

// SMARTPLUG (RELAY) DEFINITIONS
int sPlugPin = 32;
bool plugSwitch = false;

// DOOR SENSOR DEFINITIONS
int dSensorPin = 34;
int dSensorVal;
bool doorSensor;

//////////////////////////////////////////////////////////

void setup(){
  // Start the Serial Monitor
  Serial.begin(115200);
  delay( 3000 );
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting to Wi-Fi");
  while (WiFi.status() != WL_CONNECTED)
  {
      Serial.print(".");
      delay(300);
  }
  
  Serial.println("Connection successful.");
   
  Firebase.begin(FIREBASE_HOST, FIREBASE_AUTH);
  Firebase.reconnectWiFi(true);
 
  //Set database read timeout to 1 minute (max 15 minutes)
  Firebase.setReadTimeout(firebaseData, 1000 * 60);
  //tiny, small, medium, large and unlimited.
  //Size and its write timeout e.g. tiny (1s), small (10s), medium (30s) and large (60s).
  Firebase.setwriteSizeLimit(firebaseData, "tiny");
  
  FastLED.addLeds<LED_TYPE, LED_PIN, COLOR_ORDER>(leds, NUM_LEDS).setCorrection( TypicalLEDStrip );
  
  pinMode(sPlugPin, OUTPUT);          // Smart plug pin set as output
  pinMode(dSensorPin, INPUT_PULLUP);  // Door sensor pin set as input with pull up resistance
}

//////////////////////////////////////////////////////////

void loop() {
   // Get Smart Plug Data From Firebase
  if(Firebase.getBool(firebaseData, path + "/Automation/plugSwitch"))
  {
     plugSwitch = (bool)firebaseData.boolData(); 
  }
  // Go to Smart Plug Function
  sPlug_func(plugSwitch);

  // Send Door Sensor Value to Firebase
  dSensorVal = digitalRead(dSensorPin);
  sDoor_func(dSensorVal);
  if(Firebase.setBool(firebaseData, path + "/Automation/doorSensor", dSensorVal));

  // Get LED Switch Data From Firebase
  if(Firebase.getBool(firebaseData, path + "/Automation/lightSwitch"))
  {
     LEDSwitch = (bool)firebaseData.boolData(); 
  }

  // Get LED Brightness Data From Firebase
  if(Firebase.getInt(firebaseData, path + "/Automation/lightBrightness"))
  {
    brightnessValue = (int)firebaseData.intData();
  }

  // Get LED Color Data From Firebase
  if(Firebase.getDouble(firebaseData, path + "/Automation/lightColor"))
  {
      rgbValue = (uint32_t)firebaseData.doubleData();
  }

  // Transform LED color data to hexadecimal from decimal
  r = (int)(rgbValue & 0x00ff0000) >> 16;
  g = (int)(rgbValue & 0x0000ff00) >> 8;
  b = (int)(rgbValue & 0x000000ff);

  // Go to LED Function
  changePalette(LEDSwitch);

  static uint8_t startIndex = 0;
  startIndex = startIndex + 1; 
  fillLED(startIndex, brightnessValue);
  FastLED.show(); 
}

//////////////////////////////////////////////////////////

// Smart Plug Function
void sPlug_func(bool plugSwitch)
{
  if(plugSwitch == true)
  {
    digitalWrite(sPlugPin,HIGH);
  }
  else if(plugSwitch == false)
  {
    digitalWrite(sPlugPin,LOW);
  }
}

//////////////////////////////////////////////////////////

// Door Sensor Function
void sDoor_func(int dSensorVal)
{
  if(dSensorVal == LOW)
  {
    doorSensor = true;
  }
  else if(dSensorVal == HIGH)
  {
    doorSensor = false;
  }
}

//////////////////////////////////////////////////////////

// Sets up color and on-off state of the led
void changePalette(bool LEDSwitch)
{ 
  if (LEDSwitch == true)          
  {
    fill_solid( currentPalette, 16, CRGB::Black);

    for(int i=0; i<16; i++){
      currentPalette[i] = CRGB(r,g,b);
    }   
  }
  else if(LEDSwitch == false)
  {
    for(int i=0; i<16; i++){
      currentPalette[i] = CRGB(0,0,0);
    }
  }
}

// Light up the led based on palette
void fillLED( uint8_t colorIndex, uint8_t brigthness)
{ 
    for(int i=0; i<NUM_LEDS; i++) {
        leds[i] = ColorFromPalette( currentPalette, colorIndex, brigthness, currentBlending);
        colorIndex += 3;
    }
}
