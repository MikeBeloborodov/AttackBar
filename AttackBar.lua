function Print(msg, r, g, b)
	DEFAULT_CHAT_FRAME:AddMessage(msg, r, g, b)
end

function PrintRed(msg)
	Print(msg, 1.0, 0.2, 0.2)
end

function PrintWhite(msg)
	Print(msg, 1.0, 1.0, 1.0)
end


--[[
	------------------------
	------ENEMY BAR --------
	------------------------
]]--

function EnemyAttackBar_OnLoad()
	this:RegisterForDrag("LeftButton")
	this:RegisterEvent("PLAYER_TARGET_CHANGED")
	this:RegisterEvent("PLAYER_REGEN_DISABLED")
	this:RegisterEvent("PLAYER_REGEN_ENABLED")
	this:RegisterEvent("COMBAT_TEXT_UPDATE")

	this.damageEvents = {"DAMAGE", "DAMAGE_CRIT", "MISS", "DODGE", "PARRY", "BLOCK"}

	this.maxValue = GetTime()
end

function EnemyAttackBar_OnEvent()
	if event == "PLAYER_TARGET_CHANGED" then
		if UnitExists("target") then
			local mainSpeed, offSpeed = UnitAttackSpeed("target")
			this.targetSpeed = tonumber(string.format('%.02f', mainSpeed))
			EnemyAttackBarSpeed:SetText(this.targetSpeed .. "s")
			this:SetMinMaxValues(0, 1);
			this:SetValue(1);
		end
	end

	if event == "PLAYER_REGEN_DISABLED" then
		this:Show()
	end

	if event == "PLAYER_REGEN_ENABLED"  then
		this:Hide()
	end

	if event == "COMBAT_TEXT_UPDATE" then
		for _, v in pairs(this.damageEvents) do
			if(arg1 == v) then
				local time = GetTime()
				this.startTime = time
				this.maxValue = this.startTime + this.targetSpeed
				this:SetMinMaxValues(this.startTime, this.maxValue);
				this:SetValue(this.startTime);
			end
		end
	end
end

function EnemyAttackBar_OnUpdate()
	local time = GetTime()

	if time < this.maxValue then
		this:SetValue(time)
	end
end

--[[
	------------------------
	------PLAYER BAR --------
	------------------------
]]--

function PlayerAttackBar_OnLoad()
	this:RegisterForDrag("LeftButton")
	this:RegisterEvent("PLAYER_REGEN_DISABLED")
	this:RegisterEvent("PLAYER_REGEN_ENABLED")
	this:RegisterEvent("UNIT_COMBAT")
	this:RegisterEvent("UNIT_MANA")

	local mainSpeed, offSpeed = UnitAttackSpeed("player")
	this.playerSpeed = tonumber(string.format('%.02f', mainSpeed))
	PlayerAttackBarSpeed:SetText(this.playerSpeed .. "s")

	this.currMana = UnitMana("player")

	this.maxValue = GetTime()
end

function PlayerAttackBar_OnEvent()
	if event == "PLAYER_REGEN_DISABLED" then
		local mainSpeed, offSpeed = UnitAttackSpeed("player")
		this.playerSpeed = tonumber(string.format('%.02f', mainSpeed))
		PlayerAttackBarSpeed:SetText(this.playerSpeed .. "s")

		this.inCombat = true
		this.currMana = UnitMana("player")

		this:Show()
	end

	if event == "PLAYER_REGEN_ENABLED" then
		this:SetMinMaxValues(0, 1);
		this:SetValue(1);

		this.inCombat = false

		this:Hide()
	end

	if event == "UNIT_COMBAT" and this.inCombat then
		if arg1 == "target" then
			if arg5 == 0 then
				local time = GetTime()
				this.startTime = time
				this.maxValue = this.startTime + this.playerSpeed
				this:SetMinMaxValues(this.startTime, this.maxValue);
				this:SetValue(this.startTime);
			end
		end

		if arg1 =="player" then
			if arg2 == "PARRY" then
				local currentCD = tonumber(this:GetValue())
				local CDReduction = this.playerSpeed * 0.4
				local maxReduction = this.playerSpeed * 0.2

				if currentCD - CDReduction > maxReduction then
					currentCD = currentCD - CDReduction
				else
					currentCD = maxReduction
				end

				this:SetValue(currentCD);
			end
		end
	end

	if event == "UNIT_MANA" then
		local mana = UnitMana("player")
		if mana < this.currMana then
			local time = GetTime()
			this.startTime = time
			this.maxValue = this.startTime + this.playerSpeed
			this:SetMinMaxValues(this.startTime, this.maxValue);
			this:SetValue(this.startTime);
		end

		this.currMana = mana
	end
end

function PlayerAttackBar_OnUpdate()
	local time = GetTime()

	if time < this.maxValue then
		this:SetValue(time)
	end

end