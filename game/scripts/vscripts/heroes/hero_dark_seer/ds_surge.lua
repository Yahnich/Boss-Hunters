ds_surge = class({})
LinkLuaModifier( "modifier_ds_surge", "heroes/hero_dark_seer/ds_surge.lua" ,LUA_MODIFIER_MOTION_NONE )

function ds_surge:IsStealable()
    return true
end

function ds_surge:IsHiddenWhenStolen()
    return false
end

function ds_surge:GetBehavior()
    if self:GetCaster():HasTalent("special_bonus_unique_ds_surge_1") then
    	return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_AOE + DOTA_ABILITY_BEHAVIOR_DONT_RESUME_ATTACK
    end
    return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_DONT_RESUME_ATTACK
end

function ds_surge:GetAOERadius()
    if self:GetCaster():HasTalent("special_bonus_unique_ds_surge_1") then
    	return 400
    end
    return 0
end

function ds_surge:OnSpellStart()
	local caster = self:GetCaster()

	local duration = self:GetTalentSpecialValueFor("duration")

	if caster:HasTalent("special_bonus_unique_ds_surge_1") then
		local point = self:GetCursorPosition()

		local allies = caster:FindFriendlyUnitsInRadius(point, 400)
		for _,ally in pairs(allies) do
			EmitSoundOn("Hero_Dark_Seer.Surge", ally)
			ally:AddNewModifier(caster, self, "modifier_ds_surge", {Duration = duration})
		end
	else
		local target = self:GetCursorTarget()
		EmitSoundOn("Hero_Dark_Seer.Surge", target)
		target:AddNewModifier(caster, self, "modifier_ds_surge", {Duration = duration})
	end

	self:StartDelayedCooldown()
end

modifier_ds_surge = class({})
function modifier_ds_surge:OnCreated(table)
	local caster = self:GetCaster()

	self.bonusMs = self:GetTalentSpecialValueFor("bonus_ms")
	if caster:HasTalent("special_bonus_unique_ds_surge_2") then
		self.bonus_as = self.bonusMs
	end

	if IsServer() then
		local parent = self:GetParent()
		parent:Purge(false, true, false, true, false)
		ProjectileManager:ProjectileDodge(parent)

		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_dark_seer/dark_seer_surge.vpcf", PATTACH_POINT, caster)
					ParticleManager:SetParticleControlEnt(nfx, 0, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
					ParticleManager:SetParticleControlEnt(nfx, 1, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
		self:AttachEffect(nfx)
	end
end

function modifier_ds_surge:OnRefresh(table)
	local caster = self:GetCaster()

	self.bonusMs = self:GetTalentSpecialValueFor("bonus_ms")
	if caster:HasTalent("special_bonus_unique_ds_surge_2") then
		self.bonus_as = self.bonusMs
	end

	if IsServer() then
		local parent = self:GetParent()
		parent:Purge(false, true, false, true, false)
		ProjectileManager:ProjectileDodge(parent)
	end
end

function modifier_ds_surge:OnRemoved()
	if IsServer() then
		self:GetAbility():EndDelayedCooldown()
	end
end

function modifier_ds_surge:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        	}
end

function modifier_ds_surge:CheckState()
	return {[MODIFIER_STATE_UNSLOWABLE] = true}
end

function modifier_ds_surge:GetModifierAttackSpeedBonus()
	return self.bonus_as
end

function modifier_ds_surge:GetModifierMoveSpeedBonus_Percentage()
	return self.bonusMs
end

function modifier_ds_surge:GetMoveSpeedLimitBonus( params )
    return 999999
end

function modifier_ds_surge:IsDebuff()
	return false
end
