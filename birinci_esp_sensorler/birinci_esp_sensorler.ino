#include <WiFi.h>
#include <FirebaseESP32.h>
#include <OneWire.h>
#include <DallasTemperature.h>
#include <dht11.h>

// FIREBASE AND WIFI DEFINITIONS

#define FIREBASE_HOST "xxxxxxxxxx" // Put your Firebase Host name
#define FIREBASE_AUTH "xxxxxxxxxx" // Put your Firebase secret key

#define WIFI_SSID "xxxxxxxxxxx" // Put your WiFi SSID
#define WIFI_PASSWORD "xxxxxxxxxx" // Put your WiFi password

// Define FirebaseESP32 data object
FirebaseData firebaseData;

// TEMPERATURE SENSOR DEFINITIONS
// GPIO where the DS18B20 is connected to
const int oneWireBus = 32;     
// Setup a oneWire instance to communicate with any OneWire devices
OneWire oneWire(oneWireBus);
// Pass oneWire reference to Dallas Temperature sensor 
DallasTemperature sensors(&oneWire);

// FLAME SENSOR DEFINITIONS
const int flameSensorPin = 35; // Sensor analog interface

// GAS SENSOR DEFINITIONS
const int gasSensorPin = 34;

// HUMIDITY SENSOR DEFINITIONS
const int humiditySensorPin = 33;
dht11 DHT11;

// The path which sensor values stored
String path = "/SensorValues";


void setup() {
  // Start the Serial Monitor
  Serial.begin(115200);
  // Start the DS18B20 sensor
  sensors.begin();
  pinMode(flameSensorPin, OUTPUT);

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

}

void loop() {
  
  if (Firebase.setInt(firebaseData, path + "/Stream/tempValue", getTemp()))
    {
      Serial.println("PASSED");
      Serial.println("PATH: " + firebaseData.dataPath());
      Serial.println("TYPE: " + firebaseData.dataType());
      Serial.print("VALUE: ");
      printResult(firebaseData);
      Serial.println("------------------------------------");
      Serial.println();
    }
    else
    {
      Serial.println("FAILED");
      Serial.println("REASON: " + firebaseData.errorReason());
      Serial.println("------------------------------------");
      Serial.println();
    }

  if (Firebase.setInt(firebaseData, path + "/Stream/gasValue", getGas()))
    {
      Serial.println("PASSED");
      Serial.println("PATH: " + firebaseData.dataPath());
      Serial.println("TYPE: " + firebaseData.dataType());
      Serial.print("VALUE: ");
      printResult(firebaseData);
      Serial.println("------------------------------------");
      Serial.println();
    }
    else
    {
      Serial.println("FAILED");
      Serial.println("REASON: " + firebaseData.errorReason());
      Serial.println("------------------------------------");
      Serial.println();
    }

  if (Firebase.setInt(firebaseData, path + "/Stream/flameValue", getFlame()))
    {
      Serial.println("PASSED");
      Serial.println("PATH: " + firebaseData.dataPath());
      Serial.println("TYPE: " + firebaseData.dataType());
      Serial.print("VALUE: ");
      printResult(firebaseData);
      Serial.println("------------------------------------");
      Serial.println();
    }
    else
    {
      Serial.println("FAILED");
      Serial.println("REASON: " + firebaseData.errorReason());
      Serial.println("------------------------------------");
      Serial.println();
    }

    if (Firebase.setInt(firebaseData, path + "/Stream/humidityValue", getHumidity()))
    {
      Serial.println("PASSED");
      Serial.println("PATH: " + firebaseData.dataPath());
      Serial.println("TYPE: " + firebaseData.dataType());
      Serial.print("VALUE: ");
      printResult(firebaseData);
      Serial.println("------------------------------------");
      Serial.println();
    }
    else
    {
      Serial.println("FAILED");
      Serial.println("REASON: " + firebaseData.errorReason());
      Serial.println("------------------------------------");
      Serial.println();
    }


    delay(200);
}

// Get Temperature Value Function
int getTemp() {
  sensors.requestTemperatures(); 
  int temperatureC = sensors.getTempCByIndex(0); // Get the temperature value in Celsius
  return temperatureC;
}

// Get Flame Value Function
int getFlame() {
  int flame_value = analogRead(flameSensorPin); // Read the analog interface
  return flame_value;
}

// Get Gas Value Function
int getGas() {
  float sensorValue = analogRead(gasSensorPin);     // Read from gasSensorPin
  float sensorVolt = sensorValue * (5.0 / 4095.0);  // Convert analog value to voltage value
  float rsAir = ((50.0 / sensorVolt) - 10.0);       // Air resistance
  float r0 = 6.0;                                   // Calculated r0 from fresh air based on the formula (r0 = rsAir / 4.4)

  float ppmLog = (log10(rsAir / r0) - 1.133) / (-0.318);  // Parts per minute calculation (logarithmic)
  int ppm = (int) pow(10, ppmLog);                        // Parts per minute calculation

  if (ppm > 10000)
    return 10000;
  else
    return ppm;
}

// Get Humidity Value Function
int getHumidity() {
  int chk = DHT11.read(humiditySensorPin);  // Read from humiditySensorPin
  float humid = (float) DHT11.humidity;     // Get humidity data 
  int humidity = (int) humid;
  return humidity;
}

void printResult(FirebaseData &data){
  if (data.dataType() == "int")
    Serial.println(data.intData());
  else if (data.dataType() == "float")
    Serial.println(data.floatData(), 5);
  else
    Serial.println("Undefined data type.");
}
