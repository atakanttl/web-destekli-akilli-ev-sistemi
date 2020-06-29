#include <WiFi.h>
#include <FirebaseESP32.h>
#include <OneWire.h>
#include <DallasTemperature.h>
#include <dht11.h>

// FIREBASE VE WIFI TANIMLARI
#define FIREBASE_HOST "xxxxxxxxxx" // Buraya Firebase Host adı gelecek
#define FIREBASE_AUTH "xxxxxxxxxx" // Buraya Firebase gizli anahtarı gelecek

#define WIFI_SSID "xxxxxxxxxxx" // Buraya WiFi SSID (isim) gelecek
#define WIFI_PASSWORD "xxxxxxxxxx" // Buraya WiFi şifresi gelecek

// FirebaseESP32 instance'ı tanımlandı
FirebaseData firebaseData;

// SICAKLIK SENSÖRÜ TANIMLARI
// DS18B20'nin bağlı olduğu GPIO pini
const int oneWireBus = 32;     
// Tek kablo haberleşmesi sağlamak için oneWire instance'ı oluşturuldu
OneWire oneWire(oneWireBus);
// oneWire referansı Dallas Temperature sensörüne geçirildi
DallasTemperature sensors(&oneWire);

// ALEV SENSÖRÜ TANIMLARI
// Alev sensörünün bağlı olduğu GPIO pini
const int flameSensorPin = 35;

// GAZ SENSÖRÜ TANIMLARI
// Gaz sensörünün bağlı olduğu GPIO pini
const int gasSensorPin = 34;

// NEM SENSÖRÜ TANIMLARI
// Nem sensörünün bağlı olduğu GPIO pini
const int humiditySensorPin = 33;
// Nem sensöründen veri alabilmek için dht11 instance'ı tanımlandı
dht11 DHT11;

// Firebase'de oluşturulan yol
String path = "/SensorValues";

void setup() {
  // Seri monitör 115200 baud rate ile başlatıldı
  Serial.begin(115200);
  // DS18B20 sensörü başlatıldı
  sensors.begin();
  pinMode(flameSensorPin, OUTPUT);

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
}

void loop() {
  // Firebase.setXXX fonksiyonları önce belirlenen yola göre değişkeni Firebase'e aktarır, işlem başarılıysa true, başarısızsa false döndürür
  // Sıcaklık değerini Firebase'e aktar
  if (Firebase.setInt(firebaseData, path + "/Stream/tempValue", getTemp()))
    {
      // İşlem başarılıysa gönderilen veri yolunu, veri tipini ve verinin kendisini görüntüle
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
      // İşlem başarısızsa hatanın sebebini görüntüle
      Serial.println("FAILED");
      Serial.println("REASON: " + firebaseData.errorReason());
      Serial.println("------------------------------------");
      Serial.println();
    }

  // Gaz değerini Firebase'e aktar
  if (Firebase.setInt(firebaseData, path + "/Stream/gasValue", getGas()))
    {
      // İşlem başarılıysa gönderilen veri yolunu, veri tipini ve verinin kendisini görüntüle
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
      // İşlem başarısızsa hatanın sebebini görüntüle
      Serial.println("FAILED");
      Serial.println("REASON: " + firebaseData.errorReason());
      Serial.println("------------------------------------");
      Serial.println();
    }

  // Alev değerini Firebase'e aktar
  if (Firebase.setInt(firebaseData, path + "/Stream/flameValue", getFlame()))
    {
      // İşlem başarılıysa gönderilen veri yolunu, veri tipini ve verinin kendisini görüntüle
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
      // İşlem başarısızsa hatanın sebebini görüntüle
      Serial.println("FAILED");
      Serial.println("REASON: " + firebaseData.errorReason());
      Serial.println("------------------------------------");
      Serial.println();
    }

  // Nem değerini Firebase'e aktar
  if (Firebase.setInt(firebaseData, path + "/Stream/humidityValue", getHumidity()))
    {
      // İşlem başarılıysa gönderilen veri yolunu, veri tipini ve verinin kendisini görüntüle
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
      // İşlem başarısızsa hatanın sebebini görüntüle
      Serial.println("FAILED");
      Serial.println("REASON: " + firebaseData.errorReason());
      Serial.println("------------------------------------");
      Serial.println();
    }

  // Sensörleri yormamak için 200 mili saniyelik bir gecikme oluşturuldu
  delay(200);
}

// Sıcaklık değeri alma fonksiyonu
int getTemp() {
  // Sıcaklık sensöründen veri iste
  sensors.requestTemperatures(); 
  // Sıcaklık değerini Celsius olarak al
  int temperatureC = sensors.getTempCByIndex(0); 
  return temperatureC;
}

// Alev değeri alma fonksiyonu
int getFlame() {
  // Sıcaklık sensörünü analog olarak oku
  int flame_value = analogRead(flameSensorPin); 
  return flame_value;
}

// Gaz değeri alma fonksiyonu
int getGas() {
  // Gaz sensörünü analog olarak oku
  float sensorValue = analogRead(gasSensorPin);    
  // Analog değeri voltaj değerine dönüştür
  float sensorVolt = sensorValue * (5.0 / 4095.0); 
  // Hava direncini hesapla
  float rsAir = ((50.0 / sensorVolt) - 10.0);   
  // R0 direnci temiz havaya bırakılıp (r0 = rsAir / 4.4) formülüyle önceden hesaplandı
  float r0 = 6.0;

  // PPM değerini logaritmik olarak hesapla
  float ppmLog = (log10(rsAir / r0) - 1.133) / (-0.318);  
  // PPM değerini dönüştür
  int ppm = (int) pow(10, ppmLog);                       

  // PPM değeri 10000den büyükse 10000 değerini döndür, değilse ppm değerini döndür
  if (ppm > 10000)
    return 10000;
  else
    return ppm;
}

// Nem değeri alma fonksiyonu
int getHumidity() {
  // Nem sensörünü dijital olarak oku
  int chk = DHT11.read(humiditySensorPin); 
  // Nem değeri float olarak okunuyor
  float humid = (float) DHT11.humidity;
  // Float değerini integer olarak değiştir
  int humidity = (int) humid;
  return humidity;
}

// Seri monitörde görüntülemek üzere int ve float değerleri için Firebase verisi görüntüleme fonksiyonu
void printResult(FirebaseData &data){
  if (data.dataType() == "int")
    Serial.println(data.intData());
  else if (data.dataType() == "float")
    Serial.println(data.floatData(), 5);
  else
    Serial.println("Undefined data type.");
}
