boss4_sacrifice = class({})

function boss4_sacrifice:OnSpellStart()
	local caster = self:GetCaster()
	EmitSoundOn("Hero_Undying.Decay.Cast", caster)
	self.warmUpFX = ParticleManager:CreateParticle("particles/generic_aoe_persistent_circle_1/death_timer_glow_rev.vpcf", PATTACH_OVERHEAD_FOLLOW, caster)
	self.zombies = caster:FindAbilityByName("boss4_summon_zombies").zombies or {}
	self.tickrate = self:GetChannelTime() / (caster:FindAbilityByName("boss4_summon_zombies"):GetZombieCount() + 1)
	StartAnimation(caster, {duration = self:GetChannelTime(), activity = ACT_DOTA_VICTORY})
	self.delay = 0
end


function boss4_sacrifice:OnChannelThink(flInterval)
	local caster = self:GetCaster()
	if self.delay > self.tickrate then
		self.delay = 0
		for zombie,_ in pairs(self.zombies) do
			if not zombie:IsNull() and zombie:IsAlive() then
				ParticleManager:FireRopeParticle("particles/units/heroes/hero_undying/undying_soul_rip_heal.vpcf", PATTACH_POINT_FOLLOW, zombie, caster)
				caster:HealEvent(zombie:GetHealth(), self, caster)
				EmitSoundOn("Hero_Undying.Decay.Target", zombie)
				EmitSoundOn("Hero_Undying.Decay.Transfer", caster)
				zombie:Kill(self, caster)
				break
			end
		end
	else
		self.delay = self.delay + flInterval
	end
end

function boss4_sacrifice:OnChannelFinish(bInterrupted)
	ParticleManager:ClearParticle(self.warmUpFX)
	EndAnimation(self:GetCaster())
end