queenofpain_shadow_strike_bh = class({})

function queenofpain_shadow_strike_bh:GetBehavior()
	if caster:HasTalent("special_bonus_unique_queenofpain_shadow_strike_1") then
		return DOTA_ABILITY_BEHAVIOR_NO_TARGET
	else
		return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
	end
end

function queenofpain_shadow_strike_bh:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	
	if caster:HasTalent("special_bonus_unique_queenofpain_shadow_strike_1") then
		for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), self:GetTrueCastRange() ) ) do
			self:FireTrackingProjectile("particles/units/heroes/hero_queenofpain/queen_shadow_strike.vpcf", target, speed)
		end
	else
		self:FireTrackingProjectile("particles/units/heroes/hero_queenofpain/queen_shadow_strike.vpcf", target, speed)
	end
end

function queenofpain_shadow_strike_bh:OnProjectileHit( target, position )
	if target then
		local caster = self:GetCaster()
		
		local damage = self:GetTalentSpecialValueFor("strike_damage")
		local duration = self:GetTalentSpecialValueFor("duration_tooltip")
		self:DealDamage( caster, target, damage )
		target:AddNewModifier( caster, self, "modifier_queen_of_pain_shadow_strike_bh", {duration = duration})
	end
end

modifier_queen_of_pain_shadow_strike_bh = class({})
LinkLuaModifier("modifier_queen_of_pain_shadow_strike_bh", "heroes/hero_queenofpain/queen_shadow_strike_bh", LUA_MODIFIER_MOTION_NONE )

function modifier_queen_of_pain_shadow_strike_bh:OnCreated()
end

function modifier_queen_of_pain_shadow_strike_bh:OnRefresh()
end

function modifier_queen_of_pain_shadow_strike_bh:OnIntervalThink()
end

function modifier_queen_of_pain_shadow_strike_bh:GetEffectName()
	return "particles/units/heroes/hero_queenofpain/queen_shadow_strike_debuff.vpcf"
end