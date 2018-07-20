undying_summon_zombies = class({})

function undying_summon_zombies:OnSpellStart()
	local caster = self:GetCaster()
	local taget = self:GetCursorTarget()
	target:AddNewModifier(caster, self, "modifier_undying_summon_zombies", {duration = self:GetSpecialValueFor("zombie_duration")})
end

modifier_undying_summon_zombies = class({})
LinkLuaModifier("modifier_undying_summon_zombies", "heroes/hero_undying/undying_summon_zombies", LUA_MODIFIER_MOTION_NONE)

function modifier_undying_summon_zombies:OnCreated()
	self.damage = self:GetSpecialValueFor("damage")
	self.heal = self:GetSpecialValueFor("heal_pct")
	self.slow = self:GetSpecialValueFor("movement_slow")
	self.turn = self:GetSpecialValueFor("turn_slow")
	if IsServer() then
		self:StartIntervalThink(1)
	end
end

function modifier_undying_summon_zombies:OnRefresh()
	self.damage = self:GetSpecialValueFor("damage")
	self.heal = self:GetSpecialValueFor("heal_pct")
	self.slow = self:GetSpecialValueFor("movement_slow")
	self.turn = self:GetSpecialValueFor("turn_slow")
end

function modifier_undying_summon_zombies:OnIntervalThink()
	local caster = self:GetCaster()
	local target = self:GetParent()
	local ability = self:GetAbility()
	
	caster:Lifesteal(ability, self.heal_pct, self.damage, target, ability:GetAbilityDamageType(), DOTA_LIFESTEAL_SOURCE_ABILITY)
	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_undying/undying_soul_rip_heal.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	EmitSoundOn("Hero_Bane.Enfeeble.Cast", caster)
	Timers:CreateTimer(0.5,function()
        StopSoundOn("Hero_Bane.Enfeeble.Cast", caster)
    end)
	
	-- Set Control Point 1 for the backstab particle; this controls where it's positioned in the world. In this case, it should be positioned on the victim.
	ParticleManager:SetParticleControlEnt(particle, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true) 
	ParticleManager:SetParticleControlEnt(particle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	
	if caster:HasTalent("special_bonus_unique_undying_summon_zombies_1") then
		for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( target:GetAbsOrigin(), caster:FindTalentValue("special_bonus_unique_undying_summon_zombies_1") ) ) do
			if enemy ~= target then
				enemy:AddNewModifier(caster, ability, "modifier_undying_summon_zombies", { duration = self:GetRemainingTime() })
				break
			end
		end
	end
end

function modifier_undying_summon_zombies:DeclareFunctions()
	return {MODIFIER_PROPERTY_TURNRATE_PER,
			MODIFIER_PROPERTY_MOVESPEED_PER}
end

function modifier_undying_summon_zombies:Getturnslow()
	return self.turn
end

function modifier_undying_summon_zombies:Getms()
	return self.slow
end