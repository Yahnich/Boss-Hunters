modifier_stats_system_handler = class({})


-- OTHER
MOVESPEED_TABLE = {0,20,40,60,80,150}
MANA_TABLE = {0,250,500,750,1000,1250,1500,1750,2000,2250,3000}
MANA_REGEN_TABLE = {0,3,6,9,12,15,18,21,24,27,50}
HEAL_AMP_TABLE = {0,10,20,30,40,80}

-- OFFENSE
ATTACK_DAMAGE_TABLE = {0,20,40,60,80,100,120,140,160,180,250}
SPELL_AMP_TABLE = {0,10,15,20,25,30,35,40,45,50,75}
COOLDOWN_REDUCTION_TABLE = {0,10,12,15,18,25}
ATTACK_SPEED_TABLE = {0,20,40,60,80,100,120,140,160,180,250}
STATUS_AMP_TABLE = {0,5,10,15,20,35}

-- DEFENSE
ARMOR_TABLE = {0,2,4,6,8,10,12,14,16,18,25}
MAGIC_RESIST_TABLE = {0,5,10,15,20,25,30,35,40,45,60}
DAMAGE_BLOCK_TABLE = {0,10,20,30,40,50,60,70,80,90,120}
ATTACK_RANGE_TABLE = {0,50,100,150,200,250,300,350,400,450,600}
HEALTH_TABLE = {0,150,300,450,600,750,900,1050,1200,1350,2000}
HEALTH_REGEN_TABLE = {0,3,6,9,12,15,18,21,24,27,50}
STATUS_REDUCTION_TABLE = {0,5,10,15,20,35}

ALL_STATS = 2

function modifier_stats_system_handler:OnCreated()
	self:UpdateStatValues()
	self:StartIntervalThink(1)
end

function modifier_stats_system_handler:OnIntervalThink()
	self:UpdateStatValues()
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
		MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE_STACKING,
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
function modifier_stats_system_handler:GetModifierManaBonus() return 400 + MANA_TABLE[self.mpLevel + 1] end
function modifier_stats_system_handler:GetModifierConstantManaRegen() return 1.5 + MANA_REGEN_TABLE[self.mprLevel + 1] end
function modifier_stats_system_handler:GetModifierHealAmplify_Percentage() return HEAL_AMP_TABLE[self.haLevel + 1] end

function modifier_stats_system_handler:GetModifierBaseAttack_BonusDamage() return ATTACK_DAMAGE_TABLE[self.adLevel + 1] end
function modifier_stats_system_handler:GetModifierSpellAmplify_Percentage() return SPELL_AMP_TABLE[self.saLevel + 1] end
function modifier_stats_system_handler:GetModifierPercentageCooldownStacking() return COOLDOWN_REDUCTION_TABLE[self.cdrLevel + 1] end
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

function modifier_stats_system_handler:GetModifierHealthBonus() return 300 + HEALTH_TABLE[self.hpLevel + 1] end
function modifier_stats_system_handler:GetModifierConstantHealthRegen() return 2.5 + HEALTH_REGEN_TABLE[self.hprLevel + 1] end
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