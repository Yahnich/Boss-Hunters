tinker_turret = class({})
LinkLuaModifier( "modifier_tinker_turret", "heroes/hero_tinker/tinker_turret.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_tinker_turret_rockets", "heroes/hero_tinker/tinker_turret.lua", LUA_MODIFIER_MOTION_NONE )

function tinker_turret:OnAbilityPhaseStart()
	EmitSoundOn("Hero_Tinker.March_of_the_Machines.Cast", self:GetCaster())
    return true
end

function tinker_turret:OnAbilityPhaseInterrupted()
	StopSoundOn("Hero_Tinker.March_of_the_Machines.Cast", self:GetCaster())
end

function tinker_turret:OnSpellStart()
	local caster = self:GetCaster()
	
	local point = self:GetCursorPosition()
	
	EmitSoundOnLocationWithCaster(point, "DOTA_Item.SentryWard.Activate", caster)

	local turret = caster:CreateSummon("npc_tinker_turret", point, self:GetSpecialValueFor("duration"))
	turret:AddNewModifier(caster, self, "modifier_tinker_turret", {})

	if caster:HasScepter() then
		turret:AddNewModifier(caster, self, "modifier_tinker_turret_rockets", {})
	end

	ParticleManager:FireParticle("particles/dev/library/base_dust_hit.vpcf", PATTACH_POINT, caster, {[0]=turret:GetAbsOrigin()})

	GridNav:DestroyTreesAroundPoint(turret:GetAbsOrigin(), 250, false)
end

function tinker_turret:OnProjectileHit(hTarget, vLocation)
	local caster = self:GetCaster()

	if hTarget ~= nil and not hTarget:TriggerSpellAbsorb( self ) then
		EmitSoundOn("Hero_Tinker.Heat-Seeking_Missile.Impact", hTarget)
		ParticleManager:FireParticle("particles/units/heroes/hero_tinker/tinker_missle_explosion.vpcf", PATTACH_POINT, hTarget, {})
		local damage = caster:GetIntellect( false)*300/100
		self:DealDamage(caster, hTarget, damage, {}, 0)
	end
end

modifier_tinker_turret = class({})
function modifier_tinker_turret:OnCreated(table)
	if IsServer() then
		self:GetParent():StartGesture(ACT_DOTA_IDLE)
		self.nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_tinker/tinker_turret_ambient.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControlEnt(self.nfx, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetParent():GetAbsOrigin(), true)

		self:StartIntervalThink(self:GetCaster():GetSecondsPerAttack())
	end
end

function modifier_tinker_turret:OnIntervalThink()
	local enemies = self:GetCaster():FindEnemyUnitsInRadius(self:GetParent():GetAbsOrigin(), self:GetCaster():GetAttackRange())
	for _,enemy in pairs(enemies) do
		EmitSoundOn("Hero_Zuus.ArcLightning.Target", enemy)
		ParticleManager:FireRopeParticle("particles/units/heroes/hero_tinker/tinker_turret_attack.vpcf", PATTACH_POINT, self:GetParent(), enemy, {[8]=Vector(math.random(1,2),math.random(1,2),math.random(1,2)),[9]=Vector(math.random(1,2),math.random(1,2),math.random(1,2))}, "attach_attack1")
		self:GetAbility():DealDamage(self:GetCaster(), enemy, self:GetCaster():GetAttackDamage(), {}, 0)
		break
	end
end

function modifier_tinker_turret:OnRemoved()
	if IsServer() then
		ParticleManager:DestroyParticle(self.nfx, false)
	end
end

function modifier_tinker_turret:CheckState()
	local state = {	[MODIFIER_STATE_UNSELECTABLE] = true,
					[MODIFIER_STATE_UNTARGETABLE] = true,
					[MODIFIER_STATE_ATTACK_IMMUNE] = true,
					[MODIFIER_STATE_MAGIC_IMMUNE] = true,
					[MODIFIER_STATE_NO_HEALTH_BAR] = true,
					}
	return state
end

modifier_tinker_turret_rockets = class({})
function modifier_tinker_turret_rockets:OnCreated(table)
	if IsServer() then
		self:StartIntervalThink(2.0)
	end
end

function modifier_tinker_turret_rockets:OnIntervalThink()
	local enemies = self:GetCaster():FindEnemyUnitsInRadius(self:GetParent():GetAbsOrigin(), self:GetCaster():GetAttackRange())
	for _,enemy in pairs(enemies) do
		EmitSoundOn("Hero_Tinker.Heat-Seeking_Missile", self:GetParent())
		self:GetAbility():FireTrackingProjectile("particles/units/heroes/hero_tinker/tinker_missile.vpcf", enemy, 900, {source=self:GetParent(), origin=self:GetParent():GetAbsOrigin()}, DOTA_PROJECTILE_ATTACHMENT_ATTACK_1, true, true, 100)
		break
	end
end