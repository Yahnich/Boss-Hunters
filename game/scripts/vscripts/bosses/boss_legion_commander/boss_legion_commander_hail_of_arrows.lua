boss_legion_commander_hail_of_arrows = class({})

function boss_legion_commander_hail_of_arrows:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end

function boss_legion_commander_hail_of_arrows:OnAbilityPhaseStart()
	ParticleManager:FireWarningParticle( self:GetCursorPosition(), self:GetSpecialValueFor("radius") )
	if IsServer() then
		self.cast2 = ParticleManager:CreateParticle("particles/units/heroes/hero_legion_commander/legion_commander_odds_cast.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, self:GetCaster())
			ParticleManager:SetParticleControlEnt(self.cast2, 1, self:GetCaster(), PATTACH_CUSTOMORIGIN_FOLLOW, "attach_attack1", self:GetCaster():GetAbsOrigin(), true)
		self.cast = ParticleManager:CreateParticle("particles/units/heroes/hero_legion_commander/legion_commander_odds_cast.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, self:GetCaster())
			ParticleManager:SetParticleControlEnt(self.cast, 1, self:GetCaster(), PATTACH_CUSTOMORIGIN_FOLLOW, "attach_attack2", self:GetCaster():GetAbsOrigin(), true)
	end
	EmitSoundOn("Hero_LegionCommander.Overwhelming.Cast",self:GetCaster())
	return true
end

function boss_legion_commander_hail_of_arrows:OnAbilityPhaseInterrupted()
	if IsServer() then
		ParticleManager:ClearParticle(self.cast)
		ParticleManager:ClearParticle(self.cast2)
	end
end

function boss_legion_commander_hail_of_arrows:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		local target = self:GetCursorPosition()
		EmitSoundOn("Hero_LegionCommander.Overwhelming.Location",self:GetCaster())
		local radius = self:GetSpecialValueFor("radius")
		local base_damage = self:GetSpecialValueFor("damage")
		local bonus_damage = self:GetSpecialValueFor("damage_per_unit")
		local duration = self:GetSpecialValueFor("duration")
		local arrows = ParticleManager:CreateParticle("particles/units/heroes/hero_legion_commander/legion_commander_odds.vpcf", PATTACH_ABSORIGIN , caster)
				ParticleManager:SetParticleControl(arrows, 0, target)
				ParticleManager:SetParticleControl(arrows, 1, target)
				ParticleManager:SetParticleControl(arrows, 3, target)
				ParticleManager:SetParticleControl(arrows, 4, Vector(radius,0,0) )
				ParticleManager:SetParticleControl(arrows, 5, Vector(radius,0,0) )
				ParticleManager:SetParticleControl(arrows, 6, target)
				ParticleManager:SetParticleControl(arrows, 7, target)
				ParticleManager:SetParticleControl(arrows, 8, target)
		ParticleManager:ReleaseParticleIndex(arrows)
		local units = FindUnitsInRadius(caster:GetTeam(), target, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, 0, false)
		local stacks = 0
		for _,unit in pairs(units) do -- check units
			if ((unit:IsHero() and unit:GetTeam() == caster:GetTeam()) or unit:GetTeam() ~= caster:GetTeam()) and unit ~= self:GetCaster() then
				base_damage = base_damage + bonus_damage
				stacks = stacks + 1
			end
		end
		for _,unit in pairs(units) do -- deal damage
			if unit:GetTeam() ~= caster:GetTeam() then
				ApplyDamage({victim = unit, attacker = caster, damage = base_damage, damage_type = self:GetAbilityDamageType(), ability = self})
				EmitSoundOn("Hero_LegionCommander.Overwhelming.Creep",unit)
			end
		end
		
		ParticleManager:ClearParticle(self.cast)
		ParticleManager:ClearParticle(self.cast2)
	end
end

