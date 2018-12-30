modifier_handler_handler = class({})
	
INTERNAL_ATTACK_SPEED_CAP = 750
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
		-- ms init
		self.ms:SetStackCount( parent:GetIdealSpeed() )
		------------------------------------------------------------
		self:OnIntervalThink()
		self:StartIntervalThink(0.33)
		
		parent:SetHealth( parent:GetMaxHealth() )
	end
end

function modifier_handler_handler:OnIntervalThink()
	local parent = self:GetParent()
	-- think init ----------------------------------------
	local hpPct = parent:GetHealth() / parent:GetMaxHealth()
	self.acc:SetStackCount(0)
	self.as:SetStackCount(0)
	self.bat:SetStackCount(0)
	self.cdr:SetStackCount(0)
	self.hp:SetStackCount(0)
	self.ms:SetStackCount(0)
	parent:CalculateStatBonus()
	-- accuracy ------------------------------------------
	local accuracyStacks = 1
	-- attack speed --------------------------------------
	local returnAttackSpeed = 0
	local attackSpeedPct = 1
	local bonusAttackSpeedCap = 0
	local attackSpeed = math.floor( parent:GetAttackSpeed() * 100 )
	-- base attack time ----------------------------------
	local bonusBAT = 0
	local pctBAT = 1
	-- cooldown reduction  -------------------------------
	local cdrStacks = 1
	-- health --------------------------------------------
	self.baseMaxHealth = self:GetParent():GetMaxHealth()
	local bonusPctHP = self.baseMaxHealth
	if bonusPctHP <= 0 then
		bonusPctHP = self.baseMaxHealth * (-1) + 1
	end
	-- movespeed -----------------------------------------
	local msLimitMod = 0
	-- looping and handling ------------------------------
	for _, modifier in ipairs( self:GetParent():FindAllModifiers() ) do
		-- accuracy --------------------------------------
		if modifier.GetAccuracy then
			local roll = modifier:GetAccuracy(true) 
			if roll then
				accuracyStacks = accuracyStacks * (1 - roll / 100)
			end
		end
		-- attack speed ----------------------------------
		if modifier.GetModifierAttackSpeedBonus and modifier:GetModifierAttackSpeedBonus() then
			returnAttackSpeed = returnAttackSpeed + (modifier:GetModifierAttackSpeedBonus() or 0)
		end
		if modifier.GetModifierAttackSpeedBonusPercentage and modifier:GetModifierAttackSpeedBonusPercentage() then
			attackSpeedPct = attackSpeedPct + (modifier:GetModifierAttackSpeedBonusPercentage() or 0) / 100
		end
		if modifier.GetModifierAttackSpeedLimitBonus and modifier:GetModifierAttackSpeedLimitBonus() then
			bonusAttackSpeedCap = bonusAttackSpeedCap + (modifier:GetModifierAttackSpeedLimitBonus() or 0)
		end
		-- base attack time ------------------------------
		if modifier.GetBaseAttackTime_Bonus and modifier:GetBaseAttackTime_Bonus() then
			bonusBAT = bonusBAT + (modifier:GetBaseAttackTime_Bonus() * 100) 
		end
		if modifier.GetBaseAttackTime_BonusPercentage and modifier:GetBaseAttackTime_BonusPercentage() then
			pctBAT = pctBAT + ( modifier:GetBaseAttackTime_Bonus() or 0 ) / 100
		end
		-- cooldown reduction  ----------------------------
		if modifier.GetCooldownReduction then
			local cdr = modifier:GetCooldownReduction() 
			if cdr then
				cdrStacks = cdrStacks * (1 - cdr / 100)
			end
		end
		-- health -----------------------------------------
		if modifier.GetModifierExtraHealthBonusPercentage and modifier:GetModifierExtraHealthBonusPercentage() then
			bonusPctHP = bonusPctHP * ( 1 + modifier:GetModifierExtraHealthBonusPercentage() / 100 ) 
		end
		-- movespeed --------------------------------------
		if modifier.GetMoveSpeedLimitBonus and modifier:GetMoveSpeedLimitBonus() then
			msLimitMod = msLimitMod + modifier:GetMoveSpeedLimitBonus()
		end
	end
	-- accuracy -------------------------------------------
	local accuracy = (1 - accuracyStacks) * 100
	self.acc:SetStackCount( math.floor( accuracy ) )
	-- attack speed ---------------------------------------
	local maxAttackSpeed = (INTERNAL_ATTACK_SPEED_CAP + bonusAttackSpeedCap ) - attackSpeed
	returnAttackSpeed = math.floor( math.min( returnAttackSpeed * attackSpeedPct, maxAttackSpeed ) )
	if returnAttackSpeed > 0 then
		returnAttackSpeed = math.abs(returnAttackSpeed).."0"
	else
		returnAttackSpeed = math.abs(returnAttackSpeed).."1"
	end
	self.as:SetStackCount( tonumber(returnAttackSpeed) )
	-- base attack time -----------------------------------
	pctBAT = math.max(0.1, pctBAT)
	local newBAT =  math.min( math.max( self.baseAttackTime + bonusBAT, 10 ), 1000 )
	self.bat:SetStackCount( math.floor( newBAT * pctBAT ) )
	-- cooldown reduction  --------------------------------
	cdrStacks = (1 - cdrStacks) * 100 * 100 -- support decimal values
	self.cdr:SetStackCount(cdrStacks)
	-- health ---------------------------------------------
	bonusPctHP = bonusPctHP - self.baseMaxHealth
	local bonusHP = math.ceil( math.max( bonusPctHP, ( self.baseMaxHealth * (-1) ) + 1 ) )
	if bonusHP > 0 then
		bonusHP = math.abs(bonusHP).."0"
	else
		bonusHP = math.abs(bonusHP).."1"
	end
	self.hp:SetStackCount( tonumber(bonusHP) )
	-- movespeed ------------------------------------------
	local newLimit = INTERNAL_MOVESPEED_CAP + msLimitMod
	self.ms:SetStackCount( math.min( parent:GetIdealSpeed(), newLimit ) )
	-------------------------------------------------------
	parent:CalculateStatBonus()
	if parent:IsAlive() then
		parent:SetHealth( parent:GetMaxHealth() * hpPct )
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