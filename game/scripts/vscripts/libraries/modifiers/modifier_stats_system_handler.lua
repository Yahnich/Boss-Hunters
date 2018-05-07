modifier_stats_system_handler = class({})


-- OTHER
MOVESPEED_TABLE = {0,25,50,75,100,150}
MANA_TABLE = {0,3,6,9,12,18}
MANA_REGEN_TABLE = {0,5,10,15,20,30}
HEAL_AMP_TABLE = {0,20,40,60,80,120}

-- OFFENSE
ATTACK_DAMAGE_TABLE = {0,35,70,105,140,200}
SPELL_AMP_TABLE = {0,15,30,45,60,90}
COOLDOWN_REDUCTION_TABLE = {0,5,10,15,20,30}
ATTACK_SPEED_TABLE = {0,35,70,105,140,200}
STATUS_AMP_TABLE = {0,5,10,15,20,30}

-- DEFENSE
ARMOR_TABLE = {0,5,10,15,20,30}
MAGIC_RESIST_TABLE = {0,6,12,18,24,35}
DAMAGE_BLOCK_TABLE = {0,20,40,60,80,120}
ATTACK_RANGE_TABLE = {0,100,200,300,400,600}
HEALTH_TABLE = {0,2,4,6,8,12}
HEALTH_REGEN_TABLE = {0,5,10,15,20,30}
STATUS_REDUCTION_TABLE = {0,5,10,15,20,30}

ALL_STATS = 2

function modifier_stats_system_handler:OnCreated()
	self:OnIntervalThink()
	self:StartIntervalThink(0.1)
end

function modifier_stats_system_handler:OnIntervalThink()
	self:UpdateStatValues()
	if IsServer() then self:GetParent():CalculateStatBonus() end
end

function modifier_stats_system_handler:UpdateStatValues()
	-- OTHER
	self.msLevel = tonumber(CustomNetTables:GetTableValue("stats_panel", tostring(self:GetCaster():entindex()) )["ms"])
	self.mpLevel = tonumber(CustomNetTables:GetTableValue("stats_panel", tostring(self:GetCaster():entindex()) )["mp"])
	self.mprLevel = tonumber(CustomNetTables:GetTableValue("stats_panel", tostring(self:GetCaster():entindex()) )["mpr"])
	self.haLevel = tonumber(CustomNetTables:GetTableValue("stats_panel", tostring(self:GetCaster():entindex()) )["ha"])
	
	-- OFFENSE
	self.adLevel = tonumber(CustomNetTables:GetTableValue("stats_panel", tostring(self:GetCaster():entindex()) )["ad"])
	self.saLevel = tonumber(CustomNetTables:GetTableValue("stats_panel", tostring(self:GetCaster():entindex()) )["sa"])
	self.cdrLevel = tonumber(CustomNetTables:GetTableValue("stats_panel", tostring(self:GetCaster():entindex()) )["cdr"])
	self.asLevel = tonumber(CustomNetTables:GetTableValue("stats_panel", tostring(self:GetCaster():entindex()) )["as"])
	self.staLevel = tonumber(CustomNetTables:GetTableValue("stats_panel", tostring(self:GetCaster():entindex()) )["sta"])
	
	-- DEFENSE
	self.prLevel = tonumber(CustomNetTables:GetTableValue("stats_panel", tostring(self:GetCaster():entindex()) )["pr"])
	self.mrLevel = tonumber(CustomNetTables:GetTableValue("stats_panel", tostring(self:GetCaster():entindex()) )["mr"])
	self.dbLevel = tonumber(CustomNetTables:GetTableValue("stats_panel", tostring(self:GetCaster():entindex()) )["db"])
	self.arLevel = tonumber(CustomNetTables:GetTableValue("stats_panel", tostring(self:GetCaster():entindex()) )["ar"])
	self.hpLevel = tonumber(CustomNetTables:GetTableValue("stats_panel", tostring(self:GetCaster():entindex()) )["hp"])
	self.hprLevel = tonumber(CustomNetTables:GetTableValue("stats_panel", tostring(self:GetCaster():entindex()) )["hpr"])
	self.srLevel = tonumber(CustomNetTables:GetTableValue("stats_panel", tostring(self:GetCaster():entindex()) )["sr"])
	
	self.allStats = tonumber(CustomNetTables:GetTableValue("stats_panel", tostring(self:GetCaster():entindex()) )["all"])
end

function modifier_stats_system_handler:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MANA_BONUS,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
		MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
		MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK,
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
	}
	return funcs
end

function modifier_stats_system_handler:GetModifierMoveSpeedBonus_Constant() return MOVESPEED_TABLE[self.msLevel + 1] end
function modifier_stats_system_handler:GetModifierManaBonus() return 400 + MANA_TABLE[self.mpLevel + 1] * self:GetParent():GetIntellect() end
function modifier_stats_system_handler:GetModifierConstantManaRegen() return 4 + MANA_REGEN_TABLE[self.mprLevel + 1] end
function modifier_stats_system_handler:GetModifierHealAmplify_Percentage() return HEAL_AMP_TABLE[self.haLevel + 1] end

function modifier_stats_system_handler:GetModifierBaseAttack_BonusDamage() return ATTACK_DAMAGE_TABLE[self.adLevel + 1] end
function modifier_stats_system_handler:GetModifierSpellAmplify_Percentage() return SPELL_AMP_TABLE[self.saLevel + 1] end
function modifier_stats_system_handler:GetCooldownReduction() return COOLDOWN_REDUCTION_TABLE[self.cdrLevel + 1] end
function modifier_stats_system_handler:GetModifierAttackSpeedBonus_Constant() return ATTACK_SPEED_TABLE[self.asLevel + 1] end
function modifier_stats_system_handler:GetModifierStatusAmplify_Percentage() return STATUS_AMP_TABLE[self.staLevel + 1] end

function modifier_stats_system_handler:GetModifierPhysicalArmorBonus()
	local bonusarmor = 0
	if not self:GetParent():IsRangedAttacker() then bonusarmor = 6 end
	return ARMOR_TABLE[self.prLevel + 1] + bonusarmor
end
function modifier_stats_system_handler:GetModifierMagicalResistanceBonus() return MAGIC_RESIST_TABLE[self.mrLevel + 1] end

function modifier_stats_system_handler:GetModifierTotal_ConstantBlock(params) 
	if RollPercentage( 50 ) and not self:GetParent():IsRangedAttacker() and params.attacker ~= self:GetParent() then 
		return DAMAGE_BLOCK_TABLE[self.dbLevel + 1] 
	end
end

function modifier_stats_system_handler:GetModifierAttackRangeBonus() 
	if self:GetParent():IsRangedAttacker() then 
		return ATTACK_RANGE_TABLE[self.arLevel + 1] 
	end
end

function modifier_stats_system_handler:GetModifierHealthBonus() return 300 + HEALTH_TABLE[self.hpLevel + 1] * self:GetParent():GetStrength() end
function modifier_stats_system_handler:GetModifierConstantHealthRegen() return 5 + HEALTH_REGEN_TABLE[self.hprLevel + 1] end
function modifier_stats_system_handler:GetModifierStatusResistance() return STATUS_REDUCTION_TABLE[self.srLevel + 1] end

function modifier_stats_system_handler:GetModifierBonusStats_Strength() return ALL_STATS * self.allStats end
function modifier_stats_system_handler:GetModifierBonusStats_Agility() return ALL_STATS * self.allStats end
function modifier_stats_system_handler:GetModifierBonusStats_Intellect() return ALL_STATS * self.allStats end

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