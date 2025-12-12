ss_electric_vortex = class({})

function ss_electric_vortex:IsStealable()
    return true
end

function ss_electric_vortex:IsHiddenWhenStolen()
    return false
end

function ss_electric_vortex:GetBehavior()
    return DOTA_ABILITY_BEHAVIOR_NO_TARGET
end

function ss_electric_vortex:GetCastRange(vLocation, hTarget)
    return self:GetSpecialValueFor("cast_range")
end

function ss_electric_vortex:OnSpellStart()
	local caster = self:GetCaster()

	local duration = self:GetSpecialValueFor("duration")

	EmitSoundOn("Hero_StormSpirit.ElectricVortexCast", caster)

	EmitSoundOn("Hero_StormSpirit.ElectricVortex", caster)
	
	local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), self:GetTrueCastRange())
	for _,enemy in pairs(enemies) do	
		if not enemy:TriggerSpellAbsorb( self ) then
			enemy:AddNewModifier(caster, self, "modifier_ss_electric_vortex", {Duration = duration})
		end
	end
	if caster:HasTalent("special_bonus_unique_ss_electric_vortex_2") then
		caster:AddNewModifier(caster, self, "modifier_ss_electric_vortex_talent", {})
	end
end

modifier_ss_electric_vortex_talent = class({})
LinkLuaModifier("modifier_ss_electric_vortex_talent", "heroes/hero_storm_spirit/ss_electric_vortex", LUA_MODIFIER_MOTION_NONE)

function modifier_ss_electric_vortex_talent:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ABILITY_EXECUTED, MODIFIER_PROPERTY_MANACOST_PERCENTAGE }
end

function modifier_ss_electric_vortex_talent:OnAbilityExecuted(params)
	if params.unit == self:GetParent() then
		self:Destroy()
	end
end

function modifier_ss_electric_vortex_talent:GetModifierPercentageManacost()
	return 999
end

modifier_ss_electric_vortex = class({})
LinkLuaModifier("modifier_ss_electric_vortex", "heroes/hero_storm_spirit/ss_electric_vortex", LUA_MODIFIER_MOTION_NONE)
function modifier_ss_electric_vortex:OnCreated(table)
	if IsServer() then
		self.caster = self:GetCaster()
		self.point = self.caster:GetAbsOrigin()
		self.parent = self:GetParent()

		self.speed = self:GetSpecialValueFor("cast_range") / self:GetDuration() * FrameTime()

		self.talent1 = self.caster:HasTalent("special_bonus_unique_ss_electric_vortex_1")
		self.damage = self.caster:GetLevel()*self.caster:FindTalentValue("special_bonus_unique_ss_electric_vortex_1") * FrameTime()
		
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

	if self.talent1 then
		self:GetAbility():DealDamage(self.caster, self.parent, self.damage )
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