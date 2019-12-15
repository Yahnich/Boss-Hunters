vengefulspirit_haunt = class({})
LinkLuaModifier( "modifier_vengefulspirit_haunt", "heroes/hero_vengeful/vengefulspirit_haunt.lua",LUA_MODIFIER_MOTION_NONE )

function vengefulspirit_haunt:IsStealable()
	return true
end

function vengefulspirit_haunt:IsHiddenWhenStolen()
	return false
end

function vengefulspirit_haunt:GetAOERadius()
	return self:GetTalentSpecialValueFor("radius")
end

function vengefulspirit_haunt:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	EmitSoundOn("Hero_ArcWarden.SparkWraith.Appear", caster)

	self:FireTrackingProjectile("particles/units/heroes/hero_vengeful/vengeful_haunt.vpcf", target, self:GetTalentSpecialValueFor("speed"), {}, DOTA_PROJECTILE_ATTACHMENT_HITLOCATION, false, true, 100)

	if caster:HasTalent("special_bonus_unique_vengefulspirit_haunt_1") then
		local enemies = caster:FindEnemyUnitsInRadius(target:GetAbsOrigin(), 250)
		for _,enemy in pairs(enemies) do
			self:FireTrackingProjectile("particles/units/heroes/hero_vengeful/vengeful_haunt.vpcf", enemy, self:GetTalentSpecialValueFor("speed"), {}, DOTA_PROJECTILE_ATTACHMENT_HITLOCATION, false, true, 100)
			break
		end
	end
end

function vengefulspirit_haunt:OnProjectileHit(hTarget, vLocation)
	if hTarget ~= nil and not hTarget:TriggerSpellAbsorb( self ) then
		EmitSoundOn("Hero_Bane.Nightmare.End", hTarget)
		hTarget:AddNewModifier(self:GetCaster(), self, "modifier_vengefulspirit_haunt", {Duration = self:GetTalentSpecialValueFor("duration")})

		if self:GetCaster():HasTalent("special_bonus_unique_vengefulspirit_haunt_2") then
			self:DealDamage(self:GetCaster(), hTarget, self:GetTalentSpecialValueFor("damage"), {}, 0)
		end
	end
end

modifier_vengefulspirit_haunt = class({})
function modifier_vengefulspirit_haunt:OnCreated(table)
	if IsServer() then
		self:StartIntervalThink(0.5)
	end
end

function modifier_vengefulspirit_haunt:OnRefresh(table)
	if IsServer() then
		self:StartIntervalThink(0.5)
	end
end

function modifier_vengefulspirit_haunt:OnIntervalThink()
	self:GetAbility():DealDamage(self:GetCaster(), self:GetParent(), self:GetTalentSpecialValueFor("damage")/2, {}, OVERHEAD_ALERT_BONUS_POISON_DAMAGE)
end

function modifier_vengefulspirit_haunt:DeclareFunctions()
    local funcs = {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
					MODIFIER_EVENT_ON_DEATH}
    return funcs
end

function modifier_vengefulspirit_haunt:GetModifierIncomingDamage_Percentage()
    return self:GetTalentSpecialValueFor("bonus_damage")
end

function modifier_vengefulspirit_haunt:OnDeath(params)
    if params.unit == self:GetParent() then
    	self:GetAbility():EndCooldown()
    end
end

function modifier_vengefulspirit_haunt:GetEffectName()
	return "particles/units/heroes/hero_vengeful/vengeful_haunt_debuff.vpcf"
end