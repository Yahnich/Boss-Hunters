nyx_impale = class({})

function nyx_impale:IsStealable()
	return true
end

function nyx_impale:GetCastRange(vLocation, hTarget)
	if self:GetCaster():HasModifier("modifier_nyx_burrow") then
		return self:GetTalentSpecialValueFor("length") + self:GetTalentSpecialValueFor("impale_range")
	end
	return self:GetTalentSpecialValueFor("length")
end

function nyx_impale:GetBehavior()
	local caster = self:GetCaster()
	if caster:HasModifier("modifier_nyx_burrow") then
		return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_IMMEDIATE + DOTA_ABILITY_BEHAVIOR_UNRESTRICTED
	else
		return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING
	end
end

function nyx_impale:GetCooldown(iLvl)
    local cooldown = self.BaseClass.GetCooldown(self, iLvl)
    if self:GetCaster():HasModifier("modifier_nyx_burrow") then 
    	cooldown = cooldown + self:GetTalentSpecialValueFor("impale_cd")
    end
    return cooldown
end

function nyx_impale:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()

	local direction = CalculateDirection(point, caster:GetAbsOrigin())
	local distance = self:GetTalentSpecialValueFor("length")
	if caster:HasModifier("modifier_nyx_burrow") then
		distance = distance + self:GetTalentSpecialValueFor("impale_range")
	end
	local width = self:GetTalentSpecialValueFor("width")
	local speed = self:GetTalentSpecialValueFor("speed")

	self:FireLinearProjectile("particles/units/heroes/hero_nyx_assassin/nyx_assassin_impale.vpcf", direction*speed, distance, width, {}, false, true, width*2)

	if caster:HasTalent("special_bonus_unique_nyx_impale_2") then
		local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), distance)
		for _,enemy in pairs(enemies) do
			direction = CalculateDirection(enemy, caster)
			self:FireLinearProjectile("particles/units/heroes/hero_nyx_assassin/nyx_assassin_impale.vpcf", direction*speed, distance, width, {}, false, true, width*2)
			break
		end
	end
end

function nyx_impale:OnProjectileHit(hTarget, vLocation)
	local caster = self:GetCaster()
	local duration = self:GetTalentSpecialValueFor("duration")

	if hTarget then
		ParticleManager:FireParticle("particles/units/heroes/hero_nyx_assassin/nyx_assassin_impale_hit.vpcf", PATTACH_POINT, caster, {[0]=hTarget:GetAbsOrigin()})

		hTarget:ApplyKnockBack(vLocation, duration, duration, 0, 350, caster, self)
		--self:Stun(hTarget, duration, false)
		Timers:CreateTimer(duration, function()
			self:DealDamage(caster, hTarget, self:GetTalentSpecialValueFor("damage"), {}, 0)
		end)
	end
end