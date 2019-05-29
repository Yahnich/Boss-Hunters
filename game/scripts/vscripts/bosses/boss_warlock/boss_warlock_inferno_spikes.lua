boss_warlock_inferno_spikes = class({})
LinkLuaModifier( "modifier_boss_warlock_inferno_spikes", "bosses/boss_warlock/boss_warlock_inferno_spikes", LUA_MODIFIER_MOTION_NONE )

function boss_warlock_inferno_spikes:OnAbilityPhaseStart()
	local caster = self:GetCaster()
	ParticleManager:FireWarningParticle(caster:GetAbsOrigin(), 1000)
	caster:EmitSound("Creature.Laugh")
	return true
end

function boss_warlock_inferno_spikes:OnSpellStart()
	local caster = self:GetCaster()
	local speed = self:GetSpecialValueFor("speed")
	local width = self:GetSpecialValueFor("width")
	local range = 100000

	local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), FIND_UNITS_EVERYWHERE)
	for _,enemy in pairs(enemies) do
		if enemy:IsRealHero() and not enemy:IsMagicImmune() and not enemy:IsInvulnerable() and not enemy:IsInvisible() then
			local direction = CalculateDirection(enemy, caster)
			self:FireLinearProjectile("particles/bosses/boss_warlockgolems/boss_ember_spike.vpcf", direction*speed, range, width, {}, false, false, 0)
		end
	end
end

function boss_warlock_inferno_spikes:OnProjectileHit(hTarget, vLocation)
	local caster = self:GetCaster()
	if hTarget then
		local blocked = hTarget:TriggerSpellAbsorb(self)
		if not blocked then
			hTarget:AddNewModifier(caster, self, "modifier_boss_warlock_inferno_spikes", {Duration = self:GetSpecialValueFor("duration")})
			self:DealDamage(caster, hTarget, self:GetSpecialValueFor("damage"), {}, 0)
		end
		return blocked
	end
end

modifier_boss_warlock_inferno_spikes = class({})
function modifier_boss_warlock_inferno_spikes:OnCreated(table)
	if IsServer() then self:StartIntervalThink(FrameTime()) end
end

function modifier_boss_warlock_inferno_spikes:OnIntervalThink()
	self.damage = self.damage or ( self:GetParent():GetMaxHealth() * (self:GetSpecialValueFor("dot")/100) * 0.25 ) / self:GetRemainingTime()
	if self:GetParent():InWater() then
		self:Destroy()
		return 
	end
	self:GetAbility():DealDamage(self:GetCaster(), self:GetParent(), self.damage, {damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION}, 0)
	self:StartIntervalThink(0.25)
end

function modifier_boss_warlock_inferno_spikes:GetEffectName()
	return "particles/units/heroes/hero_huskar/huskar_burning_spear_debuff.vpcf"
end

function modifier_boss_warlock_inferno_spikes:GetStatusEffectName()
	return "particles/status_fx/status_effect_burn.vpcf"
end

function modifier_boss_warlock_inferno_spikes:StatusEffectPriority()
	return 11
end

function modifier_boss_warlock_inferno_spikes:IsDebuff()
	return true
end