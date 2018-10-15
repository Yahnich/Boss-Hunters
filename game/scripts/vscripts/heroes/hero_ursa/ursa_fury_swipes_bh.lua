ursa_fury_swipes_bh = class({})
LinkLuaModifier("modifier_ursa_fury_swipes_bh_handle", "heroes/hero_ursa/ursa_fury_swipes_bh", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ursa_fury_swipes_bh", "heroes/hero_ursa/ursa_fury_swipes_bh", LUA_MODIFIER_MOTION_NONE)

function ursa_fury_swipes_bh:IsStealable()
	return false
end

function ursa_fury_swipes_bh:IsHiddenWhenStolen()
	return false
end

function ursa_fury_swipes_bh:GetIntrinsicModifierName()
	return "modifier_ursa_fury_swipes_bh_handle"
end

modifier_ursa_fury_swipes_bh_handle = class({})
function modifier_ursa_fury_swipes_bh_handle:DeclareFunctions()
	return {MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL}
end

function modifier_ursa_fury_swipes_bh_handle:GetModifierProcAttack_BonusDamage_Physical(params)
	if IsServer() then
		local caster = self:GetCaster()
		local target = params.target
		local ability = self:GetAbility()
		local swipes_particle = "particles/units/heroes/hero_ursa/ursa_fury_swipes.vpcf"
		local fury_swipes_debuff = "modifier_ursa_fury_swipes_bh"
		local enrageAbility = caster:FindAbilityByName("ursa_enrage_bh")
		local enrageMultiplier = enrageAbility:GetTalentSpecialValueFor("fury_multiplier")

		-- Ability specials
		local damage_per_stack = self:GetTalentSpecialValueFor("bonus_ad") * caster:GetLevel()
		local stack_duration = self:GetTalentSpecialValueFor("duration")

		-- If the caster is broken, do nothing
		if caster:PassivesDisabled() then
			return nil
		end

		if params.attacker == caster then
			-- Initialize variables
			local fury_swipes_debuff_handler
			local damage
			-- Add debuff/increment stacks if already exists
			if target:HasModifier(fury_swipes_debuff) then
				fury_swipes_debuff_handler = target:FindModifierByName(fury_swipes_debuff)
				fury_swipes_debuff_handler:IncrementStackCount()
			else
				target:AddNewModifier(caster, ability, fury_swipes_debuff, {duration = stack_duration})
				fury_swipes_debuff_handler = target:FindModifierByName(fury_swipes_debuff)
				fury_swipes_debuff_handler:IncrementStackCount()
			end

			-- Refresh stack duration
			fury_swipes_debuff_handler:ForceRefresh()

			-- Add fury swipe impact particle
			local swipes_particle_fx = ParticleManager:CreateParticle(swipes_particle, PATTACH_ABSORIGIN, target)
			ParticleManager:SetParticleControl(swipes_particle_fx, 0, target:GetAbsOrigin())
			ParticleManager:ReleaseParticleIndex(swipes_particle_fx)

			-- Get stack count
			local fury_swipes_stacks = fury_swipes_debuff_handler:GetStackCount()

			-- Calculate damage
			damage = damage_per_stack * fury_swipes_stacks

			-- Check for Enrage's multiplier
			if caster:HasModifier("modifier_ursa_enrage_bh") then
				damage = damage * enrageMultiplier
			end

			return damage
		end
	end
end

function modifier_ursa_fury_swipes_bh_handle:IsHidden()
	return true
end

modifier_ursa_fury_swipes_bh = class({})

function modifier_ursa_fury_swipes_bh:OnCreated(table)
	local caster = self:GetCaster()
	self.damage = self:GetTalentSpecialValueFor("bonus_ad") * caster:GetLevel() * self:GetStackCount()
end

function modifier_ursa_fury_swipes_bh:OnRefresh(table)
	local caster = self:GetCaster()
	self.damage = self:GetTalentSpecialValueFor("bonus_ad") * caster:GetLevel() * self:GetStackCount()
end

function modifier_ursa_fury_swipes_bh:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOOLTIP }
end

function modifier_ursa_fury_swipes_bh:OnTooltip()
	return self.damage
end

function modifier_ursa_fury_swipes_bh:GetEffectName()
	return "particles/units/heroes/hero_ursa/ursa_fury_swipes_debuff.vpcf"
end

function modifier_ursa_fury_swipes_bh:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_ursa_fury_swipes_bh:IsDebuff()
	return true
end

function modifier_ursa_fury_swipes_bh:IsHidden()
	return false
end

function modifier_ursa_fury_swipes_bh:IsPurgable()
	return false
end