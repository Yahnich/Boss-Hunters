vengefulspirit_magic_barrage = class({})

function vengefulspirit_magic_barrage:IsStealable()
	return true
end

function vengefulspirit_magic_barrage:IsHiddenWhenStolen()
	return false
end

function vengefulspirit_magic_barrage:GetCooldown(iLvl)
    local cooldown = self.BaseClass.GetCooldown(self, iLvl)
    return cooldown
end

function vengefulspirit_magic_barrage:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end

function vengefulspirit_magic_barrage:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	EmitSoundOn("Hero_VengefulSpirit.MagicMissile", caster)

	self:FireTrackingProjectile("particles/units/heroes/hero_vengeful/vengeful_magic_missle.vpcf", target, self:GetSpecialValueFor("speed"), {}, DOTA_PROJECTILE_ATTACHMENT_ATTACK_2, false, true, 100)

	local enemies = caster:FindEnemyUnitsInRadius(target:GetAbsOrigin(), self:GetSpecialValueFor("radius"))
	for _,enemy in pairs(enemies) do
		if enemy ~= target then
			self:FireTrackingProjectile("particles/units/heroes/hero_vengeful/vengeful_magic_missle.vpcf", enemy, self:GetSpecialValueFor("speed"), {}, DOTA_PROJECTILE_ATTACHMENT_ATTACK_2, false, true, 100)
		end
	end
end

function vengefulspirit_magic_barrage:OnProjectileHit(target, position)
	if target ~= nil and not target:TriggerSpellAbsorb( self ) then
		local caster = self:GetCaster()
		EmitSoundOn("Hero_VengefulSpirit.MagicMissile", target)
		self:Stun(target, self:GetSpecialValueFor("stun_duration"), false)
		self:DealDamage(caster, target, self:GetSpecialValueFor("damage"), {}, 0)
		if caster:HasTalent("special_bonus_unique_vengefulspirit_magic_barrage_2") then
			target:AddNewModifier( caster, self, "modifier_vengefulspirit_magic_barrage_talent", {} )
		end
	end
end

modifier_vengefulspirit_magic_barrage_talent = class({})
LinkLuaModifier("modifier_vengefulspirit_magic_barrage_talent", "heroes/hero_vengeful/vengefulspirit_magic_barrage", LUA_MODIFIER_MOTION_NONE)

function modifier_vengefulspirit_magic_barrage_talent:OnCreated()
	self.amp = self:GetCaster():FindTalentValue("special_bonus_unique_vengefulspirit_magic_barrage_2")
end

function modifier_vengefulspirit_magic_barrage_talent:DeclareFunctions()
	return { MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE }
end

function modifier_vengefulspirit_magic_barrage_talent:GetModifierIncomingDamage_Percentage()
	self:Destroy()
	return self.amp
end
