sd_soul_catcher = class({})
LinkLuaModifier("modifier_sd_soul_catcher", "heroes/hero_shadow_demon/sd_soul_catcher", LUA_MODIFIER_MOTION_NONE)

function sd_soul_catcher:IsStealable()
	return true
end

function sd_soul_catcher:IsHiddenWhenStolen()
	return false
end

function sd_soul_catcher:GetCooldown(iLvl)
    local cooldown = self.BaseClass.GetCooldown(self, iLvl)
    if self:GetCaster():HasTalent("special_bonus_unique_sd_soul_catcher_1") then cooldown = cooldown + self:GetCaster():FindTalentValue("special_bonus_unique_sd_soul_catcher_1") end
    return cooldown
end

function sd_soul_catcher:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end

function sd_soul_catcher:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
	local target = point

	EmitSoundOn("Hero_ShadowDemon.Soul_Catcher.Cast", caster)

	local enemies = caster:FindEnemyUnitsInRadius(point, self:GetSpecialValueFor("radius"))
	for _,enemy in pairs(enemies) do
		if enemy:TriggerSpellAbsorb( self ) then
			enemy:AddNewModifier(caster, self, "modifier_sd_soul_catcher", {Duration = self:GetSpecialValueFor("duration")})
		end
		EmitSoundOn("Hero_ShadowDemon.Soul_Catcher", enemy)
		target = enemy:GetAbsOrigin()
		break
	end

	local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_shadow_demon/shadow_demon_soul_catcher.vpcf", PATTACH_POINT, caster)
				ParticleManager:SetParticleControl(nfx, 0, point)
				ParticleManager:SetParticleControl(nfx, 1, target)
				ParticleManager:SetParticleControl(nfx, 2, point)
				ParticleManager:SetParticleControl(nfx, 3, Vector(self:GetSpecialValueFor("radius"), 0, 0))
				ParticleManager:SetParticleControl(nfx, 4, point)
				ParticleManager:ReleaseParticleIndex(nfx)

end

modifier_sd_soul_catcher = class({})
function modifier_sd_soul_catcher:OnCreated(table)
	if IsServer() then
		local caster = self:GetCaster()
		local parent = self:GetParent()

		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_shadow_demon/shadow_demon_soul_catcher_debuff.vpcf", PATTACH_POINT, caster)
					ParticleManager:SetParticleControlEnt(nfx, 0, parent, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
		self:AttachEffect(nfx)
	end
end

function modifier_sd_soul_catcher:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
		MODIFIER_EVENT_ON_DEATH
	}
	return funcs
end

function modifier_sd_soul_catcher:OnDeath(params)
	if IsServer() then
		local caster = self:GetCaster()
		if caster:HasTalent("special_bonus_unique_sd_soul_catcher_2") and params.unit == self:GetParent() and params.unit:HasModifier("modifier_sd_soul_catcher") then
			caster:ConjureImage( params.unit:GetAbsOrigin(), 5, 75, 200, nil, self:GetAbility(), false, caster )
		end
	end
end

function modifier_sd_soul_catcher:GetModifierIncomingDamage_Percentage()
	return self:GetSpecialValueFor("amp")
end

function modifier_sd_soul_catcher:IsDebuff()
	return true
end