# Cumulocity Modbus Demo
Example implementation of a modbus device in **Cumulocity IoT**. The demo device sends random values via modubus TCP. In the following it will be shown how to easily connect and read the values from the device with Cumulocity IoT.

Cumulocity is an IoT platform that enables rapid connections of many, many different devices and applications. It allows you to monitor and respond to IoT data in real time and to spin up this capability in minutes. More information on Cumulocity IoT and how to start a free trial can be found [here](https://www.softwareag.cloud/site/product/cumulocity-iot.html#/).

Cumulocity IoT enables companies to quickly and easily implement smart IoT solutions.

The [Cumulocity IoT documentation](https://cumulocity.com/guides/protocol-integration/cloud-fieldbus/) contains detailed instructions on how to connect fieldbus devices to the platform.
______________________


For more information you can Ask a Question in the [TECHcommunity Forums](https://tech.forums.softwareag.com/).
______________________

These tools are provided as-is and without warranty or support. They do not constitute part of the Software AG product suite. Users are free to use, fork and modify them, subject to the license agreement. While Software AG welcomes contributions, we cannot guarantee to include every contribution in the master project.

Contact us at [TECHcommunity](mailto:technologycommunity@softwareag.com?subject=Github/SoftwareAG) if you have any questions.

## Getting started

Simply start via:

```bash
git clone URL
cd cumulocity-modbus-demo
docker-compose up 
```

There will be two containers ramped up:

1. The linux agent that contains the modbus functionality
2. A Modbus simulator, that simulates a power


## Device Registration

On Cumulocity side you have to register the device in your tenant. In the config.ini you have to use an identifier such as the serial number or mac address.
This serial number will be used for the registration purpose. You can find it within the cumulocity-agent.conf under the key. Please change at the beginning.

![Devie Registration](https://recordit.co/NbNj1VdQu4.gif)


## Device Protocol


## Device Configuration Modbus

Within the device management Application of Cumulocity you will find the tab "ModBus" after the device was registred successfully.

![Devie Registration](./pics/ModBus-dm.png)

Within here, you can add an TCP Device. Please 