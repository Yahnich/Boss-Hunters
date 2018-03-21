modifier_stats_system_handler = class({})


-- OTHER
MOVESPEED_TABLE = {0,15,20,25,30,35,40,45,50,55,60}
MANA_TABLE = {0,250,500,750,1000,1250,1500,1750,2000,2250,2500}
MANA_REGEN_TABLE = {0,0.1,0.2,0.3,0.4,0.5}
HEAL_AMP_TABLE = {0,10,20,30,40,50}

-- OFFENSE
ATTACK_DAMAGE_TABLE = {0,10,20,30,40,50,60,70,80,90,100}
SPELL_AMP_TABLE = {0,10,15,20,25,30,35,40,45,50,55}
COOLDOWN_REDUCTION_TABLE = {0,10,15,20,25}
ATTACK_SPEED_TABLE = {0,25,50,75,100,125,150,175,200,225,250}
STATUS_AMP_TABLE = {0,10,15,20,25}

-- DEFENSE
ARMOR_TABLE = {0,2,4,6,8,10,12,14,16,18,20}
MAGIC_RESIST_TABLE = {0,5,10,15,20,25,30,35,40,45,50}
DAMAGE_BLOCK_TABLE = {0,20,25,30,35,40,45,50,55,60,65}
ATTACK_RANGE_TABLE = {0,50,100,150,200,250,300,350,400,450,500}
HEALTH_TABLE = {0,250,500,750,1000,1250,1500,1750,2000,2250,2500}
HEALTH_REGEN_TABLE = {0,0.1,0.2,0.3,0.4,0.5}
STATUS_REDUCTION_TABLE = {0,10,15,20,25}

function modifier_stats_system_handler:OnCreated()
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
end

function modifier_stats_system_handler:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MANA_BONUS,
		MODIFIER_PROPERTY_MANA_REGEN_PERCENTAGE,
		MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE_STACKING,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
		MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK,
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE
	}
	return funcs
end

function modifier_stats_system_handler:GetModifierMoveSpeedBonus_Constant() return MOVESPEED_TABLE[self.msLevel + 1] end
function modifier_stats_system_handler:GetModifierManaBonus() return MANA_TABLE[self.mpLevel + 1] end
function modifier_stats_system_handler:GetModifierPercentageManaRegen() return MANA_REGEN_TABLE[self.mprLevel + 1] end
function modifier_stats_system_handler:GetModifierHealAmplify_Percentage() return HEAL_AMP_TABLE[self.haLevel + 1] end

function modifier_stats_system_handler:GetModifierBaseAttack_BonusDamage() return ATTACK_DAMAGE_TABLE[self.adLevel + 1] end
function modifier_stats_system_handler:GetModifierSpellAmplify_Percentage() return SPELL_AMP_TABLE[self.saLevel + 1] end
function modifier_stats_system_handler:GetModifierPercentageCooldownStacking() return COOLDOWN_REDUCTION_TABLE[self.cdrLevel + 1] end
function modifier_stats_system_handler:GetModifierAttackSpeedBonus_Constant() return ATTACK_SPEED_TABLE[self.asLevel + 1] end
function modifier_stats_system_handler:GetModifierStatusAmplify_Percentage() return STATUS_AMP_TABLE[self.staLevel + 1] end

function modifier_stats_system_handler:GetModifierPhysicalArmorBonus() return ARMOR_TABLE[self.prLevel + 1] end
function modifier_stats_system_handler:GetModifierMagicalResistanceBonus() return MAGIC_RESIST_TABLE[self.mrLevel + 1] end
function modifier_stats_system_handler:GetModifierTotal_ConstantBlock() return DAMAGE_BLOCK_TABLE[self.dbLevel + 1] end
function modifier_stats_system_handler:GetModifierAttackRangeBonus() return ATTACK_RANGE_TABLE[self.arLevel + 1] end
function modifier_stats_system_handler:GetModifierHealthBonus() return HEALTH_TABLE[self.hpLevel + 1] end
function modifier_stats_system_handler:GetModifierHealthRegenPercentage() return HEALTH_REGEN_TABLE[self.hprLevel + 1] end
function modifier_stats_system_handler:GetModifierStatusResistance() return STATUS_REDUCTION_TABLE[self.srLevel + 1] end



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