luna_moon_glaive_bh = class({})

function luna_moon_glaive_bh:GetIntrinsicModifierName()
	return "modifier_luna_moon_glaive_bh"
end

function luna_moon_glaive_bh:LaunchMoonGlaive(target, damage, bounces, source)
	local caster = self:GetCaster()
	local hSource = source or caster
	local extraData = {damage = damage, bounces = bounces}
	self:FireTrackingProjectile( caster:GetRangedProjectileName(), target, caster:GetProjectileSpeed(), {extraData = extraData, source = hSource, origin = hSource:GetAbsOrigin() })
end

function luna_moon_glaive_bh:OnProjectileHit_ExtraData( target, position, extraData )
	if target then
		local caster = self:GetCaster()
		
		local damage = tonumber(extraData.damage)
		local bounces = tonumber(extraData.bounces) or 0
		self:DealDamage(caster, target, damage, {damage_type = DAMAGE_TYPE_PHYSICAL, damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL})
		
		if bounces > 0 then
			local radius = self:GetTalentSpecialValueFor("range")
			local reduction = (100 - self:GetTalentSpecialValueFor("damage_reduction_percent")) / 100
			
			for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( target:GetAbsOrigin(), radius, {flag = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES} ) ) do
				if enemy ~= target then
					self:LaunchMoonGlaive(enemy, damage * reduction, bounces - 1, target)
					break
				end
			end
		end
	end
end

modifier_luna_moon_glaive_bh = class({})
LinkLuaModifier( "modifier_luna_moon_glaive_bh", "heroes/hero_luna/luna_moon_glaive_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_luna_moon_glaive_bh:OnCreated()
	self.bounces = self:GetTalentSpecialValueFor("bounces")
	self.radius = self:GetTalentSpecialValueFor("range")
end

function modifier_luna_moon_glaive_bh:DeclareFunctions()
	return {MODIFIER_EVENT_ON_TAKEDAMAGE}
end

function modifier_luna_moon_glaive_bh:OnTakeDamage(params)
	if params.attacker == self:GetParent() and params.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK and self:GetParent():GetHealth() > 0 and not params.inflictor then
		for _, enemy in ipairs( params.attacker:FindEnemyUnitsInRadius( params.unit:GetAbsOrigin(), self.radius, {flag = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES} ) ) do
			if enemy ~= params.unit then
				self:GetAbility():LaunchMoonGlaive(enemy, params.damage, self.bounces, params.unit)
				break
			end
		end
	end
end

function modifier_luna_moon_glaive_bh:IsHidden()
	return true
end