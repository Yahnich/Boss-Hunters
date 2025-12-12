drow_ranger_drows_teachings = class({})

function drow_ranger_drows_teachings:GetIntrinsicModifierName()
	return "modifier_ranged_drows_teachings_handler"
end

function drow_ranger_drows_teachings:OnSpellStart()
	local caster = self:GetCaster()
	caster:AddNewModifier(caster, self, "modifier_ranged_drows_teachings_active", {duration = self:GetSpecialValueFor("active_duration")})
end

modifier_ranged_drows_teachings_handler = class({})
LinkLuaModifier("modifier_ranged_drows_teachings_handler", "heroes/hero_drow_ranger/drow_ranger_drows_teachings", LUA_MODIFIER_MOTION_NONE)

function modifier_ranged_drows_teachings_handler:IsHidden()
	return true
end

function modifier_ranged_drows_teachings_handler:IsAura()
	return true
end

function modifier_ranged_drows_teachings_handler:GetModifierAura()
	return "modifier_ranged_drows_teachings_aura"
end

function modifier_ranged_drows_teachings_handler:GetAuraRadius()
	return -1
end

function modifier_ranged_drows_teachings_handler:GetAuraDuration()
	return 0.5
end

function modifier_ranged_drows_teachings_handler:GetAuraSearchTeam()    
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_ranged_drows_teachings_handler:GetAuraSearchType()
	local flags = DOTA_UNIT_TARGET_HERO
	if self:GetCaster():HasModifier("modifier_ranged_drows_teachings_active") then flags = DOTA_UNIT_TARGET_ALL end
	return flags
end

modifier_ranged_drows_teachings_aura = class({})
LinkLuaModifier("modifier_ranged_drows_teachings_aura", "heroes/hero_drow_ranger/drow_ranger_drows_teachings", LUA_MODIFIER_MOTION_NONE)

function modifier_ranged_drows_teachings_aura:OnCreated()
	local damage = self:GetSpecialValueFor("trueshot_melee_damage")
	if self:GetParent():IsRangedAttacker() then damage = self:GetSpecialValueFor("trueshot_ranged_damage") end
	self.damage = self:GetCaster():GetAgility() * damage / 100
	self:StartIntervalThink(0.33)
end
function modifier_ranged_drows_teachings_aura:OnIntervalThink()
	local damage = self:GetSpecialValueFor("trueshot_melee_damage")
	if self:GetParent():IsRangedAttacker() then damage = self:GetSpecialValueFor("trueshot_ranged_damage") end
	self.damage = self:GetCaster():GetAgility() * damage / 100
end

function modifier_ranged_drows_teachings_aura:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE}
end

function modifier_ranged_drows_teachings_aura:GetModifierPreAttack_BonusDamage()
	return self.damage
end

modifier_ranged_drows_teachings_active = class({})
LinkLuaModifier("modifier_ranged_drows_teachings_active", "heroes/hero_drow_ranger/drow_ranger_drows_teachings", LUA_MODIFIER_MOTION_NONE)