wisp_transfer = class({})
LinkLuaModifier("modifier_wisp_transfer", "heroes/hero_wisp/wisp_transfer", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_wisp_transfer_target", "heroes/hero_wisp/wisp_transfer", LUA_MODIFIER_MOTION_NONE)

function wisp_transfer:IsStealable()
    return false
end

function wisp_transfer:IsHiddenWhenStolen()
    return false
end

function wisp_transfer:CastFilterResultTarget(hTarget)
	if self:GetCaster():PassivesDisabled() then
		return UF_FAIL_CUSTOM
	elseif hTarget:GetTeamNumber() == self:GetCaster():GetTeamNumber() then
		return UF_FAIL_FRIENDLY
	end
end

function wisp_transfer:GetCustomCastErrorTarget(hTarget)
	if self:GetCaster():PassivesDisabled() then
		return "Innate is currently broken."
	end
end

function wisp_transfer:GetAbilityTextureName()
    if self:GetCaster():HasModifier("modifier_wisp_transfer") then
    	return "custom/wisp_evil_tether_break"
    end
    return "custom/wisp_evil_tether"
end

function wisp_transfer:GetBehavior()
    if self:GetCaster():HasModifier("modifier_wisp_transfer") then
    	return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
    end
    return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
end

function wisp_transfer:OnSpellStart()
	local caster = self:GetCaster()
	
	if caster:HasModifier("modifier_wisp_transfer") then
		caster:RemoveModifierByName("modifier_wisp_transfer")
		self:RefundManaCost()
	else
		local target = self:GetCursorTarget()

		EmitSoundOn("Hero_Wisp.Tether.Target", target)

		caster:AddNewModifier(caster, self, "modifier_wisp_transfer", {})
		target:AddNewModifier(caster, self, "modifier_wisp_transfer_target", {})
		self:EndCooldown()
	end
end

modifier_wisp_transfer = class({})

function modifier_wisp_transfer:OnCreated(table)
	if IsServer() then
		local parent = self:GetCaster()
		self.target = self:GetAbility():GetCursorTarget()

		self.restoreMultiplier = self:GetTalentSpecialValueFor("restore_amp")/100

		EmitSoundOn("Hero_Wisp.Tether", caster)

<<<<<<< HEAD
		local nfx = ParticleManager:CreateParticle("particles/wisp_eviltether.vpcf", PATTACH_POINT, parent)
=======
		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_wisp/wisp_evil_tether.vpcf", PATTACH_POINT, parent)
>>>>>>> 4359de20b3a163f67394a2f7c5338c27f7fa8374
					ParticleManager:SetParticleControlEnt(nfx, 1, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
					ParticleManager:SetParticleControlEnt(nfx, 0, self.target, PATTACH_POINT_FOLLOW, "attach_hitloc", self.target:GetAbsOrigin(), true)

		self:AttachEffect(nfx)

		self.drain = self.target:GetMaxHealth() * self:GetTalentSpecialValueFor("health_drain")/100 * 0.1

		self:StartIntervalThink(0.1)
	end
end

function modifier_wisp_transfer:OnIntervalThink()
	local distance = CalculateDistance(self.target, self:GetCaster())
	local range = self:GetAbility():GetTrueCastRange()
	
	if self.target and self.target:IsAlive() and self.target:HasModifier("modifier_wisp_transfer_target") and distance <= range and not self:GetCaster():PassivesDisabled() then
		self:GetAbility():DealDamage(self:GetCaster(), self.target, self.drain, {damage_flags = DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION}, 0)
		self:GetCaster():HealEvent(self.drain, self:GetAbility(), self:GetCaster(), false)

	else
		self:Destroy()
	end
end

function modifier_wisp_transfer:OnRemoved()
	if IsServer() then
		local parent = self:GetParent()
		
		StopSoundOn("Hero_Wisp.Tether", parent)
		EmitSoundOn("Hero_Wisp.Tether.Stop", parent)

		if self.target and self.target:IsAlive() then
			self.target:RemoveModifierByNameAndCaster("modifier_wisp_transfer_target", self:GetCaster())
		end
	end
end

function modifier_wisp_transfer:IsDebuff()
	return false
end

function modifier_wisp_transfer:IsPurgable()
	return false
end

function modifier_wisp_transfer:IsPurgeException()
	return false
end

function modifier_wisp_transfer:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

modifier_wisp_transfer_target = class({})
function modifier_wisp_transfer_target:IsDebuff()
	return true
end

function modifier_wisp_transfer_target:IsPurgable()
	return false
end

function modifier_wisp_transfer_target:IsPurgeException()
	return false
end