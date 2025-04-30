import webserver
import string
import persist
import json

class VM_3P75CT_emulater
    
    def init()

        # set hostname
        if tasmota.cmd("Hostname", true)["Hostname"] != "VM-3P75CT-Emulator"
            tasmota.cmd("Hostname VM-3P75CT-Emulator", true)
            print("New Hostname: VM-3P75CT-Emulator")
        end        
        # register fast_loop method
        tasmota.add_fast_loop(/-> self.fast_loop())
        global.server = udp()
        global.server_running = false 
        global.server_sutdown = true

        # error list
        global.errors = list(false, false, false, false, false, false)
        global.connected = false

        global.settings_safed = 0

        # create key value map, where is key(config name), value(list(registers, hassensor, value, type, calculated, scale)
        global.configs = map()
        var value1
        var value2 
        var value3     
        
        # first start
        if persist.has("first_start") value1 = bool(persist.member("first_start")) else value1 = true end
        global.configs.insert("first_start", list(list(), false, value1, "bool", false, 0)) 
        # server enable 
        if persist.has("server_enable") value1 = bool(persist.member("server_enable")) else value1 = false end
        global.configs.insert("server_enable", list(list(), false, value1, "bool", false, 0)) 
        # meter name 
        if persist.has("meter") value1 = persist.member("meter") else value1 = false end
        global.configs.insert("meter", list(list(), false, value1, "string", false, 0))    
        # phase config
        if persist.has("phase_config") value1 = int(persist.member("phase_config")) else value1 = 3 end
        global.configs.insert("phase_config", list(list(8192), false, value1, "uint", false, 0))
        # role
        if persist.has("role") value1 = int(persist.member("role")) else value1 = 0 end
        global.configs.insert("role", list(list(8193), false, value1, "uint", false, 0))
        # error handling
        if persist.has("error_handling") value1 = int(persist.member("error_handling")) else value1 = 0 end
        global.configs.insert("error_handling", list(list(), false, value1, "error_handling", false, 0))
        # custom_name
        if persist.has("custom_name") value1 = persist.member("custom_name") else value1 = "VM-3P75CT Emulator" end
        global.configs.insert("custom_name", list(list(8194,8195,8196,8197,8198,8199,8200,8201,8202,8203,8204,8205,8206,8207,8208,8209,8210,
        8211,8212,8213,8214,8215,8216,8217,8218,8219,8220,8221,8222,8223,8224,8225), false, value1, "string", false, 0))
        # inverter position
        if persist.has("position") value1 = int(persist.member("position")) else value1 = 0 end
        global.configs.insert("position", list(list(8226), false, value1, "uint", false, 0))
        # frequency
        if persist.has("frequency_sensor") value2 = bool(persist.member("frequency_sensor")) else value2 = false end
        if persist.has("frequency") if value2 value1 = persist.member("frequency") else value1 = int(persist.member("frequency")) end else value1 = 0 end
        global.configs.insert("frequency", list(list(12338), value2, value1, "uint", false, 1))
        # pen voltage
        if persist.has("pen_voltage_sensor") value2 = bool(persist.member("pen_voltage_sensor")) else value2 = false end
        if persist.has("pen_voltage") if value2 value1 = persist.member("pen_voltage") else value1 = int(persist.member("pen_voltage")) end else value1 = 0 end
        global.configs.insert("pen_voltage", list(list(12339), value2, value1, "sint", false, 1))
        # frequency min max
        if persist.has("frequency_min") value1 = real(persist.member("frequency_min")) else value1 = 45 end
        if persist.has("frequency_max") value2 = real(persist.member("frequency_max")) else value2 = 55 end
        global.configs.insert("frequency_min", list(list(), false, value1, "uint", false, 1))
        global.configs.insert("frequency_max", list(list(), false, value2, "uint", false, 1))
        # voltage min max
        if persist.has("voltage_min") value1 = real(persist.member("voltage_min")) else value1 = 220 end
        if persist.has("voltage_max") value2 = real(persist.member("voltage_max")) else value2 = 240 end
        global.configs.insert("voltage_min", list(list(), false, value1, "sint", false, 100))
        global.configs.insert("voltage_max", list(list(), false, value2, "sint", false, 100))
        # imported energy 
        if persist.has("imported_energy_sensor") value2 = bool(persist.member("imported_energy_sensor")) else value2 = false end
        if persist.has("imported_energy") if value2 value1 = persist.member("imported_energy") else value1 = int(persist.member("imported_energy")) end else value1 = 0 end
        global.configs.insert("imported_energy", list(list(12340,12341), value2, value1, "uint", false, 100))
        # exported energy 
        if persist.has("exported_energy_sensor") value2 = bool(persist.member("exported_energy_sensor")) else value2 = false end
        if persist.has("exported_energy") if value2 value1 = persist.member("exported_energy") else value1 = int(persist.member("exported_energy")) end else value1 = 0 end
        global.configs.insert("exported_energy", list(list(12342,12343), value2, value1, "uint", false, 100))
        # ac power
        if persist.has("ac_power_sensor") value2 = bool(persist.member("ac_power_sensor")) else value2 = false end
        if persist.has("ac_power") if value2 value1 = persist.member("ac_power") else value1 = real(persist.member("ac_power")) end else value1 = 0 end
        global.configs.insert("ac_power", list(list(12416,12417), value2, value1, "sint", false, 0))
        # voltage l1
        if persist.has("voltage_l1_calculated") value3 = bool(persist.member("voltage_l1_calculated")) else value3 = false end
        if persist.has("voltage_l1_sensor") value2 = persist.member("voltage_l1_sensor") else value2 = false end
        if persist.has("voltage_l1") if value2 value1 = persist.member("voltage_l1") else value1 = real(persist.member("voltage_l1")) end else value1 = 0 end
        global.configs.insert("voltage_l1", list(list(12352), value2, value1, "sint", value3, 100))
        # current l1 
        if persist.has("current_l1_calculated") value3 = bool(persist.member("current_l1_calculated")) else value3 = false end
        if persist.has("current_l1_sensor") value2 = persist.member("current_l1_sensor") else value2 = false end
        if persist.has("current_l1") if value2 value1 = persist.member("current_l1") else value1 = real(persist.member("current_l1")) end else value1 = 0 end
        global.configs.insert("current_l1", list(list(12353), value2, value1, "sint", value3, 100))
        # imported energy l1 
        if persist.has("imported_energy_l1_calculated") value3 = bool(persist.member("imported_energy_l1_calculated")) else value3 = false end
        if persist.has("imported_energy_l1_sensor") value2 = bool(persist.member("imported_energy_l1_sensor")) else value2 = false end
        if persist.has("imported_energy_l1") if value2 value1 = persist.member("imported_energy_l1") else value1 = real(persist.member("imported_energy_l1")) end else value1 = 0 end
        global.configs.insert("imported_energy_l1", list(list(12354,12355), value2, value1, "uint", value3, 100))
        # exported energy l1
        if persist.has("exported_energy_l1_calculated") value3 = bool(persist.member("exported_energy_l1_calculated")) else value3 = false end 
        if persist.has("exported_energy_l1_sensor") value2 = bool(persist.member("exported_energy_l1_sensor")) else value2 = false end
        if persist.has("exported_energy_l1") if value2 value1 = persist.member("exported_energy_l1") else value1 = real(persist.member("exported_energy_l1")) end else value1 = 0 end
        global.configs.insert("exported_energy_l1", list(list(12356,12357), value2, value1, "uint", value3, 100))
        # power l1
        if persist.has("power_l1_calculated") value3 = bool(persist.member("power_l1_calculated")) else value3 = false end
        if persist.has("power_l1_sensor") value2 = persist.member("power_l1_sensor") else value2 = false end
        if persist.has("power_l1") if value2 value1 = persist.member("power_l1") else value1 = real(persist.member("power_l1")) end else value1 = 0 end
        global.configs.insert("power_l1", list(list(12418,12419), value2, value1, "sint", value3, 1))
        # voltage l2 
        if persist.has("voltage_l2_calculated") value3 = bool(persist.member("voltage_l2_calculated")) else value3 = false end
        if persist.has("voltage_l2_sensor") value2 = persist.member("voltage_l2_sensor") else value2 = false end
        if persist.has("voltage_l2") if value2 value1 = persist.member("voltage_l2") else value1 = real(persist.member("voltage_l2")) end else value1 = 0 end
        global.configs.insert("voltage_l2", list(list(12360), value2, value1, "sint", value3, 100))
        # current l2 
        if persist.has("current_l2_calculated") value3 = bool(persist.member("current_l2_calculated")) else value3 = false end
        if persist.has("current_l2_sensor") value2 = persist.member("current_l2_sensor") else value2 = false end
        if persist.has("current_l2") if value2 value1 = persist.member("current_l2") else value1 = real(persist.member("current_l2")) end else value1 = 0 end
        global.configs.insert("current_l2", list(list(12361), value2, value1, "sint", value3, 100))
        # imported energy l2 
        if persist.has("imported_energy_l2_calculated") value3 = bool(persist.member("imported_energy_l2_calculated")) else value3 = false end
        if persist.has("imported_energy_l2_sensor") value2 = persist.member("imported_energy_l2_sensor") else value2 = false end
        if persist.has("imported_energy_l2") if value2 value1 = persist.member("imported_energy_l2") else value1 = real(persist.member("imported_energy_l2")) end else value1 = 0 end
        global.configs.insert("imported_energy_l2", list(list(12362,12363), value2, value1, "uint", value3, 100))
        # exported energy l2 
        if persist.has("exported_energy_l2_calculated") value3 = bool(persist.member("exported_energy_l2_calculated")) else value3 = false end
        if persist.has("exported_energy_l2_sensor") value2 = persist.member("exported_energy_l2_sensor") else value2 = false end
        if persist.has("exported_energy_l2") if value2 value1 = persist.member("exported_energy_l2") else value1 = real(persist.member("exported_energy_l2")) end else value1 = 0 end
        global.configs.insert("exported_energy_l2", list(list(12364,12365), value2, value1, "uint", value3, 100))
        # power l2
        if persist.has("power_l2_calculated") value3 = bool(persist.member("power_l2_calculated")) else value3 = false end
        if persist.has("power_l2_sensor") value2 = persist.member("power_l2_sensor") else value2 = false end
        if persist.has("power_l2") if value2 value1 = persist.member("power_l2") else value1 = real(persist.member("power_l2")) end else value1 = 0 end
        global.configs.insert("power_l2", list(list(12422,12423), value2, value1, "sint", value3, 1))
        # voltage l3
        if persist.has("voltage_l3_calculated") value3 = bool(persist.member("voltage_l3_calculated")) else value3 = false end
        if persist.has("voltage_l3_sensor") value2 = persist.member("voltage_l3_sensor") else value2 = false end
        if persist.has("voltage_l3") if value2 value1 = persist.member("voltage_l3") else value1 = real(persist.member("voltage_l3")) end else value1 = 0 end
        global.configs.insert("voltage_l3", list(list(12368), value2, value1, "sint", value3, 100))
        # current l3 
        if persist.has("current_l3_calculated") value3 = bool(persist.member("current_l3_calculated")) else value3 = false end
        if persist.has("current_l3_sensor") value2 = persist.member("current_l3_sensor") else value2 = false end
        if persist.has("current_l3") if value2 value1 = persist.member("current_l3") else value1 = real(persist.member("current_l3")) end else value1 = 0 end
        global.configs.insert("current_l3", list(list(12369), value2, value1, "sint", value3, 100))
        # imported energy l3 
        if persist.has("imported_energy_l3_calculated") value3 = bool(persist.member("imported_energy_l3_calculated")) else value3 = false end
        if persist.has("imported_energy_l3_sensor") value2 = persist.member("imported_energy_l3_sensor") else value2 = false end
        if persist.has("imported_energy_l3") if value2 value1 = persist.member("imported_energy_l3") else value1 = real(persist.member("imported_energy_l3")) end else value1 = 0 end
        global.configs.insert("imported_energy_l3", list(list(12370,12371), value2, value1, "uint", value3, 100))
        # exported energy l3 
        if persist.has("exported_energy_l3_calculated") value3 = bool(persist.member("exported_energy_l3_calculated")) else value3 = false end
        if persist.has("exported_energy_l3_sensor") value2 = persist.member("exported_energy_l3_sensor") else value2 = false end
        if persist.has("exported_energy_l3") if value2 value1 = persist.member("exported_energy_l3") else value1 = real(persist.member("exported_energy_l3")) end else value1 = 0 end
        global.configs.insert("exported_energy_l3", list(list(12372,12373), value2, value1, "uint", value3, 100))
        # power l3
        if persist.has("power_l3_calculated") value3 = bool(persist.member("power_l3_calculated")) else value3 = false end
        if persist.has("power_l3_sensor") value2 = persist.member("power_l3_sensor") else value2 = false end
        if persist.has("power_l3") if value2 value1 = persist.member("power_l3") else value1 = real(persist.member("power_l3")) end else value1 = 0 end
        global.configs.insert("power_l3", list(list(12426,12427), value2, value1, "sint", value3, 1))
                
        # create key value map, where is key(modbusregister), value(list(value, rw)
        global.registers = map()
        global.registers.insert(4096, list(bytes('a1b1'), false))      # device magic number
        global.registers.insert(4097, list(bytes('3838'), false))      # serial 1 (88888888)
        global.registers.insert(4098, list(bytes('3838'), false))      # serial 2 (88888888)
        global.registers.insert(4099, list(bytes('3838'), false))      # serial 3 (88888888)
        global.registers.insert(4100, list(bytes('3838'), false))      # serial 4 (88888888)
        global.registers.insert(4101, list(bytes('3838'), false))      # serial 5 (88888888)
        global.registers.insert(4102, list(bytes('3838'), false))      # serial 6 (88888888)
        global.registers.insert(4103, list(bytes('3838'), false))      # serial 7 (88888888)
        global.registers.insert(4104, list(bytes('3838'), false))      # serial 8 (88888888)
        global.registers.insert(4105, list(bytes('0002'), false))      # firmware version 1
        global.registers.insert(4106, list(bytes('00FF'), false))      # firmware version 2
        global.registers.insert(4107, list(bytes('0001'), false))      # hardware version (1) 
        for i: 0 .. 34
            global.registers.insert(8192 + i, list(bytes('0000'), true))  # system registers
        end       
        global.registers.insert(12338, list(bytes('0000'), false))   # frequency
        global.registers.insert(12339, list(bytes('0000'), false))   # pen voltage
        global.registers.insert(12340, list(bytes('0000'), false))   # imported energy 
        global.registers.insert(12341, list(bytes('0000'), false))   # imported energy 
        global.registers.insert(12342, list(bytes('0000'), false))   # exported energy
        global.registers.insert(12343, list(bytes('0000'), false))   # exported energy
        global.registers.insert(12416, list(bytes('0000'), false))   # ac power
        global.registers.insert(12417, list(bytes('0000'), false))   # ac power
        global.registers.insert(12352, list(bytes('0000'), false))   # voltage l1 
        global.registers.insert(12353, list(bytes('0000'), false))   # current l1 
        global.registers.insert(12354, list(bytes('0000'), false))   # imported energy l1
        global.registers.insert(12355, list(bytes('0000'), false))   # imported energy l1 
        global.registers.insert(12356, list(bytes('0000'), false))   # exported energy l1 
        global.registers.insert(12357, list(bytes('0000'), false))   # exported energy l1
        global.registers.insert(12418, list(bytes('0000'), false))   # power l1
        global.registers.insert(12419, list(bytes('0000'), false))   # power l1 
        global.registers.insert(12360, list(bytes('0000'), false))   # voltage l2 
        global.registers.insert(12361, list(bytes('0000'), false))   # current l2
        global.registers.insert(12362, list(bytes('0000'), false))   # imported energy l2
        global.registers.insert(12363, list(bytes('0000'), false))   # imported energy l2
        global.registers.insert(12364, list(bytes('0000'), false))   # exported energy l2
        global.registers.insert(12365, list(bytes('0000'), false))   # exported energy l2
        global.registers.insert(12422, list(bytes('0000'), false))   # power l2
        global.registers.insert(12423, list(bytes('0000'), false))   # power l2
        global.registers.insert(12368, list(bytes('0000'), false))   # voltage l2
        global.registers.insert(12369, list(bytes('0000'), false))   # current l3
        global.registers.insert(12370, list(bytes('0000'), false))   # imported energy l3
        global.registers.insert(12371, list(bytes('0000'), false))   # imported energy l3 
        global.registers.insert(12372, list(bytes('0000'), false))   # exported energy l3
        global.registers.insert(12373, list(bytes('0000'), false))   # exported energy l3
        global.registers.insert(12426, list(bytes('0000'), false))   # power l3
        global.registers.insert(12427, list(bytes('0000'), false))   # power l3
        global.registers.insert(12344, list(bytes('0000'), false))   # error code
        global.registers.insert(12345, list(bytes('0000'), false))   # undocumented
        global.registers.insert(12346, list(bytes('0000'), false))   # undocumented
        global.registers.insert(12347, list(bytes('0000'), false))   # undocumented
        global.registers.insert(12348, list(bytes('0000'), false))   # undocumented
        global.registers.insert(12349, list(bytes('0000'), false))   # undocumented
        global.registers.insert(12350, list(bytes('0000'), false))   # undocumented
        global.registers.insert(12351, list(bytes('0000'), false))   # undocumented
        global.registers.insert(12358, list(bytes('0000'), false))   # undocumented
        global.registers.insert(12359, list(bytes('0000'), false))   # undocumented
        global.registers.insert(12420, list(bytes('0000'), false))   # undocumented
        global.registers.insert(12421, list(bytes('0000'), false))   # undocumented
        global.registers.insert(12366, list(bytes('0000'), false))   # undocumented
        global.registers.insert(12367, list(bytes('0000'), false))   # undocumented
        global.registers.insert(12424, list(bytes('0000'), false))   # undocumented
        global.registers.insert(12425, list(bytes('0000'), false))   # undocumented
        global.registers.insert(12374, list(bytes('0000'), false))   # undocumented
        global.registers.insert(12375, list(bytes('0000'), false))   # undocumented
        global.registers.insert(12428, list(bytes('0000'), false))   # undocumented
        global.registers.insert(12429, list(bytes('0000'), false))   # undocumented
        for i: 0 .. 34
            global.registers.insert(16384 + i, list(bytes('0000'), true)) # custom name input registers
        end       
        #update registers
        self._register_values_update(false)
        self._register_values_update(true)
        # set Device Name
        if tasmota.cmd("DeviceName", true)["DeviceName"] != global.configs.item("custom_name")[2]
            tasmota.cmd("DeviceName " + global.configs.item("custom_name")[2], true)
            print("New DeviceName: " + global.configs.item("custom_name")[2])
        end  
        self._write_config_to_persist(true)
        # check for first start, if so safe and restart
        if global.configs.item("first_start")[2]
            print(global.configs.item("first_start")[2])
            global.configs.item("first_start")[2] = false
            self._write_config_to_persist(true)
            print("Rebooting...")
            tasmota.cmd("Restart 1")
        end
    end

    def web_add_main_button()
        webserver.content_send("<div style='padding:0'><hr><table style='width: 100%;'>")
        if !global.configs.item("server_enable")[2] webserver.content_send("<tr><td><label><b>Modbus UDP Server</b></label></td><td align=\"right\"><label style='color:red;'>Disabled</label></td></tr>") end
        if global.configs.item("server_enable")[2] webserver.content_send("<tr><td><label><b>Modbus UDP Server</b></label></td><td align=\"right\"><label style='color:green;'>Enabled</label></td></tr>") end
        if global.server_running webserver.content_send("<tr><td><label><b>Server Status</b></label></td><td align=\"right\"><label style='color:green;'>Running</label></td></tr>") end
        if !global.server_running && global.configs.item("server_enable")[2] webserver.content_send("<tr><td><label><b>Server Status</b></label></td><td align=\"right\"><label style='color:red;'>Offline</label></td></tr>") end
        if global.server_running && global.connected webserver.content_send("<tr><td><label><b>Connection Status</b></label></td><td align=\"right\"><label style='color:green;'>Connected</label></td></tr>") end
        if global.server_running && !global.connected webserver.content_send("<tr><td><label><b>Connection Status</b></label></td><td align=\"right\"><label style='color:red;'>Disconnected</label></td></tr>") end
        if global.server_running && global.connected webserver.content_send("<tr><td><label><b>GX Device IP</b></label></td><td align=\"right\">"..global.server.remote_ip.."</td></tr>") end
        if global.errors[0] webserver.content_send("<tr><td><label style='color:red;'><b>Error:</b></label></td><td align=\"right\">Meter not connected</td></tr>") end
        if global.errors[1] webserver.content_send("<tr><td><label style='color:red;'><b>Error:</b></label></td><td align=\"right\">Voltage out of range</td></tr>") end
        if global.errors[2] webserver.content_send("<tr><td><label style='color:red;'><b>Error:</b></label></td><td align=\"right\">No data available</td></tr>") end
        if global.errors[3] webserver.content_send("<tr><td><label style='color:red;'><b>Error:</b></label></td><td align=\"right\">Phase mismatch</td></tr>") end
        if global.errors[4] webserver.content_send("<tr><td><label style='color:red;'><b>Error:</b></label></td><td align=\"right\">Grid frequency out of range</td></tr>") end
        if global.errors[5] webserver.content_send("<tr><td><label style='color:red;'><b>Error:</b></label></td><td align=\"right\">Unknown error</td></tr>") end
        webserver.content_send("</table><hr></div>")
    end 

    def web_add_config_button() # add button in config page
        webserver.content_send("<p><form id=vmconfig action='vm' style='display: block;' method='get'><button>VM-3P75CT</button></form></p>")    # add button in config page
    end

    def vm_3p75ct_config()
        if !webserver.check_privileged_access() return nil end
        webserver.content_start("VM-3P75CT Configuration")
        webserver.content_send_style()
        webserver.content_send("<style>fieldset { margin-top: 10px; margin-bottom: 10px; }</style>")
        webserver.content_send("<div><h3><hr><center>VM-3P75CT Settings</center><hr></h3></div>")
        if global.settings_safed == 1 webserver.content_send("<label id='settings_safed'><center><h3><p style='color:green;'>Settings safed</p></h3></center></label>") global.settings_safed = 0 end
        if global.settings_safed == 2 webserver.content_send("<label id='settings_safed'><center><h3><p style='color:red;'>Failed saving settings</p></h3></center></label>") global.settings_safed = 0 end
        webserver.content_send("<form method='post' action='vm'>")
        webserver.content_send("<fieldset><label><center><b>General Settings</b></center></label>")
        # meter selection
        webserver.content_send("<fieldset><legend><b>Meter Selection</b></legend>")
        webserver.content_send("<select id='meter' name='meter'>")
        if global.configs.item("meter")[2] != "false" && global.configs.item("meter")[2] != false && global.configs.item("meter")[2] != "" 
            webserver.content_send("<option value="..global.configs.item("meter")[2]..">"..global.configs.item("meter")[2].."</option>") 
        end
        webserver.content_send("<option value='false'></option>")
        webserver.content_send("<option value='false'>None</option>")
        var meters = json.load(tasmota.read_sensors()).keys()
        for i: 1 .. json.load(tasmota.read_sensors()).size() var key = meters() if key != "Time" && key != global.configs.item("meter")[2] webserver.content_send("<option value="..key..">"..key.."</option>") end end
        webserver.content_send("</select></fieldset>")
        # phase configuration
        webserver.content_send("<fieldset><legend><b>Phase Configuration</b></legend>")
        webserver.content_send("<select id='phase_config' name='phase_config'>")
        var name = ""
        if global.configs.item("phase_config")[2] == 0 name = "Only L1" end
        if global.configs.item("phase_config")[2] == 1 name = "Only L2" end
        if global.configs.item("phase_config")[2] == 2 name = "Only L3" end
        if global.configs.item("phase_config")[2] == 3 name = "Three Phase" end
        webserver.content_send("<option value="..global.configs.item("phase_config")[2]..">"..name.."</option>") 
        if global.configs.item("phase_config")[2] != 0 webserver.content_send("<option value=0>Only L1</option>") end
        if global.configs.item("phase_config")[2] != 1 webserver.content_send("<option value=1>Only L2</option>") end
        if global.configs.item("phase_config")[2] != 2 webserver.content_send("<option value=2>Only L3</option>") end
        if global.configs.item("phase_config")[2] != 3 webserver.content_send("<option value=3>Three Phase</option>") end
        webserver.content_send("</select></fieldset>")
        # custom name
        webserver.content_send("<fieldset><legend><b>Custom Name</b></legend>")
        webserver.content_send("<input type='text' id='custom_name' name='custom_name' maxlength='32' pattern='[A-Za-z0-9 _\\.\\-\\:\\@\\#\\!\\/\\(\\)\\[\\]\"]*' value='"..global.configs.item("custom_name")[2].."'>")
        webserver.content_send("</fieldset>")
        # role
        webserver.content_send("<fieldset><legend><b>Role</b></legend>")
        webserver.content_send("<select id='role' name='role'>")
        name = ""
        if global.configs.item("role")[2] == 0 name = "Grid" end
        if global.configs.item("role")[2] == 1 name = "PV Inverter" end
        if global.configs.item("role")[2] == 2 name = "Generator" end
        if global.configs.item("role")[2] == 3 name = "AC Load" end
        if global.configs.item("role")[2] == 4 name = "EV Charger" end
        if global.configs.item("role")[2] == 5 name = "Heatpump" end
        webserver.content_send("<option value="..global.configs.item("role")[2]..">"..name.."</option>") 
        if global.configs.item("role")[2] != 0 webserver.content_send("<option value=0>Grid</option>") end
        if global.configs.item("role")[2] != 1 webserver.content_send("<option value=1>PV Inverter</option>") end
        if global.configs.item("role")[2] != 2 webserver.content_send("<option value=2>Generator</option>") end
        if global.configs.item("role")[2] != 3 webserver.content_send("<option value=3>AC Load</option>") end
        if global.configs.item("role")[2] != 4 webserver.content_send("<option value=4>EV Charger</option>") end
        if global.configs.item("role")[2] != 5 webserver.content_send("<option value=5>Heatpump</option>") end
        webserver.content_send("</select></fieldset>")
        # position
        webserver.content_send("<fieldset id=positionfielset style='display: none;'><legend><b>Position</b></legend>")
        webserver.content_send("<select id='position' name='position'>")
        name = ""
        if global.configs.item("position")[2] == 0 name = "Grid Side" end
        if global.configs.item("position")[2] == 1 name = "Load Site" end
        if global.configs.item("position")[2] == 2 name = "Alternate" end
        webserver.content_send("<option value="..global.configs.item("position")[2]..">"..name.."</option>") 
        if global.configs.item("position")[2] != 0 webserver.content_send("<option value=0>Grid</option>") end
        if global.configs.item("position")[2] != 1 webserver.content_send("<option value=1>PV Inverter</option>") end
        if global.configs.item("position")[2] != 2 webserver.content_send("<option value=2>Generator</option>") end
        webserver.content_send("</select></fieldset>")
        webserver.content_send("<button name='settings_safe' type='submit' class='bgrn'>Safe</button>")
        webserver.content_send("</fieldset></form><fieldset>")
        webserver.content_send("<p><form id=vmsensors action='vms' style='display: block;' method='get'><button>Sensor Configuration</button></form></p>")
        webserver.content_send("<p><form id=vmsalarms action='vma' style='display: block;' method='get'><button>Alarms Configuration</button></form></p>")
        if !global.configs.item("server_enable")[2] webserver.content_send("<p><form id=vmsenable name=vmsenable action='vme' style='display: block;' method='post'><button class='bgrn'>Enable Server</button></form></p>") end
        if global.configs.item("server_enable")[2] webserver.content_send("<p><form id=vmsdisable name=vmsdisable action='vmd' style='display: block;' method='post'><button class='bred'>Disable Server</button></form></p>") end
        webserver.content_send("<p><form id='vmreset' action='vmr' style='display: block;' method='post' onsubmit='return confirm(\"Are you sure you want to reset the configuration?\");'>"+
            "<button class='bred'>Reset Configuration</button></form></p></fieldset>")
        webserver.content_button(webserver.BUTTON_MAIN)
        # Tasmota-style inline script
        webserver.content_send("<script>"
            "document.addEventListener('DOMContentLoaded', function() {"
                # Optional handling of settings_safed
                "var settings_safed = document.getElementById('settings_safed');"
                "if (settings_safed) {" 
                    "settings_safed.style.display = '';"
                    "setTimeout(function() { settings_safed.style.display = 'none'; }, 5000);"
                "}"
                # Sanitize input in the custom_name field
                "document.getElementById('custom_name').addEventListener('input', function(e) {"
                    "this.value = this.value.replace(/[^A-Za-z0-9 _\\.\\-:@#!\\/()[\\]\"']/g, '');"
                "});"
                # Update fieldset legend and display based on select value
                # Function to handle the logic for both on load and on change
                "function updatePositionFieldset() {"
                    "var role = document.getElementById('role');"
                    "var position = document.getElementById('positionfielset');"
                    "var legend = position.querySelector('legend');"
                    # Apply the logic based on the selected value
                    "if (role.value == 1) {"
                        "position.style.display = '';"
                        "legend.innerHTML = '<b>Position of PV Inverter</b>';"
                    "} else if (role.value == 4) {"
                        "position.style.display = '';"
                        "legend.innerHTML = '<b>Position of EV Charger</b>';"
                    "} else {"
                        "position.style.display = 'none';"
                    "}"
                "}"
                # Add event listener for the 'change' event
                "document.getElementById('role').addEventListener('change', updatePositionFieldset);"
                # Call the function on page load to apply the logic initially
                "window.addEventListener('load', updatePositionFieldset);"
            "});"
        "</script>")
        webserver.content_stop()
    end
     
    def vm_3p75ct_sensor_config()
        var sensors = list()
        if json.load(tasmota.read_sensors()).find(global.configs.item("meter")[2], false) != false 
            var meter = json.load(tasmota.read_sensors())[global.configs.item("meter")[2]].keys()
            if size(json.load(tasmota.read_sensors())[global.configs.item("meter")[2]]) > 0 
                for i: 1 .. size(json.load(tasmota.read_sensors())[global.configs.item("meter")[2]]) sensors = sensors .. meter() end
            else sensors = list() end else sensors = list()
        end
        if !webserver.check_privileged_access() return nil end
        webserver.content_start("VM-3P75CT Configuration")
        webserver.content_send_style()
        webserver.content_send("<style>fieldset { margin-top: 10px; margin-bottom: 10px; }</style>")
        webserver.content_send("<div><h3><hr><center>VM-3P75CT Settings</center><hr></h3></div>")
        if global.settings_safed == 1 webserver.content_send("<label id='settings_safed'><center><h3><p style='color:green;'>Settings safed</p></h3></center></label>") global.settings_safed = 0 end
        if global.settings_safed == 2 webserver.content_send("<label id='settings_safed'><center><h3><p style='color:red;'>Failed saving settings</p></h3></center></label>") global.settings_safed = 0 end
        webserver.content_send("<form method='post' action='vms'>")
        webserver.content_send("<fieldset><label><center><b>Sensor Settings</b></center></label>")
        webserver.content_send("<fieldset><legend><b>Totals</b></legend>")
        webserver.content_send(self._render_sensor_field("Fequency", "frequency", "Hz", list(), sensors, 100))
        webserver.content_send(self._render_sensor_field("PEN Voltage", "pen_voltage", "V", list(), sensors, 500))
        webserver.content_send(self._render_sensor_field("Power", "ac_power", "W", list(), sensors, 50000))
        webserver.content_send(self._render_sensor_field("Imported", "imported_energy", "kWh", list(), sensors, 10000000))
        webserver.content_send(self._render_sensor_field("Exported", "exported_energy", "kWh", list(), sensors, 10000000))
        webserver.content_send("</fieldset><fieldset><legend><b>Phase L1</b></legend>")
        webserver.content_send(self._render_sensor_field("Voltage", "voltage_l1", "V", list("Power / Current"), sensors, 500))
        webserver.content_send(self._render_sensor_field("Current", "current_l1", "A", list("Power / Voltage"), sensors, 100))
        webserver.content_send(self._render_sensor_field("Power", "power_l1", "W", list("Voltage x Current", "Total Power / 3", "Total Power"), sensors, 50000))
        webserver.content_send(self._render_sensor_field("Imported", "imported_energy_l1", "kWh", list("Total Imported", "Total Imported / 3"), sensors, 10000000))
        webserver.content_send(self._render_sensor_field("Exported", "exported_energy_l1", "kWh", list("Total Exported", "Total Exported / 3"), sensors, 10000000))
        webserver.content_send("</fieldset><fieldset><legend><b>Phase L2</b></legend>")
        webserver.content_send(self._render_sensor_field("Voltage", "voltage_l2", "V", list("Power / Current"), sensors, 500))
        webserver.content_send(self._render_sensor_field("Current", "current_l2", "A", list("Power / Voltage"), sensors, 100))
        webserver.content_send(self._render_sensor_field("Power", "power_l2", "W", list("Voltage x Current", "Total Power / 3", "Total Power"), sensors, 50000))
        webserver.content_send(self._render_sensor_field("Imported", "imported_energy_l2", "kWh", list("Total Imported", "Total Imported / 3"), sensors, 10000000))
        webserver.content_send(self._render_sensor_field("Exported", "exported_energy_l2", "kWh", list("Total Exported", "Total Exported / 3"), sensors, 10000000))
        webserver.content_send("</fieldset><fieldset><legend><b>Phase L3</b></legend>")
        webserver.content_send(self._render_sensor_field("Voltage", "voltage_l3", "V", list("Power / Current"), sensors, 500))
        webserver.content_send(self._render_sensor_field("Current", "current_l3", "A", list("Power / Voltage"), sensors, 100))
        webserver.content_send(self._render_sensor_field("Power", "power_l3", "W", list("Voltage x Current", "Total Power / 3", "Total Power"), sensors, 50000))
        webserver.content_send(self._render_sensor_field("Imported", "imported_energy_l3", "kWh", list("Total Imported", "Total Imported / 3"), sensors, 10000000))
        webserver.content_send(self._render_sensor_field("Exported", "exported_energy_l3", "kWh", list("Total Exported", "Total Exported / 3"), sensors, 10000000))
        webserver.content_send("</fieldset>")
        webserver.content_send("<button type='submit' class='bgrn'>Safe</button>")
        webserver.content_send("</fieldset></form><fieldset>")
        webserver.content_send("<p><form id=vmgeneral action='vm' style='display: block;' method='get'><button>General Settings</button></form></p>")
        webserver.content_send("<p><form id=vmsalarms action='vma' style='display: block;' method='get'><button>Alarms Configuration</button></form></p></fieldset>")
        webserver.content_button(webserver.BUTTON_MAIN)
        webserver.content_send("<script>"
            "document.addEventListener('DOMContentLoaded', function() {"
            "var settings_safed = document.getElementById('settings_safed');"
            "if (settings_safed) {" 
                "settings_safed.style.display = '';"
                "setTimeout(function() { settings_safed.style.display = 'none'; }, 5000);"
            "}});"
        "</script>");
        webserver.content_stop()
    end

    def _render_sensor_field(name, key, unit, calculated, sensors, valuerange)
        var items = ""
        var calculateditems = ""
        var fixed_value = 0
        if !global.configs.item(key)[1] items = items + "<option value='fixed_value'>Fixed Value</option>" fixed_value = global.configs.item(key)[2] end
        if global.configs.item(key)[4] items = items + "<option value='calculated'>Calculated</option>" end
        if !global.configs.item(key)[4] && global.configs.item(key)[1] items = items + "<option value='"..global.configs.item(key)[2].."'>"..global.configs.item(key)[2].."</option>" end
        if size(sensors) > 0 for i: 1 .. size(sensors) if global.configs.item(key)[2] != sensors[i-1] items = items + "<option value="..sensors[i-1]..">"..sensors[i-1].."</option>" end end end
        if size(calculated) > 0 
            if global.configs.item(key)[4] calculateditems = calculateditems + "<option value="..string.escape(global.configs.item(key)[2])..">"..global.configs.item(key)[2].."</option>" end
            for i: 1 .. size(calculated) if calculated[i-1] != global.configs.item(key)[2] 
                calculateditems = calculateditems + "<option value="..string.escape(calculated[i-1])..">"..calculated[i-1].."</option>" 
            end end 
            if !global.configs.item(key)[4] items = items + "<option value='calculated'>Calculated</option>" end
        else 
            calculateditems = "<option value='dummy'></option>"
        end
        if global.configs.item(key)[1] items = items + "<option value='fixed_value'>Fixed Value</option>" end
        return ""+
        "<table style='width:100%'>"+
        # Setting
        "<tr><td style='width:2%'></td>"+
        "<td style='width:43%'><b>"..name.."</b></td>"+
        "<td style='width:53%'>"+
        "<select id='"..key.."' name="..key..">"+ items +
        "</select></td><td style='width:2%'></td></tr>"+
        # Calculated
        "<tr id='"..key.."_calculated_row'><td style='width:2%'></td>"+
        "<td style='width:43%'>Value =</td>"+
        "<td style='width:53%'>"+
        "<select id='"..key.."_calculated'".."name='"..key.."_calculated'>"+ calculateditems +
        "</select></td><td style='width:2%'></td></tr>"+
        # Fixed Value
        "<tr id='"..key.."_fixed_value_row".."'><td style='width:2%'></td>"+
        "<td style='width:43%'>Value ("..unit..") =</td>"+
        "<td style='width:53%'>"+
        "<input type='number' step='0.01' id='"..key.."_fixed_value' name='"..key.."_fixed_value' min='0' max='"..valuerange.."' value="..fixed_value..">"+
        "</td>"+
        "<td style='width:2%'></td></tr>"+
        "</table>"+
        # Script
        "<script>"+
            "document.getElementById('"..key.."').addEventListener('change', function () {"+
                "document.getElementById('"..key.."_calculated_row').style.display = this.value === 'calculated' ? 'table-row' : 'none';"+
                "document.getElementById('"..key.."_fixed_value_row').style.display = this.value === 'fixed_value' ? 'table-row' : 'none';"+
                "if (this.value !== 'calculated' && this.value !== 'fixed_value') {"+
                    "document.getElementById('"..key.."_calculated_row').style.display = 'none';"+
                    "document.getElementById('"..key.."_fixed_value_row').style.display = 'none';"+
                "}"+
            "});"+
            "window.addEventListener('load', function () {"+
                "if (document.getElementById('"..key.."').value === 'calculated') {"+
                    "document.getElementById('"..key.."_calculated_row').style.display = 'table-row';"+
                    "document.getElementById('"..key.."_fixed_value_row').style.display = 'none';"+
                "} else if (document.getElementById('"..key.."').value === 'fixed_value') {"+
                    "document.getElementById('"..key.."_calculated_row').style.display = 'none';"+
                    "document.getElementById('"..key.."_fixed_value_row').style.display = 'table-row';"+
                "} else {"+
                    "document.getElementById('"..key.."_calculated_row').style.display = 'none';"+
                    "document.getElementById('"..key.."_fixed_value_row').style.display = 'none';"+
                "}"+
            "});"+
        "</script>"
    end

    def _render_alarm_field(name, unit, valuerange)
        return "<fieldset><legend><b>"..name.."</b></legend>"+
        "<table style='width:100%'>"+
        "<tr><td style='width:10%'></td><td style='width:40%'>Min Value:</td><td style='width:30%'>"+
        "<input type='number' step='0.01' id='"..string.tolower(name).."_min' name='"..string.tolower(name).."_min'  min='0' max='"..valuerange.."' value="..global.configs.item(string.tolower(name)+"_min")[2]..">"+
        "</td><td>"..unit.."</td></tr>" +
        "<tr><td style='width:10%'></td><td style='width:40%'>Max Value:</td><td style='width:30%'>"+
        "<input type='number' step='0.01' id='"..string.tolower(name).."_max' name='"..string.tolower(name).."_max'  min='0' max='"..valuerange.."' value="..global.configs.item(string.tolower(name)+"_max")[2]..">"+
        "</td><td>"..unit.."</td></tr>" +
        "</table></fieldset>"
    end

    def vm_3p75ct_config_save()
        if !webserver.check_privileged_access() return nil end
        try
            if webserver.has_arg("settings_safe") && webserver.has_arg("meter") && webserver.has_arg("phase_config") && webserver.has_arg("custom_name") && webserver.has_arg("role") && webserver.has_arg("position")   
                var meter = false
                if webserver.arg("meter") == "false" meter = false else meter = webserver.arg("meter") end
                global.configs.setitem("meter", list(global.configs.item("meter")[0], global.configs.item("meter")[1], 
                    meter, global.configs.item("meter")[3], global.configs.item("meter")[4], global.configs.item("meter")[5]))
                global.configs.setitem("phase_config", list(global.configs.item("phase_config")[0], global.configs.item("phase_config")[1],
                    int(webserver.arg("phase_config")), global.configs.item("phase_config")[3], global.configs.item("phase_config")[4], global.configs.item("phase_config")[5]))
                global.configs.setitem("custom_name", list(global.configs.item("custom_name")[0], global.configs.item("custom_name")[1], 
                    webserver.arg("custom_name"), global.configs.item("custom_name")[3], global.configs.item("custom_name")[4], global.configs.item("custom_name")[5]))
                global.configs.setitem("role", list(global.configs.item("role")[0], global.configs.item("role")[1], 
                    int(webserver.arg("role")), global.configs.item("role")[3], global.configs.item("role")[4], global.configs.item("role")[5]))
                global.configs.setitem("position", list(global.configs.item("position")[0], global.configs.item("position")[1], 
                    int(webserver.arg("position")), global.configs.item("position")[3], global.configs.item("position")[4], global.configs.item("position")[5]))               
                global.settings_safed = 1
                self._register_values_update(false)
                self._write_config_to_persist(true)
                webserver.redirect("/vm") 
            else
                raise "value_error", "Unknown command"
            end
        except .. as e, m
            print(format("BRY: Exception> '%s' - %s", e, m))
            global.settings_safed = 2
            webserver.redirect("/vm")                  
        end
    end

    def vm_3p75ct_alarms_config()
        if !webserver.check_privileged_access() return nil end
        webserver.content_start("VM-3P75CT Configuration")
        webserver.content_send_style()
        webserver.content_send("<style>fieldset { margin-top: 10px; margin-bottom: 10px; }</style>")
        webserver.content_send("<div><h3><hr><center>VM-3P75CT Settings</center><hr></h3></div>")
        if global.settings_safed == 1 webserver.content_send("<label id='settings_safed'><center><h3><p style='color:green;'>Settings safed</p></h3></center></label>") global.settings_safed = 0 end
        if global.settings_safed == 2 webserver.content_send("<label id='settings_safed'><center><h3><p style='color:red;'>Failed saving settings</p></h3></center></label>") global.settings_safed = 0 end
        webserver.content_send("<form method='post' action='vma'>")
        webserver.content_send("<fieldset><label><center><b>Alarm Settings</b></center></label>")
        webserver.content_send(self._render_alarm_field("Frequency", "Hz", 100))
        webserver.content_send(self._render_alarm_field("Voltage", "V", 500))
        webserver.content_send("<fieldset><legend><b>Error Handling</b></legend><table style='width:100%'><tr><td style='width:10%'></td><td style='width:80%'>")
        webserver.content_send("<select id='error_handling' name='error_handling'>")
        var handling = ""
        if global.configs.item("error_handling")[2] == 0 handling = "Server up, availible values" end
        if global.configs.item("error_handling")[2] == 2 handling = "Shut down server" end
        webserver.content_send("<option value="..global.configs.item("error_handling")[2]..">"..handling.."</option>") 
        if global.configs.item("error_handling")[2] != 0 webserver.content_send("<option value=0>Server up, availible values</option>") end
        if global.configs.item("error_handling")[2] != 2 webserver.content_send("<option value=2>Shut down server</option>") end
        webserver.content_send("</td><td style='width:10%'></td></tr></table></select></fieldset>")
        webserver.content_send("<button name='settings_safe' type='submit' class='bgrn'>Safe</button>")
        webserver.content_send("</fieldset></form><fieldset>")
        webserver.content_send("<p><form id=vmgeneral action='vm' style='display: block;' method='get'><button>General Settings</button></form></p>")
        webserver.content_send("<p><form id=vmsensors action='vms' style='display: block;' method='get'><button>Sensor Configuration</button></form></p></fieldset>")
        webserver.content_button(webserver.BUTTON_MAIN)
        webserver.content_send("<script>"
            "document.addEventListener('DOMContentLoaded', function() {"
            "var settings_safed = document.getElementById('settings_safed');"
            "if (settings_safed) {" 
                "settings_safed.style.display = '';"
                "setTimeout(function() { settings_safed.style.display = 'none'; }, 5000);"
            "}});"
        "</script>");
        webserver.content_stop()
    end

    def vm_3p75ct_alarms_config_save()
        if !webserver.check_privileged_access() return nil end
        try
            if webserver.has_arg("settings_safe") && webserver.has_arg("frequency_min") && webserver.has_arg("frequency_max") && webserver.has_arg("voltage_min") && webserver.has_arg("voltage_max")
                global.configs.setitem("frequency_min", list(global.configs.item("frequency_min")[0], global.configs.item("frequency_min")[1], 
                    real(webserver.arg("frequency_min")), global.configs.item("frequency_min")[3], global.configs.item("frequency_min")[4], global.configs.item("frequency_min")[5]))
                global.configs.setitem("frequency_max", list(global.configs.item("frequency_max")[0], global.configs.item("frequency_max")[1],
                    real(webserver.arg("frequency_max")), global.configs.item("frequency_max")[3], global.configs.item("frequency_max")[4], global.configs.item("frequency_max")[5]))
                global.configs.setitem("voltage_min", list(global.configs.item("voltage_min")[0], global.configs.item("voltage_min")[1], 
                    real(webserver.arg("voltage_min")), global.configs.item("voltage_min")[3], global.configs.item("voltage_min")[4], global.configs.item("voltage_min")[5]))
                global.configs.setitem("voltage_max", list(global.configs.item("voltage_max")[0], global.configs.item("voltage_max")[1], 
                    real(webserver.arg("voltage_max")), global.configs.item("voltage_max")[3], global.configs.item("voltage_max")[4], global.configs.item("voltage_max")[5]))      
                global.configs.setitem("error_handling", list(global.configs.item("error_handling")[0], global.configs.item("error_handling")[1], 
                    int(webserver.arg("error_handling")), global.configs.item("error_handling")[3], global.configs.item("error_handling")[4], global.configs.item("error_handling")[5]))             
                global.settings_safed = 1
                self._register_values_update(false)
                self._write_config_to_persist(true)
                webserver.redirect("/vma") 
            else
                raise "value_error", "Unknown command"
            end
        except .. as e, m
            print(format("BRY: Exception> '%s' - %s", e, m))
            global.settings_safed = 2
            webserver.redirect("/vma")                  
        end
    end

    def vm_3p75ct_sensor_config_save()
        if !webserver.check_privileged_access() return nil end
        try
            var configvalues = list("frequency", "pen_voltage", "ac_power", "imported_energy", "exported_energy", "voltage_l1", "current_l1", "power_l1", "imported_energy_l1", "exported_energy_l1",
                "voltage_l2", "current_l2", "power_l2", "imported_energy_l2", "exported_energy_l2", "voltage_l3", "current_l3", "power_l3", "imported_energy_l3", "exported_energy_l3")
            for i: 0 .. size(configvalues) - 1
                if !webserver.has_arg(configvalues[i]) raise "value_error", "Unknown command" end
                if !webserver.has_arg(configvalues[i].."_calculated") raise "value_error", "Unknown command" end
                if !webserver.has_arg(configvalues[i].."_fixed_value") raise "value_error", "Unknown command" end
            end
            for i: 0 .. size(configvalues) - 1
                var value = ""
                var hassensor = false 
                var calculated = false
                if webserver.arg(configvalues[i]) == "fixed_value" value = real(webserver.arg(configvalues[i].."_fixed_value")) hassensor = false calculated = false else 
                    if webserver.arg(configvalues[i]) == "calculated" value = webserver.arg(configvalues[i].."_calculated") hassensor = true calculated = true else
                        value = webserver.arg(configvalues[i]) hassensor = true calculated = false
                    end 
                end 
                global.configs.setitem(configvalues[i], list(global.configs.item(configvalues[i])[0], hassensor, value, global.configs.item(configvalues[i])[3], calculated, global.configs.item(configvalues[i])[5]))
            end
            global.settings_safed = 1
            self._register_values_update(false)
            self._register_values_update(true)
            self._write_config_to_persist(true)
            webserver.redirect("/vms") 
        except .. as e, m
            print(format("BRY: Exception> '%s' - %s", e, m))
            global.settings_safed = 2
            webserver.redirect("/vms")                  
        end
    end

    def vm_3p75ct_sensor_config_reset()
        if !webserver.check_privileged_access() return nil end      
        global.configs.setitem("first_start", list(list(), false, false, "bool", false, 0)) # first start 
        global.configs.setitem("server_enable", list(list(), false, false, "bool", false, 0)) # server enable 
        global.configs.setitem("meter", list(list(), false, false, "string", false, 0)) # meter name 
        global.configs.setitem("phase_config", list(list(8192), false, 3, "uint", false, 0)) # phase config
        global.configs.setitem("role", list(list(8193), false, 0, "uint", false, 0)) # role
        global.configs.setitem("error_handling", list(list(), false, 0, "uint", false, 0)) # role
        global.configs.setitem("custom_name", list(list(8194,8195,8196,8197,8198,8199,8200,8201,8202,8203,8204,8205,8206,8207,8208,8209,8210,
        8211,8212,8213,8214,8215,8216,8217,8218,8219,8220,8221,8222,8223,8224,8225), false, "VM-3P75CT Emulator", "string", false, 0)) # custom_name
        global.configs.setitem("position", list(list(8226), false, 0, "uint", false, 0)) # inverter position
        global.configs.setitem("frequency", list(list(12338), false, 0, "uint", false, 1)) # frequency
        global.configs.setitem("pen_voltage", list(list(12339), false, 0, "sint", false, 1)) # pen voltage
        global.configs.setitem("frequency_min", list(list(), false, 45, "uint", false, 1)) # frequency min max
        global.configs.setitem("frequency_max", list(list(), false, 55, "uint", false, 1)) # frequency min max
        global.configs.setitem("voltage_min", list(list(), false, 220, "sint", false, 100)) # voltage min max
        global.configs.setitem("voltage_min", list(list(), false, 220, "sint", false, 100)) # voltage min max
        global.configs.setitem("imported_energy", list(list(12340,12341), false, 0, "uint", false, 100)) # imported energy 
        global.configs.setitem("exported_energy", list(list(12342,12343), false, 0, "uint", false, 100)) # exported energy  
        global.configs.setitem("ac_power", list(list(12416,12417), false, 0, "sint", false, 1)) # ac power
        global.configs.setitem("voltage_l1", list(list(12352), false, 0, "sint", false, 100)) # voltage l1 
        global.configs.setitem("current_l1", list(list(12353), false, 0, "sint", false, 100)) # current l1 
        global.configs.setitem("imported_energy_l1", list(list(12354,12355), false, 0, "uint", false, 100)) # imported energy l1 
        global.configs.setitem("exported_energy_l1", list(list(12356,12357), false, 0, "uint", false, 100)) # exported energy l1
        global.configs.setitem("power_l1", list(list(12418,12419), false, 0, "sint", false, 1)) # power l1 
        global.configs.setitem("voltage_l2", list(list(12360), false, 0, "sint", false, 100)) # voltage l2
        global.configs.setitem("current_l2", list(list(12361), false, 0, "sint", false, 100)) # current l2
        global.configs.setitem("imported_energy_l2", list(list(12362,12363), false, 0, "uint", false, 100)) # imported energy l2
        global.configs.setitem("exported_energy_l2", list(list(12364,12365), false, 0, "uint", false, 100)) # exported energy l2 
        global.configs.setitem("power_l2", list(list(12422,12423), false, 0, "sint", false, 1)) # power l2
        global.configs.setitem("voltage_l3", list(list(12368), false, 0, "sint", false, 100)) # voltage l3
        global.configs.setitem("current_l3", list(list(12369), false, 0, "sint", false, 100)) # current l3 
        global.configs.setitem("imported_energy_l3", list(list(12370,12371), false, 0, "uint", false, 100)) # imported energy l3 
        global.configs.setitem("exported_energy_l3", list(list(12372,12373), false, 0, "uint", false, 100)) # exported energy l3 
        global.configs.setitem("power_l3", list(list(12426,12427), false, 0, "sint", false, 1)) # power l3
        global.settings_safed = 1
        print("VM-3P75CT: Resetting Configuration")
        self._register_values_update(false)
        self._register_values_update(true)
        self._write_config_to_persist(true)
        webserver.redirect("/vm") 
    end

    def vm_3p75ct_server_enable()
        if !webserver.check_privileged_access() return nil end
        global.configs.setitem("server_enable", list(global.configs.item("server_enable")[0], global.configs.item("server_enable")[1], true, 
            global.configs.item("server_enable")[3], global.configs.item("server_enable")[4], global.configs.item("server_enable")[5])) 
        global.settings_safed = 1
        self._register_values_update(false)
        self._write_config_to_persist(true)
        print("VM-3P75CT: Enabling Server")
        webserver.redirect("/vm") 
    end

    def vm_3p75ct_server_disable()
        if !webserver.check_privileged_access() return nil end
        global.configs.setitem("server_enable", list(global.configs.item("server_enable")[0], global.configs.item("server_enable")[1], false, 
            global.configs.item("server_enable")[3], global.configs.item("server_enable")[4], global.configs.item("server_enable")[5])) 
        global.settings_safed = 1
        self._register_values_update(false)
        self._write_config_to_persist(true)
        print("VM-3P75CT: Disabling Server")
        webserver.redirect("/vm")            
    end

    def web_add_handler()
        webserver.on("/vm", / -> self.vm_3p75ct_config(), webserver.HTTP_GET)   # register handler config page
        webserver.on("/vm", / -> self.vm_3p75ct_config_save(), webserver.HTTP_POST)     # register handler safe config page
        webserver.on("/vma", / -> self.vm_3p75ct_alarms_config(), webserver.HTTP_GET)   # register handler config page
        webserver.on("/vma", / -> self.vm_3p75ct_alarms_config_save(), webserver.HTTP_POST)     # register handler safe config page
        webserver.on("/vms", / -> self.vm_3p75ct_sensor_config(), webserver.HTTP_GET)   # register handler config page
        webserver.on("/vms", / -> self.vm_3p75ct_sensor_config_save(), webserver.HTTP_POST)     # register handler safe config page
        webserver.on("/vmr", / -> self.vm_3p75ct_sensor_config_reset(), webserver.HTTP_POST)     # register handler safe config page
        webserver.on("/vme", / -> self.vm_3p75ct_server_enable(), webserver.HTTP_POST)     # register handler safe config page
        webserver.on("/vmd", / -> self.vm_3p75ct_server_disable(), webserver.HTTP_POST)     # register handler safe config page
    end

    def every_second()
        # called every 1s via normal way 
        if tasmota.eth()['up'] || tasmota.wifi()['up']
            if global.server_running == false && global.configs.item("server_enable")[2] && !global.server_sutdown
                if global.server.begin("", 502)
                    global.server_running = true
                    print("UDP server started on all interfaces on port 502")
                else
                    print("Error starting UDP server")
                end
            end
        else 
            if global.server_running == true
                global.server.close()
                global.server_running = false
                print("UDP server closed")
            end
        end
        if global.server_running == true && !global.configs.item("server_enable")[2]
            global.server.close()
            global.server_running = false
            print("UDP server closed")
        end
        if global.server_running == true && global.server_sutdown
            global.server.close()
            global.server_running = false
            print("UDP server closed")
        end
        # check if write registers are populated
        if global.registers.item(16384)[0] == bytes('010C')
            var customname = ""
            for i: 1 .. 32
            var currentstring = string.split(global.registers.item(16386 + i -1)[0].asstring(), 1)
                if currentstring[0] != bytes('00').asstring() customname = customname + currentstring[0] end
                if currentstring[1] != bytes('00').asstring() customname = customname + currentstring[1] end
                global.registers.setitem(16386 + i - 1, list(bytes('0000'), true))
            end
            global.registers.setitem(16384, list(bytes('0000'), true)) 
            global.registers.setitem(16385, list(bytes('0000'), true))
            global.configs.setitem("custom_name", list(global.configs.item("custom_name")[0], global.configs.item("custom_name")[1], customname, global.configs.item("custom_name")[3], 
                global.configs.item("custom_name")[4], global.configs.item("custom_name")[5]))
            self._register_values_update(false)
            self._write_config_to_persist(true)
        end
        global.connected = false
    end 

    def every_100ms()
        # check if configured meter is connected
        var sensors = json.load(tasmota.read_sensors())
        var meter = false
        var sensorkeys
        var error = true
        if sensors != nil meter = sensors.find(global.configs.item("meter")[2], false) end
        if !meter 
            global.errors[0] = true global.errors[2] = true 
        else 
            global.errors[0] = false 
            sensorkeys = meter.keys()
            if size(meter) > 0 
                for i: 1 .. size(meter)
                    if int(meter.item(sensorkeys())) != 0  error = false end
                end
            end
            global.errors[2] = error 
        end     
        # check if voltage is out of range (L1)
        error = false
        var value = bytes()
        for k : 1 .. size(global.configs.item("voltage_l1")[0]) value = value .. global.registers.item(global.configs.item("voltage_l1")[0][k-1])[0] end
        if global.configs.item("voltage_l1")[3] == "sint" value = value.geti(0, size(value)*-1) end
        if global.configs.item("voltage_l1")[3] == "uint" value = value.get(0, size(value)*-1) end
        if global.configs.item("phase_config")[2] == 0 || global.configs.item("phase_config")[2] == 3 
            if value < global.configs.item("voltage_min")[2]*global.configs.item("voltage_min")[5] || value > global.configs.item("voltage_max")[2]*global.configs.item("voltage_min")[5] 
                error = true end 
        end
        # check if voltage is out of range (L2)
        value = bytes()
        for k : 1 .. size(global.configs.item("voltage_l2")[0]) value = value .. global.registers.item(global.configs.item("voltage_l2")[0][k-1])[0] end
        if global.configs.item("voltage_l2")[3] == "sint" value = value.geti(0, size(value)*-1) end
        if global.configs.item("voltage_l2")[3] == "uint" value = value.get(0, size(value)*-1) end
        if global.configs.item("phase_config")[2] == 1 || global.configs.item("phase_config")[2] == 3 
            if value < global.configs.item("voltage_min")[2]*global.configs.item("voltage_min")[5] || value > global.configs.item("voltage_max")[2]*global.configs.item("voltage_min")[5] 
                error = true end end
        # check if voltage is out of range (L3)
        value = bytes()
        for k : 1 .. size(global.configs.item("voltage_l3")[0]) value = value .. global.registers.item(global.configs.item("voltage_l3")[0][k-1])[0] end
        if global.configs.item("voltage_l3")[3] == "sint" value = value.geti(0, size(value)*-1) end
        if global.configs.item("voltage_l3")[3] == "uint" value = value.get(0, size(value)*-1) end
        if global.configs.item("phase_config")[2] == 2 || global.configs.item("phase_config")[2] == 3 
            if value < global.configs.item("voltage_min")[2]*global.configs.item("voltage_min")[5] || value > global.configs.item("voltage_max")[2]*global.configs.item("voltage_min")[5] 
                error = true end end
        # write voltage errors
        if error global.errors[1] = true else global.errors[1] = false end
        # check if frequency is out of range
        value = bytes()
        for k : 1 .. size(global.configs.item("frequency")[0]) value = value .. global.registers.item(global.configs.item("frequency")[0][k-1])[0] end
        if global.configs.item("frequency")[3] == "sint" value = value.geti(0, size(value)*-1) end
        if global.configs.item("frequency")[3] == "uint" value = value.get(0, size(value)*-1) end 
        if value < global.configs.item("frequency_min")[2] || value > global.configs.item("frequency_max")[2] global.errors[4] = true else global.errors[4] = false end
        # write back in register
        value = bytes()
        if global.errors[5] value = bytes('00FF') if global.configs.item("error_handling")[2] == 2 global.server_sutdown = true end end
        if global.errors[4] value = bytes('0005') if global.configs.item("error_handling")[2] == 2 global.server_sutdown = true end end
        if global.errors[3] value = bytes('0004') if global.configs.item("error_handling")[2] == 2 global.server_sutdown = true end end
        if global.errors[2] value = bytes('0003') if global.configs.item("error_handling")[2] == 2 global.server_sutdown = true end end
        if global.errors[1] value = bytes('0002') if global.configs.item("error_handling")[2] == 2 global.server_sutdown = true end end
        if global.errors[0] value = bytes('0001') if global.configs.item("error_handling")[2] == 2 global.server_sutdown = true end end
        if !global.errors[5] && !global.errors[4] && !global.errors[3] && !global.errors[2] && !global.errors[1] && !global.errors[0] value = bytes('0000') global.server_sutdown = false end
        if global.configs.item("error_handling")[2] != 2 global.server_sutdown = false end

        global.registers.setitem(12344, list(value, false))
    end
  
    def fast_loop()
        # called at each iteration, and needs to be registered separately and explicitly
        if global.server_running
            self._register_values_update(true)
            var request = global.server.read() # server read to variable
            if request != nil   # check if something was sent
                #print(request)  # debug
                #print(request[7]) # debug
                if request[7] == 3  # check for function code 3
                    var data = self._read_registers(request.get(8, -2), request.get(10, -2)) # read start and lenght
                    if data == false  # check if error occured
                        global.server.send(global.server.remote_ip, global.server.remote_port, self._parse_error(request, bytes('02'))) # send error
                    else
                        global.server.send(global.server.remote_ip, global.server.remote_port, self._parse_reply_3_23(request, data))    # send requested data
                        global.connected = true
                    end
                end
                if request[7] == 23  # check for function code 23
                    if self._write_registers(request.get(12, -2), request.get(14, -2), request[17 .. 16 + request[16]]) # write registers and start, lenght from data (17ff)
                        var data = self._read_registers(request.get(8, -2), request.get(10, -2)) # read start and lenght
                        if data == false  # check if error occured
                            global.server.send(global.server.remote_ip, global.server.remote_port, self._parse_error(request, bytes('02'))) # send error
                        else
                            global.server.send(global.server.remote_ip, global.server.remote_port, self._parse_reply_3_23(request, data))    # send requested data
                            global.connected = true
                        end
                    else 
                        global.server.send(global.server.remote_ip, global.server.remote_port, self._parse_error(request, bytes('02'))) # send error
                    end
                end
                if request[7] == 01 || request[7] == 02 || request[7] == 04 || request[7] == 05 || 
                    request[7] == 06 || request[7] == 07 || request[7] == 08 || request[7] == 12 || 
                    request[7] == 15 || request[7] == 16 || request[7] == 17 || request[7] == 20 || 
                    request[7] == 21 || request[7] == 22 || request[7] == 24 || request[7] == 43 
                    return self._parse_error(request, bytes('01'))
                end
            end
        end      
    end

    # check if registers exist (start, lenght)
    def _check_registers(start, lenght)
        var registers_exist = true  # set to true 
        for i: 1 .. lenght    # iterate trough the count of registers for this request
            if !global.registers.contains(start + i -1)     # check if the register (start + current iteration - 1)
                registers_exist = false     # mark false if a register does not exist
            end
        end
        return registers_exist # return true if register exists, false if dosn't
    end

    # read registers and return bytes(data)
    def _read_registers(start, lenght)
        if self._check_registers(start, lenght) # check if registers exist
            var data = bytes()
            for i: 1 .. lenght    # iterate trough the count of registers for this request
                data = data .. global.registers.item(start + i - 1)[0] # get data from registers
            end
            return data  # return data if reisters exist
        else
            return false  # return false if registers don't exist
        end
    end

    # write registers (return true)
    def _write_registers(start, lenght, data)
        if size(data) != lenght*2
            return false    # return false if lenght of data dosen't match the actual lenght
        end
        if self._check_registers(start, lenght) # check if registers exist
            var registers_writeable = true
            for i: 1 .. lenght    # iterate trough the count of registers for this request
                if !global.registers.item(start + i - 1)[1]     # check if the register (start + current iteration - 1)
                    registers_writeable = false     # mark false if a register does not exist
                end
            end
            if !registers_writeable     # check if all registers are writeable
                return false    # return false if registers are not writeable
            else
                for i: 1 .. lenght    # iterate trough the count of registers for this request
                    global.registers.setitem(start + i - 1, list(data[i*2 - 2 .. i*2 - 1], 0, true))
                end
                return true
            end
        else
            return false  # return false if registers don't exist
        end
    end

    def _parse_error(request, errorcode)
        import string 
        var reply = bytes()
        var fcode = bytes()
        if !isinstance(request, bytes()) || !isinstance(errorcode, bytes()) return end # check if bytes are given
        if size(errorcode) != 1 return end  # check if bytes are correct size, return nil if true
        reply = request[0..3] .. bytes('0003') .. request[6..6] # write Transaction identifier, protocol identifier, message lenght (error)
        fcode.fromhex(string.hex(request[7] + 80))  # calculate new function code
        reply = reply .. fcode .. errorcode   # add function code and error code
        # return error reply 
        return reply
    end

    def _parse_reply_3_23(request, data)
        import string
        var reply = request[0..3]
        var lenght = bytes()
        var lenghthex = string.hex(data.size() + 3)     # calculate lenght
        while size(lenghthex) != 4      # bring hexstring to correct lenght
            lenghthex = "0" + lenghthex     # bring hexstring to correct lenght
        end
        lenght.fromhex(lenghthex)   # convert string to lenght
        reply = reply .. lenght .. request[6..7]    # write lenght and function code
        lenghthex = string.hex(data.size())     # calculate byte count
        while size(lenghthex) != 2      # bring hexstring to correct lenght
            lenghthex = "0" + lenghthex     # bring hexstring to correct lenght
        end
        lenght.fromhex(lenghthex)   # convert string to lenght
        reply = reply .. lenght .. data     # write bytecount and data
        return reply        # return reply
    end 

    def _register_values_update(fast)
        var keys = global.configs.keys()
        for i : 1 .. global.configs.size()
            var current_key = keys()
            var lenght = size(global.configs.item(current_key)[0]) 
            if !global.configs.item(current_key)[1] && lenght > 0 && !fast && !global.configs.item(current_key)[4]
                for j : 1 .. lenght
                    var register = global.configs.item(current_key)[0][j-1]
                    var value = bytes()
                    var currentvalue
                    if global.configs.item(current_key)[5] == 0 currentvalue = global.configs.item(current_key)[2] 
                    else currentvalue = int(global.configs.item(current_key)[2] * global.configs.item(current_key)[5])
                    end
                    if global.configs.item(current_key)[3] == "string"
                        value.fromstring(currentvalue)
                        while size(value) < lenght*2
                            value = value + bytes('00') # bring string to correct lenght
                        end
                    end
                    if global.configs.item(current_key)[3] == "sint"
                        value.resize(lenght*2)
                        value.seti(0, currentvalue, lenght*-2)
                    end 
                    if global.configs.item(current_key)[3] == "uint"
                        value.resize(lenght*2)
                        value.set(0, currentvalue, lenght*-2) 
                    end 
                    global.registers.setitem(register, list(value[j*2-2  .. j*2-1], false))
                end
            end
            if global.configs.item(current_key)[1] && lenght > 0 && fast && !global.configs.item(current_key)[4]
                var currentvalue
                var sensors = json.load(tasmota.read_sensors())
                var meter = sensors.find(global.configs.item("meter")[2], 0)
                var sensor = meter.find(global.configs.item(current_key)[2], 0)
                if global.configs.item(current_key)[5] == 0 currentvalue = sensor 
                else currentvalue = int(sensor * global.configs.item(current_key)[5])
                end
                for j : 1 .. lenght
                    var register = global.configs.item(current_key)[0][j-1]
                    var value = bytes()
                    value.resize(lenght*2)
                    if global.configs.item(current_key)[3] == "sint"
                        value.seti(0, currentvalue, lenght*-2)
                    end
                    if global.configs.item(current_key)[3] == "uint"
                        value.set(0, currentvalue, lenght*-2)
                    end
                    global.registers.setitem(register, list(value[j*2-2  .. j*2-1], false))
                end
            end
            if global.configs.item(current_key)[1] && lenght > 0 && fast && global.configs.item(current_key)[4]
                var actions = list()
                if current_key == "voltage_l1" && global.configs.item(current_key)[2] == "Power / Current" actions = list("devide", "power_l1", "current_l1") end
                if current_key == "current_l1" && global.configs.item(current_key)[2] == "Power / Voltage" actions = list("devide", "power_l1", "voltage_l1") end
                if current_key == "imported_energy_l1" && global.configs.item(current_key)[2] == "Total Imported / 3" actions = list("devidebythree", "imported_energy") end
                if current_key == "imported_energy_l1" && global.configs.item(current_key)[2] == "Total Imported" actions = list("all", "imported_energy") end
                if current_key == "exported_energy_l1" && global.configs.item(current_key)[2] == "Total Exported / 3" actions = list("devidebythree", "exported_energy") end
                if current_key == "exported_energy_l1" && global.configs.item(current_key)[2] == "Total Exported" actions = list("all", "exported_energy") end
                if current_key == "power_l1" && global.configs.item(current_key)[2] == "Voltage x Current" actions = list("multiply", "voltage_l1", "current_l1") end
                if current_key == "power_l1" && global.configs.item(current_key)[2] == "Total Power / 3" actions = list("devidebythree", "ac_power") end
                if current_key == "power_l1" && global.configs.item(current_key)[2] == "Total Power" actions = list("all", "ac_power") end
                if current_key == "voltage_l2" && global.configs.item(current_key)[2] == "Power / Current" actions = list("devide", "power_l2", "current_l2") end
                if current_key == "current_l2" && global.configs.item(current_key)[2] == "Power / Voltage" actions = list("devide", "power_l2", "voltage_l2") end
                if current_key == "imported_energy_l2" && global.configs.item(current_key)[2] == "Total Imported / 3" actions = list("devidebythree", "imported_energy") end
                if current_key == "imported_energy_l2" && global.configs.item(current_key)[2] == "Total Imported" actions = list("all", "imported_energy") end
                if current_key == "exported_energy_l2" && global.configs.item(current_key)[2] == "Total Exported / 3" actions = list("devidebythree", "exported_energy") end
                if current_key == "exported_energy_l2" && global.configs.item(current_key)[2] == "Total Exported" actions = list("all", "exported_energy") end
                if current_key == "power_l2" && global.configs.item(current_key)[2] == "Voltage x Current" actions = list("multiply", "voltage_l2", "current_l2") end
                if current_key == "power_l2" && global.configs.item(current_key)[2] == "Total Power / 3" actions = list("devidebythree", "ac_power") end
                if current_key == "power_l2" && global.configs.item(current_key)[2] == "Total Power" actions = list("all", "ac_power") end
                if current_key == "voltage_l3" && global.configs.item(current_key)[2] == "Power / Current" actions = list("devide", "power_l3", "current_l3") end
                if current_key == "current_l3" && global.configs.item(current_key)[2] == "Power / Voltage" actions = list("devide", "power_l3", "voltage_l3") end
                if current_key == "imported_energy_l3" && global.configs.item(current_key)[2] == "Total Imported / 3" actions = list("devidebythree", "imported_energy") end
                if current_key == "imported_energy_l3" && global.configs.item(current_key)[2] == "Total Imported" actions = list("all", "imported_energy") end
                if current_key == "exported_energy_l3" && global.configs.item(current_key)[2] == "Total Exported / 3" actions = list("devidebythree", "exported_energy") end
                if current_key == "exported_energy_l3" && global.configs.item(current_key)[2] == "Total Exported" actions = list("all", "exported_energy") end
                if current_key == "power_l3" && global.configs.item(current_key)[2] == "Voltage x Current" actions = list("multiply", "voltage_l3", "current_l3") end
                if current_key == "power_l3" && global.configs.item(current_key)[2] == "Total Power / 3" actions = list("devidebythree", "ac_power") end
                if current_key == "power_l3" && global.configs.item(current_key)[2] == "Total Power" actions = list("all", "ac_power") end
                for j : 1 .. size(actions) - 1
                    var value = bytes()
                    for k : 1 .. size(global.configs.item(actions[j])[0]) value = value .. global.registers.item(global.configs.item(actions[j])[0][k-1])[0] end
                    if global.configs.item(actions[j])[3] == "sint" value = value.geti(0, size(value)*-1) end
                    if global.configs.item(actions[j])[3] == "uint" value = value.get(0, size(value)*-1) end
                    if global.configs.item(actions[j])[5] != 0  value = value / global.configs.item(actions[j])[5] end
                    actions[j] = value
                end
                var sensor 
                if actions[0] == "devide" if actions[2] != 0 sensor = actions[1]/actions[2] else sensor = 0 end end
                if actions[0] == "devidebythree" sensor = actions[1]/3 end
                if actions[0] == "all" sensor = actions[1] end
                if actions[0] == "multiply" sensor = actions[1]*actions[2] end
                if global.configs.item(current_key)[5] == 0 sensor = sensor 
                else sensor = sensor * global.configs.item(current_key)[5]
                end
                for j : 1 .. lenght
                    var register = global.configs.item(current_key)[0][j-1]
                    var value = bytes()
                    value.resize(lenght*2)
                    if global.configs.item(current_key)[3] == "sint"
                        value.seti(0, sensor, lenght*-2)
                    end
                    if global.configs.item(current_key)[3] == "uint"
                        value.set(0, sensor, lenght*-2)
                    end
                    global.registers.setitem(register, list(value[j*2-2  .. j*2-1], false))
                end
            end
        end
    end

    def _write_config_to_persist(force)
        persist.zero()
        persist.setmember("first_start", global.configs.item("first_start")[2])
        persist.setmember("server_enable", global.configs.item("server_enable")[2])
        persist.setmember("meter", global.configs.item("meter")[2])
        persist.setmember("phase_config", global.configs.item("phase_config")[2])
        persist.setmember("role", global.configs.item("role")[2])
        persist.setmember("error_handling", global.configs.item("error_handling")[2])
        persist.setmember("custom_name", global.configs.item("custom_name")[2])
        persist.setmember("position", global.configs.item("position")[2])
        persist.setmember("frequency_sensor", global.configs.item("frequency")[1])
        persist.setmember("frequency", global.configs.item("frequency")[2])
        persist.setmember("pen_voltage_sensor", global.configs.item("pen_voltage")[1])
        persist.setmember("pen_voltage", global.configs.item("pen_voltage")[2])
        persist.setmember("imported_energy_sensor", global.configs.item("imported_energy")[1])
        persist.setmember("imported_energy", global.configs.item("imported_energy")[2])
        persist.setmember("exported_energy_sensor", global.configs.item("exported_energy")[1])
        persist.setmember("exported_energy", global.configs.item("exported_energy")[2])
        persist.setmember("ac_power", global.configs.item("ac_power")[2])
        persist.setmember("ac_power_sensor", global.configs.item("ac_power")[1])
        persist.setmember("frequency_min", global.configs.item("frequency_min")[2])
        persist.setmember("frequency_max", global.configs.item("frequency_max")[2])
        persist.setmember("voltage_min", global.configs.item("voltage_min")[2])
        persist.setmember("voltage_max", global.configs.item("voltage_max")[2])
        persist.setmember("voltage_l1_calculated", global.configs.item("voltage_l1")[4])
        persist.setmember("voltage_l1_sensor", global.configs.item("voltage_l1")[1])
        persist.setmember("voltage_l1", global.configs.item("voltage_l1")[2])
        persist.setmember("current_l1_calculated", global.configs.item("current_l1")[4])
        persist.setmember("current_l1_sensor", global.configs.item("current_l1")[1])
        persist.setmember("current_l1", global.configs.item("current_l1")[2])
        persist.setmember("imported_energy_l1_calculated", global.configs.item("imported_energy_l1")[4])
        persist.setmember("imported_energy_l1_sensor", global.configs.item("imported_energy_l1")[1])
        persist.setmember("imported_energy_l1", global.configs.item("imported_energy_l1")[2])
        persist.setmember("exported_energy_l1_calculated", global.configs.item("exported_energy_l1")[4])
        persist.setmember("exported_energy_l1_sensor", global.configs.item("exported_energy_l1")[1])
        persist.setmember("exported_energy_l1", global.configs.item("exported_energy_l1")[2])
        persist.setmember("power_l1_calculated", global.configs.item("power_l1")[4])
        persist.setmember("power_l1_sensor", global.configs.item("power_l1")[1])
        persist.setmember("power_l1", global.configs.item("power_l1")[2])
        persist.setmember("voltage_l2_calculated", global.configs.item("voltage_l2")[4])
        persist.setmember("voltage_l2_sensor", global.configs.item("voltage_l2")[1])
        persist.setmember("voltage_l2", global.configs.item("voltage_l2")[2])
        persist.setmember("current_l2_calculated", global.configs.item("current_l2")[4])
        persist.setmember("current_l2_sensor", global.configs.item("current_l2")[1])
        persist.setmember("current_l2", global.configs.item("current_l2")[2])
        persist.setmember("imported_energy_l2_calculated", global.configs.item("imported_energy_l2")[4])
        persist.setmember("imported_energy_l2_sensor", global.configs.item("imported_energy_l2")[1])
        persist.setmember("imported_energy_l2", global.configs.item("imported_energy_l2")[2])
        persist.setmember("exported_energy_l2_calculated", global.configs.item("exported_energy_l2")[4])
        persist.setmember("exported_energy_l2_sensor", global.configs.item("exported_energy_l2")[1])
        persist.setmember("exported_energy_l2", global.configs.item("exported_energy_l2")[2])
        persist.setmember("power_l2_calculated", global.configs.item("power_l2")[4])
        persist.setmember("power_l2_sensor", global.configs.item("power_l2")[1])
        persist.setmember("power_l2", global.configs.item("power_l2")[2])
        persist.setmember("voltage_l3_calculated", global.configs.item("voltage_l3")[4])
        persist.setmember("voltage_l3_sensor", global.configs.item("voltage_l3")[1])
        persist.setmember("voltage_l3", global.configs.item("voltage_l3")[2])
        persist.setmember("current_l3_calculated", global.configs.item("current_l3")[4])
        persist.setmember("current_l3_sensor", global.configs.item("current_l3")[1])
        persist.setmember("current_l3", global.configs.item("current_l3")[2])
        persist.setmember("imported_energy_l3_calculated", global.configs.item("imported_energy_l3")[4])
        persist.setmember("imported_energy_l3_sensor", global.configs.item("imported_energy_l3")[1])
        persist.setmember("imported_energy_l3", global.configs.item("imported_energy_l3")[2])
        persist.setmember("exported_energy_l3_calculated", global.configs.item("exported_energy_l3")[4])
        persist.setmember("exported_energy_l3_sensor", global.configs.item("exported_energy_l3")[1])
        persist.setmember("exported_energy_l3", global.configs.item("exported_energy_l3")[2])
        persist.setmember("power_l3_calculated", global.configs.item("power_l3")[4])
        persist.setmember("power_l3_sensor", global.configs.item("power_l3")[1])
        persist.setmember("power_l3", global.configs.item("power_l3")[2])
        if tasmota.cmd("DeviceName", true)["DeviceName"] != global.configs.item("custom_name")[2]
            tasmota.cmd("DeviceName " + global.configs.item("custom_name")[2], true)
            print("New DeviceName: " + global.configs.item("custom_name")[2])
        end  
        print("VM-3P75CT: Saving Configuration")
        persist.save(force)
    end
end

tasmota.add_driver(VM_3P75CT_emulater())                     # register driver