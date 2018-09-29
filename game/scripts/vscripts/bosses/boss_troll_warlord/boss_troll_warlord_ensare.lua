boss_troll_warlord_ensare = boss_troll_warlord_ensare or class({})
LinkLuaModifier( "modifier_boss_troll_warlord_ensare", "bosses/boss_troll_warlord/boss_troll_warlord_ensare.lua", LUA_MODIFIER_MOTION_NONE )

function boss_troll_warlord_ensare:OnAbilityPhaseStart()
	local caster = self:GetCaster()
	local maxTargets = self:GetSpecialValueFor("max_targets")
	local currentTargets = 0
	self.locations = {}
	
	local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), self:GetSpecialValueFor("range"))
	for _,enemy in pairs(enemies) do
		if currentTargets < maxTargets then
			ParticleManager:FireWarningParticle(enemy:GetAbsOrigin(), self:GetSpecialValueFor("radius"))
			table.insert(self.locations, enemy:GetAbsOrigin())
			currentTargets = currentTargets + 1
		end
	end
	return true
end

function boss_troll_warlord_ensare:OnSpellStart()
	local caster = self:GetCaster()
	EmitSoundOn("Hero_Meepo.Earthbind.Cast", caster)

	for _,point in pairs(self.locations) do
		local dummy = caster:CreateDummy(point)
		self:FireTrackingProjectile("particles/units/heroes/hero_meepo/meepo_earthbind_projectile_fx.vpcf", dummy, 500, {}, DOTA_PROJECTILE_ATTACHMENT_ATTACK_1, false, false, 0)
		dummy:ForceKill(false)
	end
end

function boss_troll_warlord_ensare:OnProjectileHit(hTarget, vLocation)
	local caster = self:GetCaster()

	local enemies = caster:FindEnemyUnitsInRadius(vLocation, self:GetSpecialValueFor("radius"))
	for _,enemy in pairs(enemies) do
		if not enemy:TriggerSpellAbsorb(self) then
			EmitSoundOn("Hero_Meepo.Earthbind.Target", enemy)
			enemy:AddNewModifier(caster, self, "modifier_boss_troll_warlord_ensare", {Duration = self:GetSpecialValueFor("duration")})
		end
	end
end

modifier_boss_troll_warlord_ensare = class({})
function modifier_boss_troll_warlord_ensare:IsDebuff()
	return true
end

function modifier_boss_troll_warlord_ensare:CheckState()
	local state = { [MODIFIER_STATE_ROOTED] = true}
	return state
end

function modifier_boss_troll_warlord_ensare:GetEffectName()
	return "particles/units/heroes/hero_meepo/meepo_earthbind.vpcf"
end