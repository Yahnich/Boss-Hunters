bs_bloodrage = class({})
LinkLuaModifier("modifier_bs_bloodrage", "heroes/hero_bloodseeker/bs_bloodrage", LUA_MODIFIER_MOTION_NONE)

function bs_bloodrage:IsStealable()
	return true
end

function bs_bloodrage:IsHiddenWhenStolen()
	return false
end

function bs_bloodrage:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	EmitSoundOn("hero_bloodseeker.bloodRage", target)

	if caster:HasTalent("special_bonus_unique_bs_bloodrage_1") then
		caster:AddNewModifier(caster, self, "modifier_bs_bloodrage", {Duration = self:GetTalentSpecialValueFor("duration")})
	end

	target:AddNewModifier(caster, self, "modifier_bs_bloodrage", {Duration = self:GetTalentSpecialValueFor("duration")})
end

modifier_bs_bloodrage = class({})
function modifier_bs_bloodrage:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
		MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_EVENT_ON_DEATH
	}
	return funcs
end

function modifier_bs_bloodrage:GetModifierIncomingDamage_Percentage()
	return self:GetTalentSpecialValueFor("amp")
end

function modifier_bs_bloodrage:GetModifierTotalDamageOutgoing_Percentage()
	return self:GetTalentSpecialValueFor("amp")
end

function modifier_bs_bloodrage:OnDeath(params)
	if IsServer() then
		if params.unit == self:GetParent() then
			local enemies = self:GetParent():FindEnemyUnitsInRadius(self:GetParent():GetAbsOrigin(), self:GetTalentSpecialValueFor("heal_radius"))
			for _,enemy in pairs(enemies) do
				local heal = enemy:GetMaxHealth() * self:GetTalentSpecialValueFor("max_heal")/100
				enemy:HealEvent(heal, self:GetAbility(), enemy, false)
			end

		elseif params.attacker == self:GetParent() then
			local heal = params.unit:GetMaxHealth() * self:GetTalentSpecialValueFor("max_heal")/100
			self:GetParent():HealEvent(heal, self:GetAbility(), self:GetParent(), false)
			
		end
	end
end

function modifier_bs_bloodrage:GetEffectName()
	return "particles/units/heroes/hero_bloodseeker/bloodseeker_bloodrage.vpcf"
end

function modifier_bs_bloodrage:GetStatusEffectName()
	return "particles/status_fx/status_effect_bloodrage.vpcf"
end

function modifier_bs_bloodrage:StatusEffectPriority()
	return 10
end

function modifier_bs_bloodrage:IsDebuff()
	return true
end