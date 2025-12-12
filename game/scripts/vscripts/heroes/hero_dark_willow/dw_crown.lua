 dw_crown = class({})
LinkLuaModifier("modifier_dw_crown", "heroes/hero_dark_willow/dw_crown", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_dw_crown_damage", "heroes/hero_dark_willow/dw_crown", LUA_MODIFIER_MOTION_NONE)

function dw_crown:IsStealable()
    return true
end

function dw_crown:IsHiddenWhenStolen()
    return false
end

function dw_crown:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	
	EmitSoundOn("Hero_DarkWillow.Ley.Cast", caster)
	EmitSoundOn("Hero_DarkWillow.Ley.Target", caster)
	if target:TriggerSpellAbsorb(self) then return end
	local delay = self:GetSpecialValueFor("delay")

	local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_dark_willow/dark_willow_ley_cast.vpcf", PATTACH_POINT, caster)
				ParticleManager:SetParticleControlEnt(nfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin(), true)
				ParticleManager:SetParticleControlEnt(nfx, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
				ParticleManager:ReleaseParticleIndex(nfx)

	target:AddNewModifier(caster, self, "modifier_dw_crown", {Duration = delay})

	self:StartDelayedCooldown(delay + self:GetSpecialValueFor("duration"))
end

modifier_dw_crown = class({})
function modifier_dw_crown:OnCreated(table)
	if IsServer() then
		self:SetDuration(self:GetSpecialValueFor("delay"), true)

		self.radius = self:GetSpecialValueFor("radius")
		self.duration = self:GetSpecialValueFor("duration")

		self:StartIntervalThink(1)
	end
end

function modifier_dw_crown:OnIntervalThink()
	local caster = self:GetCaster()
	local point = self:GetParent():GetAbsOrigin()

	EmitSoundOn("Hero_DarkWillow.Ley.Count", self:GetParent())

	local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_dark_willow/dark_willow_leyconduit_marker_helper.vpcf", PATTACH_POINT, caster)
				ParticleManager:SetParticleControl(nfx, 0, point)
				ParticleManager:SetParticleControl(nfx, 1, Vector(self.radius, self.radius, self.radius))
				ParticleManager:ReleaseParticleIndex(nfx)

	if caster:HasTalent("special_bonus_unique_dw_crown_2") then
		local enemies = caster:FindEnemyUnitsInRadius(point, self.radius*2)
		for _,enemy in pairs(enemies) do
			if enemy ~= self:GetParent() and not enemy:TriggerSpellAbsorb(self) then
				enemy:Charm(self:GetAbility(), self:GetParent(), 1)
			end
		end
	end
end

function modifier_dw_crown:GetEffectName()
	return "particles/units/heroes/hero_dark_willow/dark_willow_leyconduit_start.vpcf"
end

function modifier_dw_crown:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_dw_crown:OnRemoved()
	if IsServer() then
		local caster = self:GetCaster()
		local point = self:GetParent():GetAbsOrigin()

		local damage = 0

		EmitSoundOn("Hero_DarkWillow.Ley.Stun", self:GetParent())

		if caster:HasTalent("special_bonus_unique_dw_crown_1") then
			damage = caster:GetIntellect( false)
		end

		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_dark_willow/dark_willow_leyconduit_marker.vpcf", PATTACH_POINT, caster)
					ParticleManager:SetParticleControlEnt(nfx, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
					ParticleManager:SetParticleControl(nfx, 2, Vector(self.radius, self.radius, self.radius))
					--ParticleManager:SetParticleControlEnt(nfx, 4, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
					ParticleManager:ReleaseParticleIndex(nfx)

		local enemies = caster:FindEnemyUnitsInRadius(point, self.radius)
		for _,enemy in pairs(enemies) do
			if not enemy:TriggerSpellAbsorb(self) then
				self:GetAbility():Stun(enemy, self.duration, false)
				self:GetAbility():DealDamage(caster, enemy, damage, {}, OVERHEAD_ALERT_BONUS_POISON_DAMAGE)
			end
		end
	end
end

function modifier_dw_crown:DeclareFunctions()
	return { MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING }
end

function modifier_dw_crown:GetModifierStatusResistanceStacking()
	return self.status_resist
end

function modifier_dw_crown:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_dw_crown:IsDebuff()
	return true
end

function modifier_dw_crown:IsPurgable()
	return false
end

function modifier_dw_crown:IsPurgeException()
	return false
end