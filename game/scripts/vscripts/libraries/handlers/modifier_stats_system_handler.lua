modifier_stats_system_handler = class({})


-- OTHER
MOVESPEED_TABLE = 15
MANA_TABLE = 300
MANA_REGEN_TABLE = 3
HEAL_AMP_TABLE = {0,15,30,45,60,75}
-- OFFENSE
ATTACK_DAMAGE_TABLE = 20
SPELL_AMP_TABLE = 10
COOLDOWN_REDUCTION_TABLE = {0,10,15,20,25,30}
ATTACK_SPEED_TABLE = 10
STATUS_AMP_TABLE = {0,10,15,20,25,30}
-- ACCURACY_TABLE = {0,15,30,45,60,75}
AREA_DAMAGE_TABLE = {0,10,20,30,40,50}

-- DEFENSE
ARMOR_TABLE = 1
MAGIC_RESIST_TABLE = {0,10,15,20,25,30}
ATTACK_RANGEM_TABLE = 25
ATTACK_RANGE_TABLE = 50
HEALTH_TABLE = 200
HEALTH_REGEN_TABLE = 3
STATUS_REDUCTION_TABLE = {0,10,20,30,40,50}

ALL_STATS = 2

function modifier_stats_system_handler:OnCreated()
	self:UpdateStatValues()
end

function modifier_stats_system_handler:OnStackCountChanged(iStacks)
	self:UpdateStatValues()
end

function modifier_stats_system_handler:UpdateStatValues()
	-- OTHER
	local entindex = self:GetCaster():entindex()
	if self:GetCaster():GetParentUnit() then
		entindex = self:GetCaster():GetParentUnit():entindex()
	end
	local netTable = CustomNetTables:GetTableValue("stats_panel", tostring(entindex) ) or {}
	print("calc other", self:GetCaster():GetUnitName() )
	self.ms = MOVESPEED_TABLE * tonumber(netTable["ms"])
	self.mp = MANA_TABLE * tonumber(netTable["mp"])
	self.mpr = MANA_REGEN_TABLE * tonumber(netTable["mpr"])
	self.ha = HEAL_AMP_TABLE[math.min(#HEAL_AMP_TABLE, tonumber(netTable["ha"]) + 1)]
	print("calc offense", self:GetCaster():GetUnitName() )
	-- OFFENSE
	self.ad = ATTACK_DAMAGE_TABLE * tonumber(netTable["ad"])
	self.sa = SPELL_AMP_TABLE * tonumber(netTable["sa"])
	-- self.cdr = COOLDOWN_REDUCTION_TABLE[tonumber(netTable["cdr"]) + 1]
	self.as = ATTACK_SPEED_TABLE * tonumber(netTable["as"])
	self.sta = STATUS_AMP_TABLE[math.min(#STATUS_AMP_TABLE, tonumber(netTable["sta"]) + 1)]
	-- self.acc = ACCURACY_TABLE[math.min(#ACCURACY_TABLE, tonumber(netTable["acc"]) + 1)]
	
	print("calc defense", self:GetCaster():GetUnitName() )
	-- DEFENSE
	self.pr = ARMOR_TABLE * tonumber(netTable["pr"]) + 1
	self.mr = MAGIC_RESIST_TABLE[math.min(#MAGIC_RESIST_TABLE, tonumber(netTable["mr"]) + 1)]
	
	self.ard = AREA_DAMAGE_TABLE[math.min(#MAGIC_RESIST_TABLE, tonumber(netTable["ard"]) + 1)]
	
	self.hp = HEALTH_TABLE * tonumber(netTable["hp"])
	self.hpr = HEALTH_REGEN_TABLE * tonumber(netTable["hpr"])
	self.sr = STATUS_REDUCTION_TABLE[math.min(#STATUS_REDUCTION_TABLE, tonumber(netTable["sr"]) + 1)]
	
	print("calc stats", self:GetCaster():GetUnitName() )
	self.allStats =  ALL_STATS * tonumber(netTable["all"])
	
	
	if IsServer() then self:GetParent():CalculateStatBonus() end
end

function modifier_stats_system_handler:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MANA_BONUS,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
		
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
		-- MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK,
		-- MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
		MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_STATUS_RESISTANCE,
		MODIFIER_PROPERTY_EVASION_CONSTANT,
		MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
		MODIFIER_EVENT_ON_TAKEDAMAGE 
	}
	return funcs
end

function modifier_stats_system_handler:GetModifierMoveSpeedBonus_Constant() 
	local movespeed = (self.ms or 0) 
	return movespeed
end

function modifier_stats_system_handler:GetModifierManaBonus() return 500 + (self.mp or 0) end
function modifier_stats_system_handler:GetModifierConstantManaRegen() return 1.5 + (self.mpr or 0) - self:GetParent():GetIntellect() * 0.05 end
function modifier_stats_system_handler:GetModifierHealAmplify_Percentage() return self.ha or 0 end

function modifier_stats_system_handler:GetModifierPreAttack_BonusDamage() return (self.ad or 0) end
	
function modifier_stats_system_handler:GetModifierSpellAmplify_Percentage()
	return self:GetParent():GetIntellect() * 0.25 + (self.sa or 0) 
end

-- function modifier_stats_system_handler:GetCooldownReduction() return self.cdr or 0 end
function modifier_stats_system_handler:GetModifierAttackSpeedBonus() return 50 + (self.as or 0) end
function modifier_stats_system_handler:GetModifierStatusAmplify_Percentage() return self.sta or 0 end
function modifier_stats_system_handler:GetModifierAreaDamage() return self.ard or 0 end

function modifier_stats_system_handler:GetModifierPhysicalArmorBonus()
	local bonusarmor = 0
	if not self:GetParent():IsRangedAttacker() then bonusarmor = 3 end
	return ( self.pr or 0 ) + bonusarmor
end
function modifier_stats_system_handler:GetModifierMagicalResistanceBonus() return self.mr end

-- function modifier_stats_system_handler:GetModifierTotal_ConstantBlock(params) 
	-- if RollPercentage( 50 ) and not self:GetParent():IsRangedAttacker() and params.attacker ~= self:GetParent() then 
		-- return self.db or 0
	-- end
-- end

-- function modifier_stats_system_handler:GetModifierAttackRangeBonus() 
	-- return self.ar or 0
-- end

function modifier_stats_system_handler:GetModifierExtraHealthBonus() return 300 + (self.hp or 0) end
function modifier_stats_system_handler:GetModifierConstantHealthRegen() return 1 + (self.hpr or 0) - self:GetParent():GetStrength() * 0.1 end
function modifier_stats_system_handler:GetModifierStatusResistance() return ( 1 - ( (1-0.002)^self:GetParent():GetStrength() * (1-self.sr/100) ) ) * 100  end

function modifier_stats_system_handler:GetModifierBonusStats_Strength() return (self.allStats or 0) + (self.str or 0) end
function modifier_stats_system_handler:GetModifierBonusStats_Agility() return (self.allStats or 0) + (self.agi or 0) end
function modifier_stats_system_handler:GetModifierBonusStats_Intellect() return (self.allStats or 0) + (self.int or 0) end

function modifier_stats_system_handler:GetModifierEvasion_Constant() return 5 + (self.evasion or 0) + (1-(1-0.0035)^self:GetParent():GetAgility())*100 end
function modifier_stats_system_handler:GetModifierPreAttack_CriticalStrike()
	if self:RollPRNG( 5 + (self.critChance or 0) ) then
		return 200 + (self.critDamage or 0)
	end
end

function modifier_stats_system_handler:OnTakeDamage( params )
	if params.attacker == self:GetParent() and params.unit ~= self:GetParent() and self:GetParent():GetHealth() > 0 and not ( HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) or HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) or HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL) ) then
		local lifesteal = (1-(1-0.00125)^self:GetParent():GetIntellect())
		if params.inflictor and params.unit:IsMinion() then
				lifesteal = lifesteal / 4
		end
		local flHeal = math.ceil(params.damage * lifesteal)
		params.attacker:HealEvent(flHeal, params.inflictor, params.attacker)
	end
end

function modifier_stats_system_handler:IsHidden()
	return true
end

function modifier_stats_system_handler:IsPermanent()
	return true
end

function modifier_stats_system_handler:IsPurgable()
	return false
end

function modifier_stats_system_handler:RemoveOnDeath()
	return false
end

function modifier_stats_system_handler:GetAttributes()
	return MODIFIER_ATTRIBUTE_PERMANENT
end