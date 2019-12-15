ss_thunder_punch = class({})
LinkLuaModifier("modifier_ss_thunder_punch", "heroes/hero_storm_spirit/ss_thunder_punch", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ss_thunder_punch_talent", "heroes/hero_storm_spirit/ss_thunder_punch", LUA_MODIFIER_MOTION_NONE)

function ss_thunder_punch:IsStealable()
    return true
end

function ss_thunder_punch:IsHiddenWhenStolen()
    return false
end

function ss_thunder_punch:GetManaCost(iLevel)
    if self:GetCaster():HasModifier("modifier_ss_thunder_punch_talent") then
    	return self:GetTalentSpecialValueFor("mana_cost")/2
    end
    return self:GetTalentSpecialValueFor("mana_cost")
end

function ss_thunder_punch:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()

	local distance = self:GetTrueCastRange()
	local direction = CalculateDirection(point, caster:GetAbsOrigin())
	local speed = 2000

	EmitSoundOn("Hero_Sven.StormBolt", caster)

	if caster:HasTalent("special_bonus_unique_ss_thunder_punch_1") then
		if caster:HasModifier("modifier_ss_thunder_punch_talent") then
			self:FireLinearProjectile("particles/units/heroes/hero_storm_spirit/ss_thunder_punch.vpcf", direction*speed, distance, 75, {extraData = {name = "second"}}, true, true, 100)	
			caster:RemoveModifierByName("modifier_ss_thunder_punch_talent")
			self:EndCooldown()
			self:StartCooldown( self.lastCastCD - (GameRules:GetGameTime() - self.lastCastTime) )
		else
			self:FireLinearProjectile("particles/units/heroes/hero_storm_spirit/ss_thunder_punch.vpcf", direction*speed, distance, 75, {extraData = {name = "first"}}, true, true, 100)	
			self.lastCastTime = GameRules:GetGameTime()
			self.lastCastCD = self:GetCooldownTimeRemaining()
			self:EndCooldown()
			caster:AddNewModifier(caster, self, "modifier_ss_thunder_punch_talent", {Duration = 5})
		end
	else
		self:FireLinearProjectile("particles/units/heroes/hero_storm_spirit/ss_thunder_punch.vpcf", direction*speed, distance, 75, {extraData = {name = "first"}}, true, true, 100)	
	end
end

function ss_thunder_punch:OnProjectileHit_ExtraData(hTarget, vLocation, table)
	local caster = self:GetCaster()

	local bonusAttack = self:GetTalentSpecialValueFor("attack_damage")

	if table.name == "second" then
		bonusAttack = bonusAttack/2
	end

	if hTarget then
		if not hTarget:TriggerSpellAbsorb( self ) then
			caster:PerformAbilityAttack(hTarget, true, self, bonusAttack, true, true)
		end

		if not caster:HasTalent("special_bonus_unique_ss_thunder_punch_2") then
			return true
		end
	else
		EmitSoundOnLocationWithCaster(vLocation, "Hero_Sven.StormBoltImpact", caster)
	end
end

modifier_ss_thunder_punch_talent = class({})
function modifier_ss_thunder_punch_talent:OnCreated(table)
	if IsServer() then
		self:SetDuration(self:GetDuration(), true)
	end
end

function modifier_ss_thunder_punch_talent:OnRemoved()
	if IsServer() then
		self:GetAbility():SetCooldown()
	end
end

function modifier_ss_thunder_punch_talent:IsHidden()
	return false
end

function modifier_ss_thunder_punch_talent:IsHidden()
	return false
end

function modifier_ss_thunder_punch_talent:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end