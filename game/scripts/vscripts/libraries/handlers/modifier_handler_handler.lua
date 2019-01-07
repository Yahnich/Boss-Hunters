modifier_handler_handler = class({})
	
INTERNAL_ATTACK_SPEED_CAP = 900
INTERNAL_MOVESPEED_CAP = 550

function modifier_handler_handler:OnCreated()
	if IsServer() then
		local parent = self:GetParent()
		if not parent:HasModifier("modifier_bloodseeker_thirst") then
			parent:AddNewModifier(self:GetParent(), nil, "modifier_bloodseeker_thirst", {})
		end
		self.acc = parent:AddNewModifier(self:GetParent(), nil, "modifier_accuracy_handler", {})
		self.as = parent:AddNewModifier(self:GetParent(), nil, "modifier_attack_speed_handler", {})
		self.bat = parent:AddNewModifier(self:GetParent(), nil, "modifier_base_attack_time_handler", {})
		self.cdr = parent:AddNewModifier(self:GetParent(), nil, "modifier_cooldown_reduction_handler", {})
		self.hp = parent:AddNewModifier(self:GetParent(), nil, "modifier_health_handler", {})
		self.ms = parent:AddNewModifier(self:GetParent(), nil, "modifier_move_speed_handler", {})
		-- base attack time init
		self.baseAttackTime = self:GetParent():GetBaseAttackTime() * 100
		if parent:IsRealHero() then
			self.baseAttackTime = self.baseAttackTime * 1.5
		end
		self.baseAttackTime =  math.floor( self.baseAttackTime )
		self.bat:SetStackCount( self.baseAttackTime )
		-- health init
		self.baseMaxHealth = self:GetParent():GetMaxHealth()
		self.hp.hpPct = self:GetParent():GetHealth() / self:GetParent():GetMaxHealth()
		-- ms init
		self.ms:SetStackCount( parent:GetIdealSpeed() )
		self.accModifiers = {}
		self.asModifiers = {}
		self.batModifiers = {}
		self.cdrModifiers = {}
		self.hpModifiers = {}
		self.msModifiers = {}
		self.state = 1
		for id, modifier in ipairs( self:GetParent():FindAllModifiers() ) do
			-- accuracy --------------------------------------
			if modifier.GetAccuracy then
				table.insert(self.accModifiers, modifier)
			end
			-- attack speed ----------------------------------
			if ( modifier.GetModifierAttackSpeedBonus ) 
			or ( modifier.GetModifierAttackSpeedBonusPercentage )
			or ( modifier.GetModifierAttackSpeedLimitBonus ) then
				table.insert(self.asModifiers, modifier)
			end
			-- base attack time ------------------------------
			if ( modifier.GetBaseAttackTime_Bonus ) 
			or ( modifier.GetBaseAttackTime_BonusPercentage ) then
				table.insert(self.batModifiers, modifier)
			end
			-- cooldown reduction  ----------------------------
			if modifier.GetCooldownReduction then
				table.insert(self.cdrModifiers, modifier)
			end
			-- health -----------------------------------------
			if modifier.GetModifierExtraHealthBonusPercentage then
				table.insert(self.hpModifiers, modifier)
			end
			-- movespeed --------------------------------------
			if modifier.GetMoveSpeedLimitBonus then
				table.insert(self.msModifiers, modifier)
			end
		end
	end
end

function modifier_handler_handler:OnIntervalThink()
	if IsServer() then
		if self.state == 1 then
			self.state = 2
			if #self.accModifiers > 0 then
				self:UpdateAccuracy()
				return
			end
		end
		if self.state == 2 then
			self.state = 3
			if #self.asModifiers > 0 then
				self:UpdateAttackSpeed()
				return
			end
		end
		if self.state == 3 then
			self.state = 4
			if #self.batModifiers > 0 then
				self:UpdateBaseAttackTime()
				return
			end
		end
		if self.state == 4 then
			self.state = 5
			if #self.cdrModifiers > 0 then
				self:UpdateCooldownReduction()
				return
			end
		end
		if self.state == 5 then
			self.state = 6
			if #self.hpModifiers > 0 then
				self:UpdateHealth()
				return
			end
		end
		if self.state == 6 then
			self.state = 7
			if #self.msModifiers > 0 then
				self:UpdateMoveSpeed()
				return
			end
		end
		if self.state == 7 then
			self.state = 1
			if #self.accModifiers > 0
			and #self.asModifiers > 0
			and #self.batModifiers > 0
			and #self.cdrModifiers > 0
			and #self.hpModifiers > 0
			and #self.msModifiers > 0 then
				self:StartIntervalThink(-1)
			end
		end
	end
end

function modifier_handler_handler:UpdateAccuracy()
	-- accuracy ------------------------------------------
	local accuracyStacks = 1
	for id, modifier in ipairs( self.accModifiers ) do
		if modifier and not modifier:IsNull() then
			local roll = modifier:GetAccuracy(true) 
			if roll then
				accuracyStacks = accuracyStacks * (1 - roll / 100)
			end
		else
			table.remove(self.accModifiers, id)
		end
	end
	local accuracy = (1 - accuracyStacks) * 100
	if self.acc:GetStackCount() ~= math.floor( accuracy ) then self.acc:SetStackCount( math.floor( accuracy ) ) end
end

function modifier_handler_handler:UpdateAttackSpeed()
	local parent = self:GetParent()
	self.as:SetStackCount(0)
	parent:CalculateStatBonus()
	local returnAttackSpeed = 0
	local attackSpeedPct = 1
	local bonusAttackSpeedCap = 0
	local attackSpeed = math.floor( parent:GetAttackSpeed() * 100 )
	for id, modifier in ipairs( self.asModifiers ) do
		if modifier and not modifier:IsNull() then
			if modifier.GetModifierAttackSpeedBonus then
				local bonus = modifier:GetModifierAttackSpeedBonus() 
				if bonus then returnAttackSpeed = returnAttackSpeed + (bonus or 0) end
			end
			if modifier.GetModifierAttackSpeedBonusPercentage then
				local bonus = modifier:GetModifierAttackSpeedBonusPercentage()
				if bonus then attackSpeedPct = attackSpeedPct + (bonus or 0) / 100 end
			end
			if modifier.GetModifierAttackSpeedLimitBonus then
				local bonus = modifier:GetModifierAttackSpeedLimitBonus()
				if bonus then bonusAttackSpeedCap = bonusAttackSpeedCap + (bonus or 0) end
			end
		else
			table.remove(self.asModifiers, id)
		end
	end
	local maxAttackSpeed = (INTERNAL_ATTACK_SPEED_CAP + bonusAttackSpeedCap ) - attackSpeed
	returnAttackSpeed = math.floor( math.min( returnAttackSpeed * attackSpeedPct, maxAttackSpeed ) )
	if returnAttackSpeed > 0 then
		returnAttackSpeed = math.abs(returnAttackSpeed).."0"
	else
		returnAttackSpeed = math.abs(returnAttackSpeed).."1"
	end
	local asStacks = tonumber(returnAttackSpeed)
	if self.as:GetStackCount() ~= asStacks then self.as:SetStackCount( asStacks ) end
	parent:CalculateStatBonus()
end

function modifier_handler_handler:UpdateBaseAttackTime()
	local parent = self:GetParent()
	self.bat:SetStackCount(0)
	local bonusBAT = 0
	local pctBAT = 1
	for id, modifier in ipairs( self.batModifiers ) do
		if modifier and not modifier:IsNull() then
			if modifier.GetBaseAttackTime_Bonus then
				local bonus = modifier:GetBaseAttackTime_Bonus() 
				if bonus then bonusBAT = bonusBAT + (bonus * 100) end
			end
			if modifier.GetBaseAttackTime_BonusPercentage then
				local bonus = modifier:GetBaseAttackTime_BonusPercentage()
				if bonus then pctBAT = pctBAT + ( bonus or 0 ) / 100 end
			end
		else
			table.remove(self.batModifiers, id)
		end
	end
	pctBAT = math.max(0.1, pctBAT)
	local newBAT =  math.min( math.max( self.baseAttackTime + bonusBAT, 10 ), 1000 )
	local batStacks = math.floor( newBAT * pctBAT )
	if self.bat:GetStackCount() ~= batStacks then self.bat:SetStackCount( batStacks ) end
	parent:CalculateStatBonus()
end

function modifier_handler_handler:UpdateCooldownReduction()
	local cdrStacks = 1
	for id, modifier in ipairs( self.cdrModifiers ) do
		if modifier and not modifier:IsNull() then
			local cdr = modifier:GetCooldownReduction() 
			if cdr then
				cdrStacks = cdrStacks * (1 - cdr / 100)
			end
		else
			table.remove(self.cdrModifiers, id)
		end
	end
	cdrStacks = (1 - cdrStacks) * 100 * 100 -- support decimal values
	if self.cdr:GetStackCount() ~= cdrStacks then self.cdr:SetStackCount(cdrStacks) end
end

function modifier_handler_handler:UpdateHealth()
	local parent = self:GetParent()
	local hpPct = parent:GetHealth() / parent:GetMaxHealth()
	self.hp:SetStackCount(0)
	parent:CalculateStatBonus()
	self.baseMaxHealth = self:GetParent():GetMaxHealth()
	local bonusPctHP = self.baseMaxHealth
	if bonusPctHP <= 0 then
		bonusPctHP = self.baseMaxHealth * (-1) + 1
	end
	for id, modifier in ipairs( self.hpModifiers ) do
		if modifier and not modifier:IsNull() then
			local bonus = modifier:GetModifierExtraHealthBonusPercentage()
			if bonus then
				bonusPctHP = bonusPctHP * ( 1 + bonus / 100 ) 
			end
		else
			table.remove(self.hpModifiers, id)
		end
	end
	bonusPctHP = bonusPctHP - self.baseMaxHealth
	local bonusHP = math.ceil( math.max( bonusPctHP, ( self.baseMaxHealth * (-1) ) + 1 ) )
	if bonusHP > 0 then
		bonusHP = math.abs(bonusHP).."0"
	else
		bonusHP = math.abs(bonusHP).."1"
	end
	local hpStacks = tonumber(bonusHP)
	if hpStacks ~= self.hp:GetStackCount() then self.hp:SetStackCount( hpStacks ) end
	parent:CalculateStatBonus()
	if IsServer() and parent:IsAlive() and parent:GetHealth() ~= parent:GetMaxHealth() * (hpPct or 100) then
		parent:SetHealth( parent:GetMaxHealth() * (hpPct or 100) )
	end
end

function modifier_handler_handler:UpdateMoveSpeed()
	local parent = self:GetParent()
	local msLimitMod = 0
	for id, modifier in ipairs( self.msModifiers ) do
		if modifier and not modifier:IsNull() then
			local bonus = modifier:GetMoveSpeedLimitBonus()
			if bonus then
				msLimitMod = msLimitMod + bonus
			end
		else
			table.remove(self.msModifiers, id)
		end
	end
	local newLimit = INTERNAL_MOVESPEED_CAP + msLimitMod
	local msStacks = math.min( parent:GetIdealSpeed(), newLimit )
	if self.ms:GetStackCount() ~= msStacks then self.ms:SetStackCount( msStacks ) end
end

function modifier_handler_handler:CheckIfUpdateNeeded(name, ability, duration)
	local parent = self:GetParent()
	local newestModifier
	local lastTime = -9999
	for id, modifier in ipairs( parent:FindAllModifiersByName(name) ) do
		if ability == modifier:GetAbility() and modifier:GetCreationTime() > lastTime then
			lastTime = modifier:GetCreationTime()
			newestModifier = modifier
		end
	end
	if newestModifier then
		if newestModifier.GetAccuracy then
			table.insert(self.accModifiers, newestModifier)
		end
		-- attack speed ----------------------------------
		if ( newestModifier.GetModifierAttackSpeedBonus ) 
		or ( newestModifier.GetModifierAttackSpeedBonusPercentage )
		or ( newestModifier.GetModifierAttackSpeedLimitBonus ) then
			table.insert(self.asModifiers, newestModifier)
		end
		-- base attack time ------------------------------
		if ( newestModifier.GetBaseAttackTime_Bonus ) 
		or ( newestModifier.GetBaseAttackTime_BonusPercentage ) then
			table.insert(self.batModifiers, newestModifier)
		end
		-- cooldown reduction  ----------------------------
		if newestModifier.GetCooldownReduction then
			table.insert(self.cdrModifiers, newestModifier)
		end
		-- health -----------------------------------------
		if newestModifier.GetModifierExtraHealthBonusPercentage then
			table.insert(self.hpModifiers, newestModifier)
		end
		-- movespeed --------------------------------------
		if newestModifier.GetMoveSpeedLimitBonus then
			table.insert(self.msModifiers, newestModifier)
		end
		--------------------------------
		--- UPDATE ---------------------
		--------------------------------
		self:StartIntervalThink(0.05)
	end
end

function modifier_handler_handler:IsHidden()
	return true
end

function modifier_handler_handler:IsPurgable()
	return false
end

function modifier_handler_handler:RemoveOnDeath()
	return false
end

function modifier_handler_handler:IsPermanent()
	return true
end

function modifier_handler_handler:AllowIllusionDuplicate()
	return true
end

function modifier_handler_handler:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end