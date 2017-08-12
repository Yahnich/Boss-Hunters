guardian_stone_fortress = class({})

function guardian_stone_fortress:OnSpellStart()
	local caster = self:GetCaster()
	caster:Stop()
	caster:Hold()
	EmitSoundOn("Hero_EarthSpirit.Petrify", caster)
	caster:AddNewModifier(caster, self, "modifier_guardian_stone_fortress_buff", {duration = self:GetTalentSpecialValueFor("duration")})
end

LinkLuaModifier( "modifier_guardian_stone_fortress_buff", "heroes/guardian/guardian_stone_fortress.lua", LUA_MODIFIER_MOTION_NONE )
modifier_guardian_stone_fortress_buff = class({})

function modifier_guardian_stone_fortress_buff:OnCreated()
	if IsServer() then
		self:GetAbility():StartDelayedCooldown(self:GetRemainingTime(), false)
	end
end

function modifier_guardian_stone_fortress_buff:OnRefresh()
	if IsServer() then
		self:GetAbility():StartDelayedCooldown(self:GetRemainingTime(), false)
	end
end

function modifier_guardian_stone_fortress_buff:OnDestroy()
	if IsServer() then
		self:GetAbility():EndDelayedCooldown()
	end
end

function modifier_guardian_stone_fortress_buff:GetEffectName()
	return "particles/units/heroes/hero_earth_spirit/earthspirit_petrify_debuff_stoned.vpcf"
end

function modifier_guardian_stone_fortress_buff:GetStatusEffectName()
	return "particles/status_fx/status_effect_earth_spirit_petrify.vpcf"
end

function modifier_guardian_stone_fortress_buff:StatusEffectPriority()
	return 25
end

function modifier_guardian_stone_fortress_buff:DeclareFunctions()
	funcs = {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
		MODIFIER_EVENT_ON_ORDER
	}
	return funcs
end

function modifier_guardian_stone_fortress_buff:OnOrder()
	if params.unit == self:GetParent() then
		if self:GetParent():HasTalent("guardian_stone_fortress_talent_1") then
			if params.order > 2 then
				self:Destroy()
			end
		else
			self:Destroy()
		end
	end
end

function modifier_guardian_stone_fortress_buff:GetModifierIncomingDamage_Percentage()
	return -100
end

