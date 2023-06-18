_G.state = 1
local function start_service()
local address = "esp32c3.tbz.io"
httpsrv.start(80, function(client, method, uri, headers, body)
	-- method 是字符串, 例如 GET POST PUT DELETE
	-- uri 也是字符串 例如 / /api/abc
	-- headers table类型
	-- body 字符串
	log.info("httpsrv", method, uri, json.encode(headers), body)
	if uri == "/led/1" then
		pwm.open(pin_blk,1000,999,0,1000)
		state = 1
		return 200, {}, "ok"
	elseif uri == "/led/0" then
		pwm.open(pin_blk,1000,0,0,1000)
		state = 0
		return 200, {}, "ok"
	elseif uri == "/led/toggle" then
		if state == 0 then
			pwm.open(pin_blk,1000,999,0,1000)
			state = 1
		else
			pwm.open(pin_blk,1000,0,0,1000)
			state = 0
		end
		return 200, {}, "ok"
	elseif uri == "/time" then
		return 200, {}, tostring(os.date())
	elseif uri == "/state" then
		return 200, {}, json.encode({
			state = state
		})
	end
	-- 返回值的约定 code, headers, body
	-- 若没有返回值, 则默认 404, {} ,""
	return 404, {}, "Not Found " .. uri
end)
end
-- 关于静态文件
-- 情况1: / , 映射为 /index.html
-- 情况2: /abc.html , 先查找 /abc.html, 不存在的话查找 /abc.html.gz
-- 若gz存在, 会自动以压缩文件进行响应, 绝大部分浏览器支持.
-- 当前默认查找 /luadb/xxx 下的文件,暂不可配置


return {
	start = start_service
}