boss_warlock_desecrate = class({})
LinkLuaModifier( "modifier_boss_warlock_desecrate", "bosses/boss_warlock/boss_warlock_desecrate", LUA_MODIFIER_MOTION_NONE )

function boss_warlock_desecrate:GetChannelTime()
	return self:GetSpecialValueFor("duration")
end

function boss_warlock_desecrate:GetChannelAnimation()
	return ACT_DOTA_CHANNEL_ABILITY_3
end

function boss_warlock_desecrate:GetChannelAnimation()
	return ACT_DOTA_CHANNEL_ABILITY_3
end

function boss_warlock_desecrate:OnAbilityPhaseStart()
	ParticleManager:FireWarningParticle(self:GetCaster():GetAbsOrigin(), 500)
	return true
end

function boss_warlock_desecrate:OnSpellStart()
	local caster = self:GetCaster()

	caster:AddNewModifier(caster, self, "modifier_status_immunity", {Duration = self:GetSpecialValueFor("duration")})
	FindClearSpaceForUnit(caster, Vector(0,0,0), true)

	self.newRadius = 0

	EmitSoundOn("Hero_ShadowDemon.DemonicPurge.Cast", self.caster)

	self.nfx = ParticleManager:CreateParticle("particles/bosses/boss_warlock/boss_warlock_desecrate.vpcf", PATTACH_POINT, caster)
	ParticleManager:SetParticleControl(self.nfx, 0, caster:GetAbsOrigin()+Vector(0,0,100) )
	ParticleManager:SetParticleControl(self.nfx, 1, Vector(self.newRadius,self.newRadius,self.newRadius))
end

function boss_warlock_desecrate:OnChannelThink(flInterval)
	self.newRadius = self.newRadius + 10
	ParticleManager:SetParticleControl(self.nfx, 1, Vector(self.newRadius,self.newRadius,self.newRadius))
	local enemies = self:GetCaster():FindEnemyUnitsInRadius(self:GetCaster():GetAbsOrigin(), self.newRadius)
	for _,enemy in pairs(enemies) do
		if not enemy:IsMagicImmune() and not enemy:IsInvulnerable() then
			enemy:DisableHealing(0.5)
			enemy:AddNewModifier(self:GetCaster(), self, "modifier_boss_warlock_desecrate", {Duration = 0.5}):IncrementStackCount()
		end
	end
end

function boss_warlock_desecrate:OnChannelFinish(bInterrupted)
	ParticleManager:ClearParticle(self.nfx)
	self:GetCaster():RemoveModifierByName("modifier_status_immunity")
end

modifier_boss_warlock_desecrate = class({})
function modifier_boss_warlock_desecrate:OnCreated(table)
	if IsServer() then self:StartIntervalThink(0.5) end
end

function modifier_boss_warlock_desecrate:OnIntervalThink()
	self:GetAbility():DealDamage(self:GetCaster(), self:GetParent(), self:GetSpecialValueFor("damage")*self:GetStackCount(), {}, 0)
end

function modifier_boss_warlock_desecrate:IsDebuff()
	return true
end