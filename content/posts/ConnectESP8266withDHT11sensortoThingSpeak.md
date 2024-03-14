+++
title = 'Connect ESP8266 with DHT11 sensor to ThingSpeak'
date = 2024-01-06T20:34:07+01:00
description = "In this tutorial I will explain you how to connect your ESP8266-01 to ThingSpeak and read some data."
tags = [ "IoT", "Electronic"]
draft = false
+++

## Introduction

**In this tutorial I will explain you how to connect your ESP8266-01 to ThingSpeak and read some data.**

### Use Arduino IDE and load this program: 

```
# code block
#include "DHT.h"
#include "ESP8266WiFi.h"
#include "ThingSpeak.h"

const char * api_key = "abcdef";
const char * ssid = "wifi-name";
const char * pass = "wifi-password";
unsigned long myChannelNumber=12345678;
const char* server = "api.thingspeak.com";

#define DHTPIN 2
#define DHTTYPE DHT11
DHT dht (DHTPIN, DHTTYPE);

WiFiClient client;
float t;
float h;


void setup()
{
ThingSpeak.begin(client);
dht.begin();
Serial.begin(115200);
delay(10);

WiFi.begin(ssid, pass);

  while (WiFi.status() != WL_CONNECTED)
    {
    delay(500);
    Serial.print(".");
    }
}


void loop()
{

h = 10+dht.readHumidity();
t = dht.readTemperature();

ThingSpeak.setField(1,t);
ThingSpeak.setField(2,h);

ThingSpeak.writeFields(myChannelNumber,api_key);
delay(2000);
}


    
```

### Remember to change all the initial parameters:

api_key = *"YOUR KEY"*

ssid = *"wifi name"*

pass = *"wifi password"*

myChannelNumber = *"channel number"*



### Go to Files -> Preferences and insert this link in “Additional Boards Manager URLs”:

https://arduino.esp8266.com/stable/package_esp8266com_index.json


### Navigate to "Tools" and select "Manage Libraries." Install the following libraries:

1) Adafruit ESP8266

2) Adafruit DHT Sensor 

3) ThingSpeak IoT

### As you have installed all the necessary libraries you can upload the code to your esp connected via usb serial

**Connect the ESP8266 to the DHT11 in this way**

ESP8266:

GND -> GND

VCC -> 3.3V

IO2 -> DHT11 Data

![scheme](/esp8266/image.png)

If you have done all the steps correctly you will find the data in thingspeak

![chart](/esp8266/charts.png)
