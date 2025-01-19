---
layout: post
title:  "Build a Home Assistant Temperature & Humidity Sensor"
date:   2025-01-17 18:11:46 +1100
published: true
toc: true
---

How to build a temperature and humidity sensor accessible from OpenHAB Home Assistant

**Summary**

This is adapted from the https://github.com/gonium/esp8266-dht22-sensor repo by Gonium, using only the DHT22 temperature and humidity sensor.

1. [command] - 1 line explanation
2. [command] - 1 line explanation


## Requires

Hardware:

- ESP8266 chip with wifi - I use the NodeMCU Lolin V3 with ESP8266, serial monitor and micro USB power plug.
- DHT22 temperature and humidity sensor
- 10kOhm resistor
- Micro USB cable
- WIFI access

Software:

- [esp8266 by ESP8266 Community] board driver
- [python] - v3.11 used
- [pyenv]
- [platformio] - for code compilation and flashing the board
- [git]
- [curl]

## Procedure

### Clone project repo

Clone the project code, including submodule for DHT22, using:

    $ git clone --recurse-submodules https://github.com/jesscmoore/esp8266-dht22-sensor.git
    $ cd esp8266-dht22-sensor

If you forget to use [--recurse-submodules], run below to get the submodule

    $ git submodule update --init --recursive


### Install platformio and setup IDE

PlatformIO is a cross-platform, cross-architecture, multiple framework tool for developing applications for embedded products.

    $ pip install -U pip setuptools
    $ pip install -U platformio

It can be run from command line or from within vscode with the VSCode platformio IDE. We use `VSCode` for editing, compiling and flashing the code, with the platformio extension providing icons similar to Ardruino IDE for compiling and flashing the code to the board.

From within VSCode, install the `platformio IDE extension`

Open VSCode

    $ code .

We start a virtual environment with `pyenv` to use python v3.11 for the project.

    $ pyenv virtualenv 3.11.0 esp8266_dht22_sensor_dev
    $ pyenv local esp8266_dht22_sensor_dev


### Configure host, wifi and sensor

Configuration details are stored in `config.h` which is excluded from the repo with [.gitignore]. We created a `config.h` file based on `config_sample.h`.

    $ cp config_sample.h config.h

We edited `config.h` to provide our wifi SSID, password and the hostname to broadcase via MDNS.

The code allows for either DHT22 temperature and humidity sensor or the temperature-only DS18S20 sensor. We use the DHT22 sensor. Include following and comment out other sensors in `config.h`:

```
#define MAX_NUM_SENSORS 1
// Option 1: you have a DHT22/DHT11 temp/hum sensor.
#define SENSOR_DHT22 1
#define DHTTYPE DHT22
```

### Configure platformio for board

Platformio uses a `platformio.ini` file in top folder of the project to specify the board, port and required details.

We looked up the board on PlatformIO board manager to find the details.

In VSCode, click `PlatformIO` icon in LHS panel to open the `PIO Home` tab and click `Boards` and enter `NodeMCU` in the search bar to search the list of supported boards. The board of the NodeMCU Lolin V3 is `NodeMCU 1.0 (ESP-12E Module)`. This shows the platform and allowed frameworks for this board. Clicking the name hyperlink shows the platformio configuration options for this board. Our code is written in Arduino framework, so this must be specified in our configuration for VSCode to check and compile the code.

Create `platform.ini` with this text:

```
; PlatformIO Project Configuration File
;
;   Build options: build flags, source filter
;   Upload options: custom upload port, speed and extra flags
;   Library options: dependencies, extra library storages
;   Advanced options: extra scripting
;
; Please visit documentation for the other options and examples
; https://docs.platformio.org/page/projectconf.html

[env:nodemcu_esp8266]
platform = espressif8266
framework = arduino
board = nodemcuv2
```
where `env` label is an arbitrary user given name for the configuration.

Note, framework and targets are not necessary for this board.

### Specify port

PlatformIO attempts to automatically detect the port. However without `upload_port` specified it will typically select an incorrect port. By speicifying a port, or limiting it to serial ports, we ensure the correct port is used.

List serial ports to get the port name of the usb port connected to the NodeMCU board.

```
ls /dev/*serial*
/dev/cu.usbserial-130  /dev/tty.usbserial-130
```
The port to use is `/dev/cu.usbserial-130`

Update platformio.ini to specify the port:
```
; any port beginning with /dev/cu.usbserial
upload_port = /dev/cu.usbserial*
```


### Specify serial monitor baud rate

Update `platformio.ini` to use baud speed 115200

```
; Serial Monitor options
monitor_speed = 115200
```

### Compile & upload

Click the "tick" icon to compile.

Successful compilation will write the binary to [.pio/build/nodemcu_esp8266] and print should end with
```
Building .pio/build/nodemcu_esp8266/firmware.bin
Creating BIN file ".pio/build/nodemcu_esp8266/firmware.bin" using "/Users/u9904893/.platformio/packages/framework-arduinoespressif8266/bootloaders/eboot/eboot.elf" and ".pio/build/nodemcu_esp8266/firmware.elf"
================================= [SUCCESS] Took 13.53 seconds =================================
```

Click the '->' icon to upload and run.


Alternatively, the project can be compiled and uploaded on command line with:
```
platformio run && platformio serialports monitor
```


Opening modem admin webpage, shows `ESP-27E090	10.1.1.141` ie. that the device is online.

Clicking the 'plug' icon to open the serial monitor on VSCode, shows illegible text. Perhaps the baud rate is note correct.

Removed the baud rate specification in platformio.ini and recompiled and reuploaded.

Success, the serial monitor is now displaying output.

```
-- Terminal on /dev/cu.usbserial-130 | 9600 8-N-1
--- Available filters and text transformations: colorize, debug, default, direct, esp8266_exception_decoder, hexlify, log2file, nocontrol, printable, send_on_enter, time
--- More details at https://bit.ly/pio-monitor-filters
--- Quit: Ctrl+C | Menu: Ctrl+T | Help: Ctrl+T followed by Ctrl+H
..................
Connected to iiNetC2780B
IP address: 10.1.1.141
MDNS responder started
Registered handler for /temperature/0

```

After updating code to include `dht.begin();` and define the DHTpin with the full pin name, the code works.

Successfully writing temperature and humidity to webpage!!

Temperature is 21 degrees which is sufficiently accurate for our needs.
Humidity remains constant at 99.90% which is incorrect.

The sensor should now be accessible under ````http://10.1.1.141```` and ````http://roomsensor````.

    $ curl http://10.1.1.141
    Measurements of device roomsensor
    Sensor 0 temperature: 21.05 degree Celsius
    Sensor 0 humidity: 99.90 % r.H.

    $ curl http://10.1.1.141/temperature/0
    {"temperature": 22.88,"unit": "Celsius"}%

    $ curl http://10.1.1.141/humidity
    {"humidity": 99.90,"unit": "% r.H."}%


### Connect Openhab to sensor
#### Install Jsonpath transformation

Reading json data requires the jsonpath transformation

Click `Add-on Store` > click `Transformation` tab in bottom menu > select `JSONPATH Transformation` > click `Install`

#### Add a thing for sensor

Openhab connects to devices by its IP address and the binding used to tell Openhab how to talk to the device.



For Openhab to read the data published online by the device, each json data key published by the device needs to be added to the thing as a channel with linked item.

#### Add channel for temperature

Open `Channel` tab to add channels to the HTTP Room Sensor Thing.

Click `Show Advanced` to see all the options and add these settings, then `Save`. The `Label` is the shorthand version of the channel UID identifier, where the channel UID will be set based on the label. The `Description` is the display name for the field.

Don't forget the `/0` appended to the url extension, as our device publishes the temperature at `http://10.1.1.141/temperature/0`.

```
Label: Room_Temperature
Description: Temperature
State transformation: JSONPATH($.temperature)
State url extension: temperature/0
Read only: true
```

#### Add item for temperature

Choose `Add linked item` to the Room_Temperature channel and add these settings, then `Save`.

The `Name` of the item is [thing]_[channel].

Note: temperature is one of the available dimensions. This will give us a choice of Celsius, Kelvin or Faranheit units. Category is where the icon is selected, and will show a thermometer icon after `Temperature` is selected.

```
Label: Temperature
Type: Number
Dimension: select `Temperature (o C)`
Unit: select `o C`
Category: select `Temperature`
Semantic class: select `Point`
Semantic property: leave blank (maybe specify `Temperature` later)
Non-semantic tags: leave blank
Parent groups: leave blank
```

After clicking `Save`, successful data read will be seen by the value shown under the data value shown on the item.

Now we add the data format, select `State Description`. Use standard number formatting to define the format and we use `%unit%` to append the unit, e.g. enter:

```
%.1f %unit%
```


#### Add channel for humidity

Follow the same process to create a humidity channel, with only the unit field different

```
Label: Room_Humidity
Description: Humidity
State transformation: JSONPATH($.humidity)
State url extension: humidity
Read only: true
```

**Keep unit field blank.** As humidity is not one of the available `dimensions` in the item configurations, the item will give an `UNDEF` error if item is provided. Instead we specify the data format and append unit in the metadata of the item.

#### Add item for humidity

Choose `Add linked item` to the Room_Temperature channel and add these settings, then `Save`.

The `Name` of the item is [thing]_[channel].

Note: humidity is **not** one of the available dimensions, hence we will use State Description to append the unit. Category is where the icon is selected, and will show a thermometer icon after `Temperature` is selected.

```
Label: Temperature
Type: Number
Dimension: select `Temperature (o C)`
Unit: select `o C`
Category: select `Temperature`
Semantic class: select `Point`
Semantic property: leave blank (maybe specify `Temperature` later)
Non-semantic tags: leave blank
Parent groups: leave blank
```

After clicking `Save`, successful data read will be seen by the value shown under the data value shown on the item.

Now we add the data format and unit by adding metadata to the `State Description`. The "%" symbol for humidity unit must be escaped with another "%".

Select `State Description` > `Add metadata` > `Pattern`: `%.1f %%`

The humidity will now be displayed with 1 decimal place and % units.


### Add data to Openhab UI

Openhab is a webapp with native apps for Android and other major platforms.

It offers a variety of ways to design and edit the UI. Using `Sitemaps` may be the easiest way.

Sitemaps seem to be not supported in OpenHab Main UI. However they would allow easy editing $OPENHAB_CONF/sitemaps on raspberrypi. Perhaps using vscode connected to raspberrypi.

In `VSCode new window` > `<>` Connect to `jmoore@raspberrypi`

VSCode will begin download and setup of the VSCode Server on the remote host.


### References

- [https://docs.platformio.org/en/latest/boards/espressif8266/nodemcuv2.html?utm_source=platformio&utm_medium=piohome]
- [https://docs.platformio.org/en/latest/projectconf/sections/env/options/upload/upload_port.html]
- [https://www.openhab.org/]
- [https://community.openhab.org/t/temperature-and-humidity-display-widget/143601]
