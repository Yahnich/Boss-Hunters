forest_overgrowth = class({})

function forest_overgrowth:OnSpellStart()
	local caster = self:GetCaster()
	caster:AddNewModifier(caster, self, "modifier_forest_overgrowth_buff", {duration = self:GetSpecialValueFor("duration")})
	Timers:CreateTimer(function() caster:HealEvent(self:GetSpecialValueFor("bonus_max_hp"), self, caster) end)
	if caster:HasTalent("forest_overgrowth_talent_1") then
		local allies = caster:FindFriendlyUnitsInRadius(caster:GetAbsOrigin(), 900)
		for _, ally in pairs( allies ) do
			ally:AddNewModifier(caster, self, "modifier_forest_overgrowth_talent", {duration = self:GetSpecialValueFor("duration")})
		end
	end
	ParticleManager:FireParticle("particles/units/heroes/hero_treant/treant_overgrowth_cast.vpcf", PATTACH_POINT_FOLLOW, caster)
	EmitSoundOn("Hero_Treant.Overgrowth.Cast", caster)
end

modifier_forest_overgrowth_buff = class({})
LinkLuaModifier("modifier_forest_overgrowth_buff", "heroes/forest/forest_overgrowth.lua", 0)

function modifier_forest_overgrowth_buff:OnCreated()
	self.maxHP = self:GetSpecialValueFor("bonus_max_hp")
	self.duration = self:GetSpecialValueFor("root_duration")
	self.radius = self:GetSpecialValueFor("root_radius")
	if IsServer() then 
		EmitSoundOn("Hero_Treant.Overgrowth.CastAnim", caster)
		self:GetAbility():StartDelayedCooldown() 
	end
end

function modifier_forest_overgrowth_buff:OnDestroy()
	if IsServer() then self:GetAbility():EndDelayedCooldown() end
end

function modifier_forest_overgrowth_buff:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ABILITY_FULLY_CAST, MODIFIER_PROPERTY_MODEL_SCALE, MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS}
end

function modifier_forest_overgrowth_buff:GetModifierModelScale()
	return 100
end

function modifier_forest_overgrowth_buff:GetModifierExtraHealthBonus()
	return self.maxHP
end

function modifier_forest_overgrowth_buff:OnAbilityFullyCast(params)
	if params.unit == self:GetParent() then
		local caster = self:GetParent()
		local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), self.radius)
		for _, enemy in pairs( enemies ) do
			enemy:AddNewModifier(caster, self, "modifier_forest_overgrowth_root", {duration = self.duration})
			local rootFX = ParticleManager:CreateParticle("particles/units/heroes/hero_treant/treant_leech_seed_afromhand.vpcf", PATTACH_ABSORIGIN, caster)
			ParticleManager:SetParticleControl(rootFX, 0, caster:GetAbsOrigin())
			ParticleManager:SetParticleControl(rootFX, 1, enemy:GetAbsOrigin())
			local trailFX = ParticleManager:CreateParticle("particles/units/heroes/hero_treant/treant_overgrowth_trails.vpcf", PATTACH_ABSORIGIN, caster)
			ParticleManager:SetParticleControl(trailFX, 0, caster:GetAbsOrigin())
			ParticleManager:SetParticleControl(trailFX, 1, enemy:GetAbsOrigin())
			
			ParticleManager:ReleaseParticleIndex(rootFX)
			ParticleManager:ReleaseParticleIndex(trailFX)
		end
	end
end

modifier_forest_overgrowth_talent = class({})
LinkLuaModifier("modifier_forest_overgrowth_talent", "heroes/forest/forest_overgrowth.lua", 0)

function modifier_forest_overgrowth_talent:OnCreated()
	self.heal = self:GetSpecialValueFor("talent_heal") / self:GetDuration()
end

function modifier_forest_overgrowth_talent:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE}
end

function modifier_forest_overgrowth_talent:GetModifierHealthRegenPercentage()
	return self.heal
end

function modifier_forest_overgrowth_talent:GetEffectName()
	return "particles/items_fx/healing_tango.vpcf"
end

modifier_forest_overgrowth_root = class({})
LinkLuaModifier("modifier_forest_overgrowth_root", "heroes/forest/forest_overgrowth.lua", 0)

function modifier_forest_overgrowth_root:DeclareFunctions()
	return {[MODIFIER_STATE_ROOTED] = true}
end

function modifier_forest_overgrowth_root:GetEffectName()
	return "particles/units/heroes/hero_treant/treant_overgrowth_vines.vpcf"
end