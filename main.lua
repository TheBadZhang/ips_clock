PROJECT = "uartdemo"
VERSION = "1.0.0"

-- sys库是标配
_G.sys = require("sys")

_G.my_http_srv = require("http_srv")

if wdt then
	wdt.init(9000)
	sys.timerLoopStart(wdt.feed, 3000)
end

spi_id = 2
pin_cs = 10
pin_rst = 4
pin_dc = 8
pin_blk = 5

spi_lcd = spi.deviceSetup(spi_id, nil,0,0,8,40*1000*1000,spi.MSB,1,0)


-- 初始化片选引脚，并设置初始电平为低电平（初始化用）
pin_cs1 = gpio.setup(10,0)
pin_cs2 = gpio.setup(6,0)
pic_cs3 = gpio.setup(7,0)
pin_cs4 = gpio.setup(9,0)
-- 背光控制引脚
gpio.setup(pin_blk, 0)
gpio.set(pin_blk, 0)

lcd.init("st7735s",{port = "device",pin_dc = pin_dc, pin_pwr = nil, pin_rst = pin_rst, direction = 3,w = 160,h = 80,xoffset = 1,yoffset = 26},spi_lcd)

lcd.setColor(0x0000,0xffff)
lcd.clear(0x0000)
lcd.setFont(lcd.font_unifont_t_symbols)


uart.setup(0, 115200, 8, 1, uart.NONE)

sys.taskInit(
	function()


		wlan.init()
		-- 背光控制
		pwm.open(pin_blk,1000,999,0,1000)
		lcd.drawStr(10,12,"wifi init...")
		-- 修改成自己的ssid和password
		wlan.connect("laptop", "a12345678")
		lcd.drawStr(10,24,"wifi connect...")
		log.info("wlan", "wait for IP_READY")

		while not wlan.ready() do
			local ret, ip = sys.waitUntil("IP_READY", 30000)
			-- wlan连上之后, 这里会打印ip地址
			log.info("ip", ret, ip)
			if ip then
				_G.wlan_ip = ip
				lcd.drawStr(10, 36, "wifi connected!")
				lcd.drawStr(10, 48, wlan_ip)
			end
		end
		lcd.drawStr(10, 60, "start...")
		sys.wait(1000)



		-- local data = [[{"board_name":"LENOVO LNVNB161216","cpu_cores":20,"cpu_freq":2300.0,"cpu_name":"12th Gen Intel(R) Core(TM) i7-12700H","cpu_percent":" 2.7","net_down_rate":6.0859375,"net_up_rate":52.955078125,"ram_percent":65.1,"ram_total":31.73192596435547,"ram_used":20.647735595703125,"rom_percent":37.189698607909136,"rom_total":2.719144180417061,"rom_used":1.0112415254116058}]]
		-- t = json.decode(data)
		-- log.info("got information")
		-- gpio.set(9,0)
		-- if type(t) == "table" then
		-- 	lcd.setColor(0xffff,0x0000)
		-- 	lcd.flush()
		-- 	-- lcd.fill(0, 0, 160, 80, 0xffff)
		-- 	lcd.showImage(0,0,"/luadb/bg.jpg")
		-- 	lcd.drawStr(1,10,string.format("%s", t.board_name))
		-- 	lcd.drawStr(0,10*2,string.format("%s", t.cpu_name))
		-- 	lcd.drawStr(1,10*3,string.format("CPU:%s%%", t.cpu_percent))
		-- 	lcd.drawStr(1,10*4,string.format("RAM:%4.1f--%3.1fGB/%3.1fGB", t.ram_percent, t.ram_used, t.ram_total))
		-- 	lcd.drawStr(1,10*5,string.format("ROM:%4.1f--%3.1fTB/%3.1fTB", t.rom_percent, t.rom_used, t.rom_total))
		-- 	lcd.drawStr(1,10*6,string.format("NET:up:%5.1fKiB,down:%5.1fKiB",t.net_up_rate, t.net_down_rate))
		-- 	lcd.setColor(0x0000,0xffff)
		-- end
		-- gpio.set(9,1)

		my_http_srv.start()
		-- 对应屏幕的片选引脚和显示的字符串第几位数字
		time2screen = {
			{10,1},
			{6,2},
			{7,4},
			{9,5}
		}

		while true do
			-- lcd.clear()
			-- 获取当前时间
			tt = tostring(os.date("%H:%M:%S", os.time()))
			-- 串口打印当前时间
			log.info("time", tt)
			if lcd.showImage then
				-- 依次显示对应的时间
				for _,t in ipairs(time2screen) do
					gpio.set(t[1],0)
					lcd.showImage(0, 0, "/luadb/"..string.sub(tt, t[2], t[2])..".jpg")
					gpio.set(t[1],1)
				end
			end
			-- 延时半秒钟（可以略微提高显示的精度）
			sys.wait(500)
		end
	end
)



sys.run()

