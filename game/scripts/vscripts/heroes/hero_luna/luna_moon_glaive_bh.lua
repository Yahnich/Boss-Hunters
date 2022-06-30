luna_moon_glaive_bh = class({})

function luna_moon_glaive_bh:GetIntrinsicModifierName()
	return "modifier_luna_moon_glaive_bh"
end

function luna_moon_glaive_bh:LaunchMoonGlaive(target, damage, bounces, source)
	local caster = self:GetCaster()
	local hSource = source or caster
	
	local extraData = {damage = damage or 0, bounces = bounces or self:GetTalentSpecialValueFor("bounces"), hitUnits = {}}
	local projID = self:FireTrackingProjectile( caster:GetRangedProjectileName(), target, caster:GetProjectileSpeed(), {extraData = extraData, source = hSource, origin = hSource:GetAbsOrigin() })
	
	self.glaives = self.glaives or {}
	self.glaives[projID] = extraData
	return projID
end

function luna_moon_glaive_bh:OnProjectileHitHandle( target, position, projectileID )
	if target then
		local caster = self:GetCaster()
		local projectileData = self.glaives[projectileID]
		
		local talent1 = caster:HasTalent("special_bonus_unique_luna_moon_glaive_1")
		
		local damage = tonumber(projectileData.damage)
		local bounces = tonumber(projectileData.bounces) or 0
		local hitUnits = projectileData.hitUnits
		local triggeredTalent = projectileData.triggeredTalent
		
		hitUnits[target] = (hitUnits[target] or 0) + 1
		caster:PerformAbilityAttack(target, false, self, -damage, true, true)
		
		
		if talent1 and not triggeredTalent then
			if hitUnits[target] == caster:FindTalentValue("special_bonus_unique_luna_moon_glaive_1") then
				self:GenerateLucentBeam( target )
				triggeredTalent = true
			end
		end
		
		if bounces > 0 then
			local radius = self:GetTalentSpecialValueFor("range")
			local reduction = (100 - self:GetTalentSpecialValueFor("damage_reduction_percent")) / 100
			local reducedDamage = ((100 - damage)/100 * reduction)
			
			for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( target:GetAbsOrigin(), radius, {flag = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES} ) ) do
				if enemy ~= target then
					local newID = self:LaunchMoonGlaive(enemy, (1-reducedDamage)*100, bounces - 1, target)
					self.glaives[newID].hitUnits = hitUnits
					self.glaives[newID].triggeredTalent = triggeredTalent
					break
				end
			end
		-- elseif talent1 and not triggeredTalent then
			-- self:GenerateLucentBeam( target )
		end
		self.glaives[projectileID] = nil
	end
end

function luna_moon_glaive_bh:GenerateLucentBeam( target )
	local caster = self:GetCaster()
	local lucent = caster:FindAbilityByName("luna_lucent_beam_bh")
	if lucent and lucent:GetLevel() > 0 then
		lucent:LucentBeam( target, false )
	end
end

modifier_luna_moon_glaive_bh = class({})
LinkLuaModifier( "modifier_luna_moon_glaive_bh", "heroes/hero_luna/luna_moon_glaive_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_luna_moon_glaive_bh:OnCreated()
	self.bounces = self:GetTalentSpecialValueFor("bounces")
	self.radius = self:GetTalentSpecialValueFor("range")
	self.reduction = -self:GetTalentSpecialValueFor("damage_reduction_percent")
end

function modifier_luna_moon_glaive_bh:OnRefresh()
	self.bounces = self:GetTalentSpecialValueFor("bounces")
	self.radius = self:GetTalentSpecialValueFor("range")
	self.reduction = -self:GetTalentSpecialValueFor("damage_reduction_percent")
end

function modifier_luna_moon_glaive_bh:DeclareFunctions()
	return { MODIFIER_EVENT_ON_ATTACK_LANDED }
end

function modifier_luna_moon_glaive_bh:OnAttackLanded(params)
	if params.attacker == self:GetParent() and self:GetParent():GetHealth() > 0 then
		for _, enemy in ipairs( params.attacker:FindEnemyUnitsInRadius( params.target:GetAbsOrigin(), self.radius, {flag = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES} ) ) do
			if enemy ~= params.target then
				self:GetAbility():LaunchMoonGlaive(enemy, -self.reduction, self.bounces - 1, params.target)
				break
			end
		end
	end
end

function modifier_luna_moon_glaive_bh:IsHidden()
	return true
end