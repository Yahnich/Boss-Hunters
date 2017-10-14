justicar_shining_light = class({})

function justicar_shining_light:OnSpellStart()
	local caster = self:GetCaster()
	local cursorTarget = self:GetCursorTarget()
	
	EmitSoundOn("Hero_Omniknight.Purification", cursorTarget)
	
	if caster:HasTalent("justicar_shining_light_talent_1") then
		local radius = caster:FindTalentValue("justicar_shining_light_talent_1")
		local targets = caster:FindEnemyUnitsInRadius(cursorTarget:GetAbsOrigin(), radius, {team = DOTA_UNIT_TARGET_TEAM_BOTH})
		for _, target in pairs(targets) do
			self:AllyEnemyActions(target, damageheal)
		end
	else
		self:AllyEnemyActions(cursorTarget, damageheal)
	end
end

function justicar_shining_light:AllyEnemyActions(target)
	local caster = self:GetCaster()
	
	local damageheal = self:GetTalentSpecialValueFor("damageheal")
	damageheal = damageheal + caster:GetInnerSun()
	caster:ResetInnerSun()
	
	local baseheal = self:GetTalentSpecialValueFor("baseheal") / 100
	
	local cast = ParticleManager:CreateParticle("particles/econ/items/omniknight/hammer_ti6_immortal/omniknight_purification_immortal_cast.vpcf", PATTACH_POINT_FOLLOW, caster)
	ParticleManager:SetParticleControl(cast, 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(cast, 1, target:GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(cast)
	
	local targetAOE = ParticleManager:CreateParticle("particles/units/heroes/hero_omniknight/omniknight_purification.vpcf", PATTACH_POINT_FOLLOW, target)
	ParticleManager:SetParticleControl(targetAOE, 0, target:GetAbsOrigin())
	ParticleManager:SetParticleControl(targetAOE, 1, Vector(target:GetHullRadius(), target:GetHullRadius() * 2, target:GetHullRadius() * 2 ))
	ParticleManager:SetParticleControl(targetAOE, 2, target:GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(targetAOE)
	if target:GetTeam() == self:GetCaster():GetTeam() then
		target:Dispel(caster, true)
		target:HealEvent(damageheal + target:GetMaxHealth() * baseheal, self, self:GetCaster())
	else
		target:AddNewModifier(caster, self, "modifier_justicar_shining_light_debuff", {duration = self:GetTalentSpecialValueFor("debuff_duration")})
		self:DealDamage(caster, target, damageheal)
	end
end

modifier_justicar_shining_light_debuff = class({})
LinkLuaModifier("modifier_justicar_shining_light_debuff", "heroes/justicar/justicar_shining_light.lua", 0)


function modifier_justicar_shining_light_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_DISABLE_HEALING,
	}
	return funcs
end

function modifier_justicar_shining_light_debuff:GetDisableHealing()
	return 1
end