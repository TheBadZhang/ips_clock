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
-- pin_cs = 10
pin_rst = 10
pin_dc = 6
pin_blk = 7
-- gpio.setup(2, 0)
-- gpio.setup(3, 0)
spi_lcd = spi.deviceSetup(spi_id, nil,0,0,8,40*1000*1000,spi.MSB,1,0)


-- 对应屏幕的片选引脚和显示的字符串第几位数字
time2screen = {
	{8,1},
	{4,2},
	{5,4},
	{9,5},
	{0,7},
	{1,8}
}
-- 初始化片选引脚，并设置初始电平为低电平（初始化用）
pin_cs = {}
for k,v in ipairs(time2screen) do
	pin_cs[k] = gpio.setup(v[1], 0)
end


-- 背光控制引脚
gpio.setup(pin_blk, 0)
gpio.set(pin_blk, 0)

gpio.setup(pin_rst, 0)
gpio.setup(pin_dc, 0)
-- gpio.setup()

-- spi.setup(spi_id, nil, 0, 0, 8, 2000000, spi.MSB, 1, 0)
log.info("lcd init", lcd.init("st7735s",
	{
		port = "device",pin_dc = pin_dc, pin_rst = pin_rst,
		direction = 3,w = 160,h = 80,xoffset = 0,yoffset = 24
	},
	spi_lcd))
lcd.invoff()
lcd.setColor(0x0000,0xffff)
lcd.clear(0x0000)
lcd.setFont(lcd.font_unifont_t_symbols)

uart.setup(0, 115200, 8, 1, uart.NONE)
-- 打印根分区的信息
log.info("fsstat", fs.fsstat("/"))
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


		my_http_srv.start()

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
			timer.mdelay(100)
		end
	end
)



sys.run()

