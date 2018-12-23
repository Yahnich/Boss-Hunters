ss_electric_vortex = class({})
LinkLuaModifier("modifier_ss_electric_vortex", "heroes/hero_storm_spirit/ss_electric_vortex", LUA_MODIFIER_MOTION_NONE)

function ss_electric_vortex:IsStealable()
    return true
end

function ss_electric_vortex:IsHiddenWhenStolen()
    return false
end

function ss_electric_vortex:GetBehavior()
    if self:GetCaster():HasTalent("special_bonus_unique_ss_electric_vortex_2") then
    	return DOTA_ABILITY_BEHAVIOR_NO_TARGET
    end
    return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
end

function ss_electric_vortex:GetCastRange(vLocation, hTarget)
    return self:GetTalentSpecialValueFor("cast_range")
end

function ss_electric_vortex:OnSpellStart()
	local caster = self:GetCaster()

	local duration = self:GetTalentSpecialValueFor("duration")

	EmitSoundOn("Hero_StormSpirit.ElectricVortexCast", caster)

	if caster:HasTalent("special_bonus_unique_ss_electric_vortex_2") then
		EmitSoundOn("Hero_StormSpirit.ElectricVortex", caster)
		
		local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), self:GetTrueCastRange())
		for _,enemy in pairs(enemies) do
			enemy:AddNewModifier(caster, self, "modifier_ss_electric_vortex", {Duration = duration})
		end
	else
		local target = self:GetCursorTarget()

		EmitSoundOn("Hero_StormSpirit.ElectricVortex", target)

		target:AddNewModifier(caster, self, "modifier_ss_electric_vortex", {Duration = duration})
	end

	self:StartDelayedCooldown(duration)
end

modifier_ss_electric_vortex = class({})
function modifier_ss_electric_vortex:OnCreated(table)
	if IsServer() then
		self.caster = self:GetCaster()
		self.point = self.caster:GetAbsOrigin()
		self.parent = self:GetParent()

		self:SetDuration(self:GetTalentSpecialValueFor("duration"), true)

		self.speed = 100 * FrameTime()

		self.damage = self.caster:GetIntellect() * FrameTime()

		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_stormspirit/stormspirit_electric_vortex.vpcf", PATTACH_POINT, self.caster)
					ParticleManager:SetParticleControl(nfx, 0, self.point)
					ParticleManager:SetParticleControlEnt(nfx, 1, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true)

		self:AttachEffect(nfx)

		self:StartIntervalThink(FrameTime())
	end
end

function modifier_ss_electric_vortex:OnIntervalThink()
	local parentPoint = self.parent:GetAbsOrigin()
	local direction = CalculateDirection(self.point, parentPoint)
	local distance = CalculateDistance(self.point, parentPoint)
	if distance > self.speed then
		self.parent:SetAbsOrigin(GetGroundPosition(parentPoint, self.parent) + direction * self.speed)
	end

	if self.caster:HasTalent("special_bonus_unique_ss_electric_vortex_1") then
		self:GetAbility():DealDamage(self.caster, self.parent, self.damage, {damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION})
	end
end

function modifier_ss_electric_vortex:OnRemoved()
	if IsServer() then
		FindClearSpaceForUnit(self.parent, self.parent:GetAbsOrigin(), true)
		self:GetAbility():EndDelayedCooldown()
	end
end

function modifier_ss_electric_vortex:CheckState()
	return {[MODIFIER_STATE_STUNNED] = true}
end

function modifier_ss_electric_vortex:IsDebuff()
	return true
end

function modifier_ss_electric_vortex:IsPurgable()
	return true
end