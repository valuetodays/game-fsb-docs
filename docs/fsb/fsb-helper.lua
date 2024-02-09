
--[[
可能用到的代码段
  转十六进制
  string.format("%x", 1000)
--]]

-- -------------------------------------
-- -------------------------------------



--[[
getByteFromRAM
--]]
local function getByteFromRAM(addr)
	return memory.readbyte(addr)
end



--[[
读取敌人血量
--]]
local function readHp(addr)
	local currentHpAddr = addr;
	local maxHpAddr = addr + (0xF0-0x80);
	local currentHp = memory.readword(currentHpAddr, currentHpAddr + 1)
	local maxHp = memory.readword(maxHpAddr, maxHpAddr + 1)
	return currentHp,maxHp
end


--[[
是否战斗中
return: 81-在，00-不在
--]]
local function isInBattle()
	return getByteFromRAM(0x46)
end


--[[
获取地图id
--]]
local function getMapId()
	return getByteFromRAM(0x47)
end


--[[
获取玩家位置x
--]]
local function getPlayerPosX()
	return getByteFromRAM(0x7A)
end


--[[
获取玩家位置y
--]]
local function getPlayerPosY()
	return getByteFromRAM(0x7B)
end


--[[
获取界面类型：
00-切换地图中，当进入战斗画面时是显示敌人名称的界面
01-敌我战斗中（会有攻击动画）
02/03-战后结算界面
05-地图中
--]]
local function getUiType()
	return getByteFromRAM(0x2F)
end


local baseAddr = 0x6980;
while (true) do
	local ui = getUiType()
	local battleFlag = isInBattle();
	if ( battleFlag == 0x81 ) then
		if (ui == 0x00 or ui == 0x01) then 
			-- 战斗中就显示怪物血量
			for i=0x0,0xf,2 do
				local currentHp, maxHp = readHp(baseAddr + i);
				gui.text(10, 50 + i * 5, ""..tostring(currentHp).."/"..tostring(maxHp));
			end
		end
	elseif ( battleFlag == 0x00 ) then
		if (ui == 0x00) then 
			gui.text(10, 10 + 0 * 5, "loading new map");
		elseif (ui == 0x05) then
			local mapId = getMapId()
			local posx = getPlayerPosX();
			local posy = getPlayerPosY();
			local str = "mapId:" .. mapId .. "(" .. posx .. "," .. posy .. ")"
			gui.text(10, 10 + 0 * 5, str);
		end
    else 
		gui.text(10, 10 + 0 * 5, "ERROR VALUE:"..battleFlag);
    end
	
    emu.frameadvance();
end;

