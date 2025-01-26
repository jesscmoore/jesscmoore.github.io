---
layout: post
title:  "Build a Home Assistant Temperature & Humidity Sensor"
date:   2025-01-17 18:11:46 +1100
published: false
toc: true
---

How to build a temperature and humidity sensor accessible from OpenHAB Home Assistant

**Summary**

This is adapted from the https://github.com/gonium/esp8266-dht22-sensor repo by Gonium, using only the DHT22 temperature and humidity sensor.

1. [pip] - for installing platformio
2. [pyenv] - for setting python environment
3. [platformio] - compilation and installing firmware on the embedded board
4. [curl] - querying the device webpage

Optional: git for code versioning and VSCode editor with platformio IDE extension for editing, compiling and flashing the embedded board


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
- [curl]

## Procedure

### Clone project repo

Clone the project code, including submodule for DHT22, using:

    $ git clone --recurse-submodules https://github.com/jesscmoore/esp8266-dht22-sensor.git
    $ cd esp8266-dht22-sensor

If you forget to use [--recurse-submodules], run below to get the submodule

    $ git submodule update --init --recursive


### Install platformio and setup IDE

We start a virtual environment with `pyenv` to use python v3.11 for the project.

    $ pyenv virtualenv 3.11.0 esp8266_dht22_sensor_dev
    $ pyenv local esp8266_dht22_sensor_dev

PlatformIO is a cross-platform, cross-architecture, multiple framework tool for developing applications for embedded products.

    $ pip install -U pip setuptools
    $ pip install -U platformio

It can be run from command line or from within vscode with the VSCode platformio IDE. We use `VSCode` for editing, compiling and flashing the code, with the platformio extension providing icons similar to Ardruino IDE for compiling and flashing the code to the board.

From within VSCode, install the `platformio IDE extension`

Open VSCode

    $ code .


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

#### Add item for last update time

By default things each have a `Last Success` and `Last Failure` date time channels. Adding a datetime item to `Last Success` channel will make last update time available for the UI.

Open `Settings` > `Things` > click `RoomSensor HTTP Thing` > select `Channels` tab > click `Last Success` channel > click `Link Item to Channel` > and add these settings:

```
`Label`: `Last Update`
`Type`: `Datetime`
`Category`: `time`
`Semantic class`: choose `point`
`Semantic Property`: select `timestamp`
```

and click `Save`. The datetime will be displayed on the next data update.



### Add data to Openhab UI

Openhab is a webapp with native apps for Android and other major platforms.

It offers a variety of ways to design and edit the UI. The older method was using `Sitemaps` which are stored on raspberrypi in:

 `$OPENHAB_CONF/sitemaps`


Openhab UI is accessible from web browser or native android apps for iOS and Android. The mobile apps read the sitemap by default, although the Android version switches to the MainUI Overview page when viewed in landscape mode. Note, without a sitemap, portrait view on Android displays the MainUI very poorly.

For this reason, both MainUI Overview page and a sitemap are required. `Sitemaps`, `locations` and `pages` are all pages, which can be created and accessed from Pages section of the Settings submenu.

#### Creating a sitemap (for mobile viewers)

We will make a simple sitemap with two rows one for temperature and one for humidity under a heading with the location of the room sensor.

Sitemaps can be created by adding a `*.sitemap` file to `$OPENHAB_CONF/sitemaps` or in the admin settings of Openhab web app. For reference see the [demo sitemap](https://www.openhab.org/docs/ui/sitemaps.html) in the Openhab docs.

The `Create sitemap` shortcut is only visible from the `Developer Sidebar`, which we first must make visible.

Click `Developer Tools` > under `Maitenance Tools` set ` Developer Sidebar`: on

Next we will go to Pages, which is where we can access the sitemap and other pages from within Openhab.

Click `Settings` > `Pages` > on sidebar click `Create sitemap` > enter `Label`: enter `My Home Automation` or your preferred page heading


Then add a Frame to provide a heading with the location of our sensor.

Click `My Home Automation` > `Insert widget inside Sitemap` > choose `Frame` > `Label`: `Office` > `Icon`: choose `bedroom` > `Save`

Then we add a 1st text item widget for temperature.

Click `Insert Widget Inside Frame` > select `Text` > enter `Label`: `Temperature [%.1f °C]` > click `Item`: select `Room_temperature` item > click `Icon`: choose `temperature` > `Save`.

Next, add a 2nd text item widget for humidity.

Click `Insert Widget Inside Frame` > select `Text` > enter `Label`: `Humidity [%.1f %%]` > click `Item`: select `Room_humidity` item > click `Icon`: choose `humidity` > `Save`.


#### Edit MainUI Overview page (for web app users)

Edit the Overview page to add a temperature and humidity card. We will use the combined [temperature and humidity cell widget](https://community.openhab.org/t/temperature-and-humidity-display-widget/143601) created by github user `the-ninth`

Install this third party widget from the `Add-on Store`:

Click `Add-on Store` > select `User Interfaces` to install widgets > enter "temperature" in Search bar > select `Temperature and Humidity Display Widget` > click `Install`.

Now we can add this widget to the MainUI Overview page.

Click `Settings` > click `Pages` > click `Overview` > select `Design` tab > click `Add Row` > click `Add Cells` > click `+` > select `TemperatureHumidity` cell widget > click top right icon > choose `Configure Cell` > and add these settings:

```
Title: Office Climate
`Temperature item`: choose `Room_Temperature` item
`Humidity item`: choose `Room_Humidity` item
`Last update item`: choose `Last update` item
`Temperature label`: `Temperature`
`Temperature suffix`: `°C`
`Humidity label`: `Humidity`
`Humidity suffix`: `%`
`Last Update label`: `Last Update`

and click `Done` and click `Save`.

If we had created a channel and item for the sensor data time, we could have then added an item for last update field too.

Click `Save`.

Alternatively the above widgets can be added to the `blocks:` section of the code by clicking `Code` tab.

```
  - component: oh-block
    config: {}
    slots:
      default:
        - component: oh-grid-cells
          config: {}
          slots:
            default:
              - component: widget:TemperatureHumidity
                config:
                  hum_item: RoomSensor_HTTP_Thing_Room_Humidity
                  hum_label: Relative Humidity
                  hum_suffix: "%"
                  title: Main Bedroom Climate
                  tmp_item: RoomSensor_HTTP_Thing_Room_Temperature
                  tmp_label: Temperature
                  tmp_suffix: °C
                  update_item: RoomSensor_HTTP_Thing_Last_Success
                  update_label: Last Update
```

Clicking `openHAB` icon to navigate to homepage shows our overview page with temperature and humidity.

### Enable charts

Clicking `Analyzer` on number widget should show a time series chart of the measurements.

If no data points are displayed, check that `rrd4j` persistence is installed and set as the default persistence service.

Open `Add-on Store` > `Persistence` > clcik `RD4j Persistence` and check showing installed.

Under `Settings` > `Persistence` in Configuration menu > `Default Service`: check `RRD4J` selected.


### References

- [https://docs.platformio.org/en/latest/boards/espressif8266/nodemcuv2.html?utm_source=platformio&utm_medium=piohome]
- [https://docs.platformio.org/en/latest/projectconf/sections/env/options/upload/upload_port.html]
- [https://www.openhab.org/]
- [https://community.openhab.org/t/temperature-and-humidity-display-widget/143601]
