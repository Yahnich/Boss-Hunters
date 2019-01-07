modifier_stats_system_handler = class({})


-- OTHER
MOVESPEED_TABLE = 10
MANA_TABLE = 200
MANA_REGEN_TABLE = 1.5
HEAL_AMP_TABLE = {0,15,30,45,60,75}
-- OFFENSE
ATTACK_DAMAGE_TABLE = 20
SPELL_AMP_TABLE = 10
COOLDOWN_REDUCTION_TABLE = {0,10,15,20,25,30}
ATTACK_SPEED_TABLE = 10
STATUS_AMP_TABLE = {0,10,15,20,25,30}
ACCURACY_TABLE = {0,15,30,45,60,75}

-- DEFENSE
ARMOR_TABLE = 1
MAGIC_RESIST_TABLE = {0,10,15,20,25,30}
ATTACK_RANGEM_TABLE = 25
ATTACK_RANGE_TABLE = 50
HEALTH_TABLE = 150
HEALTH_REGEN_TABLE = 2
STATUS_REDUCTION_TABLE = {0,10,20,30,40,50}

ALL_STATS = 2

function modifier_stats_system_handler:OnStackCountChanged(iStacks)
	self:UpdateStatValues()
end

function modifier_stats_system_handler:UpdateStatValues()
	-- OTHER
	local entindex = self:GetCaster():entindex()
	if not self:GetCaster():IsRealHero() then
		entindex = self:GetStackCount()
	end
	
	local netTable = CustomNetTables:GetTableValue("stats_panel", tostring(entindex) ) or {}
	self.ms = MOVESPEED_TABLE * tonumber(netTable["ms"])
	self.mp = MANA_TABLE * tonumber(netTable["mp"])
	self.mpr = MANA_REGEN_TABLE * tonumber(netTable["mpr"])
	self.ha = HEAL_AMP_TABLE[math.max(#HEAL_AMP_TABLE, tonumber(netTable["ha"]) + 1)]
	
	-- OFFENSE
	self.ad = ATTACK_DAMAGE_TABLE * tonumber(netTable["ad"])
	self.sa = SPELL_AMP_TABLE * tonumber(netTable["sa"])
	-- self.cdr = COOLDOWN_REDUCTION_TABLE[tonumber(netTable["cdr"]) + 1]
	self.as = ATTACK_SPEED_TABLE * tonumber(netTable["as"])
	self.sta = STATUS_AMP_TABLE[math.max(#STATUS_AMP_TABLE, tonumber(netTable["sta"]) + 1)]
	self.acc = ACCURACY_TABLE[math.max(#ACCURACY_TABLE, tonumber(netTable["acc"]) + 1)]
	
	-- DEFENSE
	self.pr = ARMOR_TABLE * tonumber(netTable["pr"]) + 1
	self.mr = MAGIC_RESIST_TABLE[math.max(#MAGIC_RESIST_TABLE, tonumber(netTable["mr"]) + 1)]
	
	if self:GetParent():IsRangedAttacker() then 
		self.ar = ATTACK_RANGE_TABLE * tonumber(netTable["ar"])
	else
		self.ar = ATTACK_RANGEM_TABLE * tonumber(netTable["ar"])
	end
	
	self.hp = HEALTH_TABLE * tonumber(netTable["hp"])
	self.hpr = HEALTH_REGEN_TABLE * tonumber(netTable["hpr"])
	self.sr = STATUS_REDUCTION_TABLE[math.max(#STATUS_REDUCTION_TABLE, tonumber(netTable["sr"]) + 1)]
	
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
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
		MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_STATUS_RESISTANCE,
	}
	return funcs
end

function modifier_stats_system_handler:GetModifierMoveSpeedBonus_Constant() return -35 + (self.ms or 0) end
function modifier_stats_system_handler:GetModifierManaBonus() return 500 + (self.mp or 0) end
function modifier_stats_system_handler:GetModifierConstantManaRegen() return (self.mpr or 0) end
function modifier_stats_system_handler:GetModifierHealAmplify_Percentage() return self.ha or 0 end

function modifier_stats_system_handler:GetModifierPreAttack_BonusDamage() return (self.ad or 0) end
function modifier_stats_system_handler:GetModifierBaseAttack_BonusDamage() return 10 end
	
function modifier_stats_system_handler:GetModifierSpellAmplify_Percentage()
	local int_multiplier = TernaryOperator( 0.06, self:GetParent():GetPrimaryAttribute() == DOTA_ATTRIBUTE_INTELLECT, 0.04 )
	return self:GetParent():GetIntellect() * int_multiplier + (self.sa or 0) 
end

-- function modifier_stats_system_handler:GetCooldownReduction() return self.cdr or 0 end
function modifier_stats_system_handler:GetModifierAttackSpeedBonus() return 50 + (self.as or 0) end
function modifier_stats_system_handler:GetModifierStatusAmplify_Percentage() return self.sta or 0 end
function modifier_stats_system_handler:GetAccuracy(params)
	local accuracy = self.acc or 0
	if not self:GetParent():IsRangedAttacker() then
		accuracy = accuracy + 35
	end
	return accuracy
end

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

function modifier_stats_system_handler:GetModifierAttackRangeBonus() 
	return self.ar or 0
end

function modifier_stats_system_handler:GetModifierExtraHealthBonus() return 400 + (self.hp or 0) end
function modifier_stats_system_handler:GetModifierConstantHealthRegen() return (self.hpr or 0) end
function modifier_stats_system_handler:GetModifierStatusResistance() return self.sr or 0 end

function modifier_stats_system_handler:GetModifierBonusStats_Strength() return self.allStats or 0 end
function modifier_stats_system_handler:GetModifierBonusStats_Agility() return self.allStats or 0 end
function modifier_stats_system_handler:GetModifierBonusStats_Intellect() return self.allStats or 0 end

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

function modifier_stats_system_handler:AllowIllusionDuplicate()
	return true
end