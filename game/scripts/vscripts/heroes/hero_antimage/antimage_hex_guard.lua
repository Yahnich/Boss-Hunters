antimage_hex_guard = class ({})

function antimage_hex_guard:GetIntrinsicModifierName()
	return "modifier_antimage_hex_guard"
end

function antimage_hex_guard:GetBehavior()
	if self:GetCaster():HasTalent("special_bonus_unique_antimage_hex_guard_2") then
		return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
	else
		return DOTA_ABILITY_BEHAVIOR_PASSIVE
	end
end

function antimage_hex_guard:GetCooldown()
	return self:GetCaster():FindTalentValue("special_bonus_unique_antimage_hex_guard_2", "cooldown")
end

function antimage_hex_guard:OnSpellStart()
	local caster = self:GetCaster()
	caster:AddNewModifier( caster, self, "modifier_antimage_hex_guard_talent", {duration = caster:FindTalentValue("special_bonus_unique_antimage_hex_guard_2", "duration")})
end

modifier_antimage_hex_guard_talent = class({})
LinkLuaModifier( "modifier_antimage_hex_guard_talent", "heroes/hero_antimage/antimage_hex_guard", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
	function modifier_antimage_hex_guard_talent:OnCreated()
		self:GetAbility():StartDelayedCooldown()
		local hex = self:GetParent():FindModifierByName("modifier_antimage_hex_guard_talent")
		if hex then
			hex:ForceRefresh()
		end
	end
	
	function modifier_antimage_hex_guard_talent:OnDestroy()
		self:GetAbility():EndDelayedCooldown()
		local hex = self:GetParent():FindModifierByName("modifier_antimage_hex_guard_talent")
		if hex then
			hex:ForceRefresh()
		end
	end
	
	function modifier_antimage_hex_guard_talent:GetEffectName()
		return ""
	end
end

modifier_antimage_hex_guard = class({})
LinkLuaModifier( "modifier_antimage_hex_guard", "heroes/hero_antimage/antimage_hex_guard", LUA_MODIFIER_MOTION_NONE)

function modifier_antimage_hex_guard:OnCreated()
	self.mr = self:GetTalentSpecialValueFor("magic_resistance")
	self.sr = self:GetTalentSpecialValueFor("status_resistance")
end

function modifier_antimage_hex_guard:OnRefresh()
	self.mr = self:GetTalentSpecialValueFor("magic_resistance")
	self.sr = self:GetTalentSpecialValueFor("status_resistance")
	if self:GetParent():HasModifier("modifier_antimage_hex_guard_talent") then
		self.mr = self:GetCaster():FindTalentValue("special_bonus_unique_antimage_hex_guard_2")
		self.sr = self.mr
	end
end

function modifier_antimage_hex_guard:DeclareFunctions()
	return {MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS, MODIFIER_PROPERTY_STATUS_RESISTANCE_BONUS}
end

function modifier_antimage_hex_guard:GetModifierMagicalResistanceBonus(params)
	PrintAll(params)
	print(--------magic resist-------------)
	return self.mr
end

function modifier_antimage_hex_guard:GetModifierStatusResistance()
	return self.sr
end