vile_archmage_vile_archon = class({})

function vile_archmage_vile_archon:GetIntrinsicModifierName()
	return "modifier_vile_archmage_vile_archon"
end

modifier_vile_archmage_vile_archon = class({})
LinkLuaModifier("modifier_vile_archmage_vile_archon", "bosses/boss_vile_archmage/vile_archmage_vile_archon", LUA_MODIFIER_MOTION_NONE)

function modifier_vile_archmage_vile_archon:OnCreated()
	self.interval = self:GetSpecialValueFor("interval")
	self.duration = self:GetSpecialValueFor("duration")
	if IsServer() then
		self:StartIntervalThink(self.interval)
	end
end

function modifier_vile_archmage_vile_archon:OnRefresh()
	self.boss = self:GetSpecialValueFor("interval")
	self.duration = self:GetSpecialValueFor("duration")
	if IsServer() then
		self:StartIntervalThink(self.interval)
	end
end

function modifier_vile_archmage_vile_archon:OnIntervalThink()
	self:GetCaster():AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_vile_archmage_vile_archon_buff", {duration = self.duration} )
end

function modifier_vile_archmage_vile_archon:IsHidden()
	return true
end

modifier_vile_archmage_vile_archon_buff = class({})
LinkLuaModifier("modifier_vile_archmage_vile_archon_buff", "bosses/boss_vile_archmage/vile_archmage_vile_archon", LUA_MODIFIER_MOTION_NONE)

function modifier_vile_archmage_vile_archon_buff:OnCreated()
	self.cdr = self:GetSpecialValueFor("cooldown_reduction")
end

function modifier_vile_archmage_vile_archon_buff:OnRefresh()
	self.cr = self:GetSpecialValueFor("cooldown_reduction")
end

function modifier_vile_archmage_vile_archon_buff:DeclareFunctions()
	return {MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE_STACKING}
end

function modifier_vile_archmage_vile_archon_buff:GetModifierPercentageCooldownStacking(params)
	return self.cdr
end

function modifier_vile_archmage_vile_archon_buff:GetEffectName()
	return "particles/units/heroes/hero_pugna/pugna_decrepify.vpcf"
end