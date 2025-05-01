
# tasmota_vm-3p75ct_modbus_emulator - Emulates a Victron VM-3P75CT from Tasmota Smart Meter Interface Data

<small>GitHub repository: [phillipkremer/tasmota_vm-3p75ct_modbus_emulator](https://github.com/phillipkremer/tasmota_vm-3p75ct_modbus_emulator)</small>

## Index

1. [Disclaimer](#disclaimer)
2. [Purpose](#purpose)
4. [Tasmota](#tasmota)
5. [Install](#install)
6. [Config](#config)
7. [Registers](#registers)


## Disclaimer

I cannot guaranty that the script works as intended. I'm not responsible if you break something using my script. 


## Purpose

The script emulates the Modbus/UDP interface of a Victron VM-3P75CT. Possible data sources are the Tasmota SmartMeterInterface (if configured correctly), static values and calculated values from available data. 
The ESP32 Tasmota device is able to mimic every possible role and register, that the VM-3P75CT is able to provide. Settings can be adjusted via the built in Tasmota Web Interface.


## Tasmota

Use the provided `user_config_override.h` to compile a Tasmota with Berry and SmartMeterInterface. Be aware, that berry only works with ESP32. For compiling Tasmota refer to https://tasmota.github.io/docs/Compile-your-build/. You may need to alter the user_config-overwrite.h depending on the ESP32 board you are using. I use this https://www.amazon.de/-/en/dp/B071P98VTG board.
See https://tasmota.github.io/docs/Smart-Meter-Interface/ for detailed information on how to set up Tasmota-SmartMeterInterface. 

Depending on your individual Smart Meter, the first part of the script looks like this:
```
>D
>B
->sensor53 r
>M 1
+1,3,s,16,9600,MT175
```
Under https://tasmota.github.io/docs/Smart-Meter-Interface/#smart-meter-descriptors are several scripts listed for different smart meters. Choose the one for your meter and copy it under *Tools &rarr; Edit Script*. Than enable script. The device should restart and and available values should be shown at the Tasmota the starting page. 

Hardware wise I use this https://www.amazon.de/-/en/UEDING-Writing-Reading-Original-Microcontroller/dp/B0D9JSYQHY IR Adapter. Just connect 5V, GND, RX and TX. Works great.
You may need to unlock the IR Interface of your Smart Meter with a pin from your provider. 

Be aware that not every smart meter supports all information transmitted by a VM-3P75CT. You may need to use mock values, which you can configure under *Configuration &rarr; VM-3P75CT &rarr; Sensor Configuration*.

## Install

Go to *Tools &rarr; Manage File System* and upload the `autoexec.be` file. It is important that you don't rename the file. Restart the Tasmota device. The emulator is now installed and ready to be configured.

Now at the Tasmota starting page there will status messages be shown. 

## Config

Go to *Configuration &rarr; VM-3P75CT*. Here you are able to select a configured meter to be used as data source. For a three phase grid meter no other configuration needs to be done here.

Under *Sensor Configuration* you select per data register the corresponding meter sensor. You can only select sensors, which are configured in the script. You can also choose *Fixed Value* and *Calculated*. *Fixed Value* allows you to enter a fixed value for that data register. *Calculated* allows you to calculate the value of that data register based on other available values. 

Under *Alarms Configuration* you can set minimal and maximal values for frequency and voltage. If values are out of these borders alarms are raised. Alarms are also raised if no data is available from the configured meter or the meter isn't configured any more. You can set the the modbus server to shutdown if a alarm is raised. 

After enabling the modbus server (via button *Enable Server*) the device will be found by VenusOS when scanning for modbus devices. 

## Registers

###**🕵️ 0. Probe Register (Model Identification)**
 
| Hex Addr | Dec Addr | Register Type | Path | Data Format | Scale | Function Description |
| --- | --- | --- | --- | --- | --- | --- |
| 0x1000 | 4096 | Reg_u16 | — | 16-bit unsigned integer | — | **Model ID register**. Used by the `probe` system to identify device type (`0xA1B1`).|
***  
### 🧾 **1\. Info Registers (Static Device Info)**

| Address (Hex) | Address (Dec) | Register Type | Path | Data Format | Scale | Function Description |
| --- | --- | --- | --- | --- | --- | --- |
| `0x1001` | `4097` | `Reg_text` | `/Serial` | 8-byte ASCII string (64-bit) | — | Unique device serial number. Used for identification in Victron systems or diagnostics. |
| `0x1009` | `4105` | `VEReg_ver` | `/FirmwareVersion` | 32-bit encoded version tuple | — | Version of the firmware. Used for compatibility checks and feature gating. |
| `0x100B` | `4107` | `Reg_u16` | `/HardwareVersion` | 16-bit unsigned integer | — | Hardware revision number. Useful for support, troubleshooting, or feature mapping. |
| `0x2002` | `8194` | `Reg_text` | `/CustomName` | 32-byte UTF-8 string (256-bit) | — | User-defined name shown in GUIs (e.g. “Garage Meter”). Can be used for device labeling. |
***
### 🔄 **2\. Data Registers (Dynamic/Configurable Data)**


| Address (Hex) | Address (Dec) | Register Type | Path | Data Format | Scale | Function Description |
| --- | --- | --- | --- | --- | --- | --- |
| `0x2000` | `8192` | `Reg_u16` | — | 16-bit unsigned integer | — | Phase configuration (0=L1, 1=L2, 2=L3, 3=3-phase). Used to determine number of phases. |
| `0x2001` | `8193` | `Reg_u16` | — | 16-bit unsigned integer | — | Role ID index. Maps to: 0 = `grid`, 1 = `pvinverter`, 2 = `genset`, 3 = `acload`, 4 = `evcharger`, 5 = `heatpump`. |
| `0x2002` | `8194` | `Reg_text` | `/CustomName` | 32-byte UTF-8 string | — | Writable custom name. Displayed in GUI/system interfaces. Triggers reinit on change. |
| `0x2022` | `8226` | `Reg_u16` | `/Position` | 16-bit unsigned integer | — | Defines where the **meter is installed** in an AC topology: <br>`0` = **Grid-side** (before inverter) <br>`1` = **Load-side** (after inverter) <br>`2` = **AC-coupled PV input** <br><br/>📌 Relevant when role = `pvinverter` or `evcharger`. |

***
### ⚡ **3\. System-Level AC Registers** (firmware ≥ 0.1.3.1)
  
| Address (Hex) | Address (Dec) | Register Type | Path | Data Format | Scale | Function Description |
| --- | --- | --- | --- | --- | --- | --- |
| `0x3032` | `12338` | `Reg_u16` | `/Ac/Frequency` | 16-bit unsigned integer | × 0.01 | AC line frequency in Hz. Used for grid monitoring and stability checks. |
| `0x3033` | `12339` | `Reg_s16` | `/Ac/PENVoltage` | 16-bit signed integer | × 0.01 | Voltage between PEN conductor and reference. Important for safety/neutral checks. |
| `0x3034` | `12340` | `Reg_u32b` | `/Ac/Energy/Forward` | 32-bit unsigned (2×16-bit) | × 0.01 | Cumulative imported energy (kWh). Used for billing and energy tracking. |
| `0x3036` | `12342` | `Reg_u32b` | `/Ac/Energy/Reverse` | 32-bit unsigned (2×16-bit) | × 0.01 | Cumulative exported energy (kWh). Relevant for feed-in systems and energy balancing. |
| `0x3038` | `12344` | `Reg_u16` | `/ErrorCode` | 16-bit unsigned integer | — | Error state code. Used by monitoring systems for alarm or fault indication. <br><br/>0 = OK (No error) <br>1 = Internal hardware/software fault <br>2 = Voltage out of range <br>3 = CT sensor error (e.g. disconnected or damaged) <br>4 = Phase mismatch (e.g. 3-phase mode with only L1 wired) <br>5 = Grid frequency out of range e.g., &lt;45Hz or &gt;65Hz <br>255 = Unknown/undocumented error |
| `0x3080` | `12416` | `Reg_s32b` | `/Ac/Power` | 32-bit signed integer | — | Net AC power. Positive = import; Negative = export. Drives energy flow logic. |
* * *
### 🔁 **4\. Per-Phase Registers**
#### 🔌 **Phase L1**  
| Address (Hex) | Address (Dec) | Register Type | Path | Data Format | Scale | Function Description |
| --- | --- | --- | --- | --- | --- | --- |
| `0x3040` | `12352` | `Reg_s16` | `/Ac/L1/Voltage` | 16-bit signed integer | × 0.01 | Instantaneous line voltage on L1. Used for diagnostics and imbalance detection. |
| `0x3041` | `12353` | `Reg_s16` | `/Ac/L1/Current` | 16-bit signed integer | × 0.01 | Current on L1. Useful for load analysis and phase balancing. |
| `0x3042` | `12354` | `Reg_u32b` | `/Ac/L1/Energy/Forward` | 32-bit unsigned (2×16-bit) | × 0.01 | Imported energy on L1. Helps with per-phase billing/monitoring. |
| `0x3044` | `12356` | `Reg_u32b` | `/Ac/L1/Energy/Reverse` | 32-bit unsigned (2×16-bit) | × 0.01 | Exported energy on L1. Used in export monitoring systems. |
| `0x3082` | `12418` | `Reg_s32b` | `/Ac/L1/Power` | 32-bit signed integer | — | Active power on L1. Supports load profiling and optimization. |
#### 🔌 **Phase L2**
| Address (Hex) | Address (Dec) | Register Type | Path | Data Format | Scale | Function Description |
| --- | --- | --- | --- | --- | --- | --- |
| `0x3048` | `12360` | `Reg_s16` | `/Ac/L2/Voltage` | 16-bit signed integer | × 0.01 | Voltage on L2. Used to detect imbalance or dropped phases. |
| `0x3049` | `12361` | `Reg_s16` | `/Ac/L2/Current` | 16-bit signed integer | × 0.01 | Load current on L2. Key metric for 3-phase load balancing. |
| `0x304A` | `12362` | `Reg_u32b` | `/Ac/L2/Energy/Forward` | 32-bit unsigned (2×16-bit) | × 0.01 | Cumulative import energy on L2. |
| `0x304C` | `12364` | `Reg_u32b` | `/Ac/L2/Energy/Reverse` | 32-bit unsigned (2×16-bit) | × 0.01 | Cumulative export energy on L2. |
| `0x3086` | `12422` | `Reg_s32b` | `/Ac/L2/Power` | 32-bit signed integer | — | Instantaneous active power on L2. |
#### 🔌 **Phase L3**
| Address (Hex) | Address (Dec) | Register Type | Path | Data Format | Scale | Function Description |
| --- | --- | --- | --- | --- | --- | --- |
| `0x3050` | `12368` | `Reg_s16` | `/Ac/L3/Voltage` | 16-bit signed integer | × 0.01 | Voltage on L3. |
| `0x3051` | `12369` | `Reg_s16` | `/Ac/L3/Current` | 16-bit signed integer | × 0.01 | Current on L3. |
| `0x3052` | `12370` | `Reg_u32b` | `/Ac/L3/Energy/Forward` | 32-bit unsigned (2×16-bit) | × 0.01 | Energy imported on L3. |
| `0x3054` | `12372` | `Reg_u32b` | `/Ac/L3/Energy/Reverse` | 32-bit unsigned (2×16-bit) | ×0.01 | Cumulative reverse (export) energy on L3 (kWh). |
| `0x308A` | `12426` | `Reg_s32b` | `/Ac/L3/Power` | 32-bit signed integer | — | Real-time active power on L3 (W). |


