#include <WiFi.h>
#include <FirebaseESP32.h>
#include <FastLED.h>

// FIREBASE VE WIFI TANIMLARI
#define FIREBASE_HOST "xxxxxxxxxx" // Buraya Firebase Host adı gelecek
#define FIREBASE_AUTH "xxxxxxxxxx" // Buraya Firebase gizli anahtarı gelecek

#define WIFI_SSID "xxxxxxxxxxx" // Buraya WiFi SSID (isim) gelecek
#define WIFI_PASSWORD "xxxxxxxxxx" // Buraya WiFi şifresi gelecek

// FirebaseESP32 instance'ı tanımlandı
FirebaseData firebaseData;

// Firebase'de oluşturulan yol
String path = "/SensorValues";

// LED & 'FastLED.h' KÜTÜPHANESİ TANIMLARI
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

// AKILLI PRİZ (RÖLE) TANIMLARI
int sPlugPin = 32;
bool plugSwitch = false;

// KAPI SENSÖRÜ TANIMLARI
int dSensorPin = 34;
int dSensorVal;
bool doorSensor;

//////////////////////////////////////////////////////////

void setup(){
  // Seri monitör 115200 baud rate ile başlatıldı
  Serial.begin(115200);
  delay( 3000 );
  
  // WiFi ağına bağlanmaya çalış
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting to Wi-Fi");
  while (WiFi.status() != WL_CONNECTED)
  {
      Serial.print(".");
      delay(300);
  }
  Serial.println("Connection successful.");

  // Firebase'i başlat
  Firebase.begin(FIREBASE_HOST, FIREBASE_AUTH);
  // İnternet bağlantısının kesilmesi durumunda yeniden bağlanmayı deneyip döngüyü baştan başlat
  Firebase.reconnectWiFi(true);
 
  // Firebase veri okuması zaman aşımını 1 dakika olarak belirle
  Firebase.setReadTimeout(firebaseData, 1000 * 60);
  // Firebase veri yazma zaman aşımını 1 saniye olarak belirle (tiny)
  Firebase.setwriteSizeLimit(firebaseData, "tiny");

  // LED tipi, pini, renk sırası, LED matrisi ve sayısına göre LED'i başlat
  FastLED.addLeds<LED_TYPE, LED_PIN, COLOR_ORDER>(leds, NUM_LEDS).setCorrection( TypicalLEDStrip );

  // Akıllı priz pinini çıkış olarak belirle
  pinMode(sPlugPin, OUTPUT);
  // Kapı sensörü pinini pull-up direnciyle giriş olarak belirle
  pinMode(dSensorPin, INPUT_PULLUP); 
}

//////////////////////////////////////////////////////////

void loop() {
  // Firebase.getXXX fonksiyonları önce belirlenen yola göre Firebase'den değişken alır, işlem başarılıysa true, başarısızsa false döndürür
  // Akıllı priz değerini Firebase'den al
  if(Firebase.getBool(firebaseData, path + "/Automation/plugSwitch"))
  {
    // plugSwitch değerini Firebase'deki akıllı prize göre değiştir
    plugSwitch = (bool)firebaseData.boolData(); 
  }
  // Akıllı priz fonksiyonunu plugSwitch değeriyle çağır
  sPlug_func(plugSwitch);

  // Kapı sensörü değerini oku
  dSensorVal = digitalRead(dSensorPin);
  // Kapı sensörünü boolean değeriyle güncelle
  sDoor_func(dSensorVal);
  // Firebase.setXXX fonksiyonları önce belirlenen yola göre değişkeni Firebase'e aktarır, işlem başarılıysa true, başarısızsa false döndürür
  // Kapı sensörü değerini Firebase'e aktar
  if(Firebase.setBool(firebaseData, path + "/Automation/doorSensor", dSensorVal));
  
  // LED durum değerini Firebase'den al
  if(Firebase.getBool(firebaseData, path + "/Automation/lightSwitch"))
  {
     LEDSwitch = (bool)firebaseData.boolData(); 
  }

  // LED parlaklık değerini Firebase'den al
  if(Firebase.getInt(firebaseData, path + "/Automation/lightBrightness"))
  {
    brightnessValue = (int)firebaseData.intData();
  }

  // LED renk değerini Firebase'den al
  if(Firebase.getDouble(firebaseData, path + "/Automation/lightColor"))
  {
      rgbValue = (uint32_t)firebaseData.doubleData();
  }

  // Alınan integer renk değerini kırmızı, yeşil ve mavi olarak parçalara ayır
  r = (int)(rgbValue & 0x00ff0000) >> 16;
  g = (int)(rgbValue & 0x0000ff00) >> 8;
  b = (int)(rgbValue & 0x000000ff);

  // LED'in durumuna göre LED paletini değiştir
  changePalette(LEDSwitch);
  
  static uint8_t startIndex = 0;
  startIndex = startIndex + 1; 

  // İndise ve parlaklığa göre LED'leri doldur
  fillLED(startIndex, brightnessValue);
  // LED'leri yak
  FastLED.show(); 
}

//////////////////////////////////////////////////////////

// Akıllı priz fonksiyonu
// Firebase'den alınan priz durumu röleye iletilir.
void sPlug_func(bool plugSwitch)
{
  // Gelen veri true ise röleyi çalıştır, false ise röleyi durdur
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

// Kapı sensörü fonksiyonu
// Pinden okunan değer LOW ise kapı açık; HIGH ise kapı kapalıdır
void sDoor_func(int dSensorVal)
{
  // Sensörden alınan veriye göre kapı sensörü değerini bool cinsinden değiştir
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

// LED'in paletini ve açık-kapalı durumunu ayarlayan fonksiyon
// Firebase'den alınan durum bilgisine göre LED yakılır, renk bilgisine göre palet değiştirilir
void changePalette(bool LEDSwitch)
{ 
  if (LEDSwitch == true)          
  {
    fill_solid( currentPalette, 16, CRGB::Black);

    // Ayrılan R, G, B değerleri palete yazılır
    for(int i=0; i<16; i++){
      currentPalette[i] = CRGB(r,g,b);
    }   
  }
  // LED durumu kapalı olarak ayarlanmışsa palet (0,0,0) olarak ayarlanır, bu da LED'i sönük duruma geçirir
  else if(LEDSwitch == false)
  {
    for(int i=0; i<16; i++){
      currentPalette[i] = CRGB(0,0,0);
    }
  }
}

// Palete göre LED'i dolduran fonksiyon
// changePalette fonksiyonundan alınan palet verisi, Firebase'den alınan parlaklık bilgisiyle beraber donanıma iletilir
void fillLED( uint8_t colorIndex, uint8_t brigthness)
{ 
    for(int i=0; i<NUM_LEDS; i++) {
        leds[i] = ColorFromPalette( currentPalette, colorIndex, brigthness, currentBlending);
        colorIndex += 3;
    }
}
