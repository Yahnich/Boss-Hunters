windrunner_skillshot = class({})
LinkLuaModifier("modifier_windrunner_skillshot_handle", "heroes/hero_windrunner/windrunner_skillshot", LUA_MODIFIER_MOTION_NONE)

function windrunner_skillshot:GetIntrinsicModifierName()
	return "modifier_windrunner_skillshot_handle"
end

function windrunner_skillshot:GetCastPoint()
	if self:GetCaster():GetSecondsPerAttack() < 0.3 then
		return self:GetCaster():GetSecondsPerAttack()
	else
		return 0.3
	end
end

function windrunner_skillshot:GetPlaybackRateOverride()
	if 1/self:GetCaster():GetSecondsPerAttack() > 1 then
		return 1/self:GetCaster():GetSecondsPerAttack()
	else
		return 1
	end
end

function windrunner_skillshot:GetCastRange(vLocation, hTarget)
	return self:GetCaster():GetAttackRange() + 1000
end

function windrunner_skillshot:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	caster:PerformAttack(target, true, true, true, true, true, false, false)
	self:FireTrackingProjectile("particles/skillshot.vpcf", target, caster:GetProjectileSpeed(), {}, DOTA_PROJECTILE_ATTACHMENT_ATTACK_1)
end

function windrunner_skillshot:OnProjectileHit(hTarget, vLocation)
	if hTarget then
		local damage = self:GetCaster():GetAttackDamage() * self:GetTalentSpecialValueFor("pierce_pct")/100 + self:GetTalentSpecialValueFor("base_damage")
		self:Stun(hTarget, self:GetTalentSpecialValueFor("duration"))
		self:DealDamage(self:GetCaster(), hTarget, damage, {}, OVERHEAD_ALERT_DAMAGE)
	end
end

modifier_windrunner_skillshot_handle = class({})

function modifier_windrunner_skillshot_handle:OnCreated()
	if IsServer() then
		self.lastAttack = 0
		self.cd = self:GetTalentSpecialValueFor("passive_cooldown")
		self.chance = self:GetTalentSpecialValueFor("chance")
	end
end

function modifier_windrunner_skillshot_handle:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ATTACK_RECORD
    }
    return funcs
end

function modifier_windrunner_skillshot_handle:OnAttackRecord(params)
    if IsServer() and params.attacker == self:GetParent() and params.target and params.target:GetTeam() ~= self:GetCaster():GetTeam()  then
    	if self.lastAttack + self.cd < GameRules:GetGameTime() and self:RollPRNG( self.chance ) then
    		self:GetAbility():FireTrackingProjectile("particles/skillshot.vpcf", params.target, params.attacker:GetProjectileSpeed(), {}, DOTA_PROJECTILE_ATTACHMENT_ATTACK_1)
    		if not self:GetCaster():HasTalent("special_bonus_unique_windrunner_focusfire_bh_1") and not self:GetCaster():HasModifier("modifier_windrunner_focusfire_bh") then
    			self.lastAttack = GameRules:GetGameTime()
    		end
    	end
    end
end

function modifier_windrunner_skillshot_handle:IsHidden()
	return true
end