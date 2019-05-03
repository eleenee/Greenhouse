#include <Wire.h>
#include "DHTesp.h"
#include <Adafruit_Sensor.h>
#include <Adafruit_BMP280.h>
#include <Servo.h>

#include <ESP8266WiFi.h>
#include <PubSubClient.h>

#define SEALEVELPRESSURE_HPA (1013.25)

#define BME_ADDRESS 0x76
#define DHT11_PIN D6
#define Y25_PIN D5
#define WATERING_INDICATOR_PIN D1
#define LIGHT_INDICATOR_PIN D2
//#define SERVO_PIN D6

const char* outTemperature = "greenhouse/outside/temperature";
const char* outPressure = "greenhouse/outside/pressure";
const char* outAir = "greenhouse/air/isOpened";
const char* outWaterLevel = "greenhouse/water/criticalLevel";
const char* outIsWatering = "greenhouse/water/isWatering";

const char* inTemperature = "greenhouse/inside/temperature";
const char* inHumidity = "greenhouse/inside/humidity";
const char* inSoilTemperature = "greenhouse/inside/soil/temperature";
const char* inSoilMoisture = "greenhouse/inside/soil/moisture";
const char* inIsLight = "greenhouse/inside/light";

const char* ssid = "ssid";
const char* password = "password";
const char* mqtt_server = "192.168.1.45";

const unsigned long delayTime = 1000;
const unsigned long period = 60000;

WiFiClient espClient;
PubSubClient client(espClient);

Adafruit_BMP280 bme;
DHTesp dht;
Servo servo;

//boolean isWindowOpen = false;
//boolean isWatering = false;
//boolean isLightOn = false;

long lastMsg = 0;
char msg[10];
float tempOut = 0;
float tempIn = 0;
float pressure = 0;
float humidity = 0;
unsigned int water = 0;


void setup() {
    
  Serial.begin(9600);
  delay(10);

  // setup BME280 sensor (outside temperature, pressure)
  Wire.begin(D3, D4);
  delay(10);

  if (!bme.begin(BME_ADDRESS)) {
    delay(500);
    Serial.println("Could not find a valid BME280 sensor, check wiring!");
  } 
  //Serial.println("BMP280 is OK");
  //delay(10);

  // DHT11 setup
  dht.setup(DHT11_PIN, DHTesp::DHT11);

  // setup XKC-Y25-PNP water sensor
  pinMode(Y25_PIN, INPUT);
  //Serial.println("Water sensor is OK");

  // setup watering
  pinMode(WATERING_INDICATOR_PIN, OUTPUT);
  //gitalWrite(WATERING_INDICATOR_PIN, HIGH);
  //delay(100);
  //digitalWrite(WATERING_INDICATOR_PIN, LOW);
  //Serial.println("Watering is OK");

  // setup light
  pinMode(LIGHT_INDICATOR_PIN, OUTPUT);
  //digitalWrite(LIGHT_INDICATOR_PIN, HIGH);
  //delay(100);
  //digitalWrite(LIGHT_INDICATOR_PIN, LOW);
  //Serial.println("Lights is OK");

  // setup servo (window open)
  //servo.attach(SERVO_PIN);
  //servo.write(90);
  //delay(delayTime);
  //servo.write(0);
  //delay(delayTime);
  //servo.detach();
  //Serial.println("Servo is OK");

  setup_wifi();

  client.setServer(mqtt_server, 1883);
  client.setCallback(callback);
  client.subscribe(outIsWatering);
  //client.subscribe(outAir);
  client.subscribe(inIsLight);
  
}


void loop() { 

    if (!client.connected()) {
      reconnect();
    }
    client.loop();

    long now = millis();
    if (now - lastMsg > period) {
      lastMsg = now;
      
      tempOut = bme.readTemperature();
      pressure = bme.readPressure()  / 100.0F;

      tempIn = dht.getTemperature();
      humidity = dht.getHumidity();
      
      water = digitalRead(Y25_PIN);

      Serial.println();
      snprintf (msg, 10, "%.1f", tempOut);
      client.publish(outTemperature, dtostrf(tempOut, 3, 1, msg), true);
      printPublishedMessage(outTemperature, msg);

      snprintf (msg, 10, "%.0f", pressure);
      client.publish(outPressure, dtostrf(pressure, 3, 0, msg), true);
      printPublishedMessage(outPressure, msg);
      
      snprintf (msg, 10, "%d", water);
      client.publish(outWaterLevel, dtostrf(water, 1, 0, msg), true);
      printPublishedMessage(outWaterLevel, msg); 

      snprintf (msg, 10, "%.1f", tempIn);
      client.publish(inTemperature, dtostrf(tempIn, 3, 1, msg), true);
      printPublishedMessage(inTemperature, msg);

      snprintf (msg, 10, "%.1f", humidity);
      client.publish(inHumidity, dtostrf(humidity, 3, 1, msg), true);
      printPublishedMessage(inHumidity, msg);
    }
}

void printPublishedMessage(const char* topic, char* msg) {
  Serial.print("MEASSAGE PUBLISHED: ");
  Serial.print(topic);
  Serial.print(": ");
  Serial.println(msg);
}

void setup_wifi() {

  delay(10);
  Serial.println();
  Serial.print("Connecting to ");
  Serial.println(ssid);

  WiFi.begin(ssid, password);

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  Serial.println("");
  Serial.println("WiFi connected");
  Serial.println("IP address: ");
  Serial.println(WiFi.localIP());
}

void reconnect() {
  while (!client.connected()) {
    Serial.print("Attempting MQTT connection...");
    if (client.connect("ESP8266Client")) {
      Serial.println("connected");
      //client.publish("outTopic", "hello world");
      client.subscribe(outIsWatering);
      //client.subscribe(outAir);
      client.subscribe(inIsLight);
  
    } else {
      Serial.print("failed, rc=");
      Serial.print(client.state());
      Serial.println(" try again in 5 seconds");
      delay(5*delayTime);
    }
  }
}

void callback(char* topic, byte* payload, unsigned int length) {
  
  Serial.print("MESSAGE ARRIVED: \"");
  Serial.print(topic);
  Serial.print("\" - \" ");
  for (int i = 0; i < length; i++) {
    Serial.print((char)payload[i]);
  }
  Serial.println(" \".");


  if (strcmp(topic, outIsWatering) == 0) {
      if ((char)payload[0] == '1') {
        //isWatering = true;
        turnOnWatering();
      } else {
        //isWatering = false;
        turnOffWatering();
      }
    }
  //if (strcmp(topic, outAir) == 0) {
      //if ((char)payload[0] == '1') {
        //isWindowOpen = true;
        //servo.attach(SERVO_PIN);
        //servo.write(90);
        //delay(100);
        //servo.detach();
      //} else {
        //isWindowOpen = false; 
        //servo.attach(SERVO_PIN);
        //servo.write(0); 
        //delay(100);
        //servo.detach();
      //}
    //}
  if (strcmp(topic, inIsLight) == 0) {
      
      if ((char)payload[0] == '1') {
        //isLightOn = true;
        turnOnLight();
      } else {
        //isLightOn = false;
        turnOffLight();
      }
    }
}

void turnOnLight() {
  digitalWrite(LIGHT_INDICATOR_PIN, HIGH); 
}

void turnOffLight() {
  digitalWrite(LIGHT_INDICATOR_PIN, LOW);
}

void turnOnWatering() {
  digitalWrite(WATERING_INDICATOR_PIN, HIGH); 
}

void turnOffWatering() {
  digitalWrite(WATERING_INDICATOR_PIN, LOW);
}


void printValues() {
  
    Serial.print("Temperature = ");
    Serial.print(bme.readTemperature());
    Serial.println(" *C");

    Serial.print("Pressure = ");
    Serial.print(bme.readPressure() / 100.0F);
    Serial.println(" hPa");

    Serial.print("Approx. Altitude = ");
    Serial.print(bme.readAltitude(SEALEVELPRESSURE_HPA));
    Serial.println(" m");

    Serial.println();
}
