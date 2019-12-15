boss_clockwerk_mark_for_destruction = class({})

function boss_clockwerk_mark_for_destruction:IsStealable()
	return true
end

function boss_clockwerk_mark_for_destruction:IsHiddenWhenStolen()
	return false
end

function boss_clockwerk_mark_for_destruction:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end

if IsServer() then
	function boss_clockwerk_mark_for_destruction:OnAbilityPhaseStart()
		ParticleManager:FireWarningParticle( self:GetCursorPosition(), self:GetAOERadius() )
		return true
	end
	function boss_clockwerk_mark_for_destruction:OnSpellStart()
		local caster = self:GetCaster()
		local targetPos = self:GetCursorPosition()
		self:FireFlashbang(targetPos)
	end
	
	function boss_clockwerk_mark_for_destruction:FireFlashbang(position)
		local dummy = self:CreateDummy(position)
		local projectile = {
			Target = dummy,
			Source = self:GetCaster(),
			Ability = self,
			EffectName = "particles/units/heroes/hero_rattletrap/rattletrap_rocket_flare.vpcf",
			bDodgable = false,
			bProvidesVision = false,
			iMoveSpeed = 1800,
			iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_2,
		}
		ProjectileManager:CreateTrackingProjectile(projectile)
		EmitSoundOn("Hero_Rattletrap.Rocket_Flare.Fire", self:GetCaster())
	end

	function boss_clockwerk_mark_for_destruction:OnProjectileHit(target, position)
		local caster = self:GetCaster()
		local radius = self:GetTalentSpecialValueFor("radius")
		local duration = self:GetTalentSpecialValueFor("duration")
		local enemies = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
		EmitSoundOn("Hero_Rattletrap.Rocket_Flare.Explode", self:GetCaster())
		UTIL_Remove(target)
		for _, enemy in pairs(enemies) do
			if not enemy:TriggerSpellAbsorb( self ) then
				enemy:AddNewModifier(caster, self, "modifier_boss_clockwerk_mark_for_destruction_blind", {duration = duration})
				ApplyDamage({victim = enemy, attacker = caster, damage = self:GetTalentSpecialValueFor("damage"), damage_type = self:GetAbilityDamageType(), ability = self})
			end
		end
		AddFOWViewer( caster:GetTeamNumber(), position, radius, 10, false ) 
	end
end

modifier_boss_clockwerk_mark_for_destruction_blind = class({})
LinkLuaModifier( "modifier_boss_clockwerk_mark_for_destruction_blind", "bosses/boss_clockwerk/boss_clockwerk_mark_for_destruction" ,LUA_MODIFIER_MOTION_NONE )

function modifier_boss_clockwerk_mark_for_destruction_blind:OnCreated()
	self.miss = self:GetAbility():GetTalentSpecialValueFor("blind")
	self.amp = self:GetAbility():GetTalentSpecialValueFor("bonus_damage")
end

function modifier_boss_clockwerk_mark_for_destruction_blind:OnRefresh()
	self.miss = self:GetAbility():GetTalentSpecialValueFor("blind")
	self.amp = self:GetAbility():GetTalentSpecialValueFor("bonus_damage")
end

function modifier_boss_clockwerk_mark_for_destruction_blind:DeclareFunctions()
	funcs = {
				MODIFIER_PROPERTY_MISS_PERCENTAGE,
				MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE 
			}
	return funcs
end

function modifier_boss_clockwerk_mark_for_destruction_blind:GetModifierMiss_Percentage()
	return self.miss
end

function modifier_boss_clockwerk_mark_for_destruction_blind:GetModifierIncomingDamage_Percentage()
	return self.amp
end

function modifier_boss_clockwerk_mark_for_destruction_blind:GetEffectName()
	return "particles/units/heroes/hero_keeper_of_the_light/keeper_of_the_light_blinding_light_debuff.vpcf"
end

function modifier_boss_clockwerk_mark_for_destruction_blind:GetStatusEffectName()
	return "particles/status_fx/status_effect_slardar_amp_damage.vpcf"
end

function modifier_boss_clockwerk_mark_for_destruction_blind:StatusEffectPriority()
	return 8
end