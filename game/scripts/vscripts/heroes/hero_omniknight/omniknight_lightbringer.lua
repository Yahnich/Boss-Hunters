omniknight_lightbringer = class({})

function omniknight_lightbringer:GetCooldown(iLvl )
	if self:GetCaster():HasScepter() and self:GetCaster():HasModifier("modifier_omniknight_guardian_angel_bh") then
		return 0
	else
		return self.BaseClass.GetCooldown( self, iLvl )
	end
end

function omniknight_lightbringer:ShouldUseResources()
	return true
end

function omniknight_lightbringer:GetIntrinsicModifierName()
	return "modifier_omniknight_lightbringer"
end

modifier_omniknight_lightbringer = class({})
LinkLuaModifier("modifier_omniknight_lightbringer", "heroes/hero_omniknight/omniknight_lightbringer", LUA_MODIFIER_MOTION_NONE)

function modifier_omniknight_lightbringer:OnCreated()
	self.radius = self:GetTalentSpecialValueFor("damage_radius")
	self.conversion = self:GetTalentSpecialValueFor("conversion") / 100
end

function modifier_omniknight_lightbringer:OnRefresh()
	self:OnCreated()
end

function modifier_omniknight_lightbringer:DeclareFunctions()
	return {MODIFIER_EVENT_ON_TAKEDAMAGE}
end

function modifier_omniknight_lightbringer:OnTakeDamage(params)
	if params.attacker and params.attacker ~= self:GetParent() or params.original_damage <= 0 or params.inflictor == self:GetAbility() or not self:GetAbility():IsCooldownReady() or self:GetCaster():PassivesDisabled() then
		return
	else
		local countsAsAttack = ( params.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK ) or HasBit( params.damage_flags, DOTA_DAMAGE_FLAG_PROPERTY_FIRE )
		local spellValid = true
		local spellValidTargeting = false
		local spellHasTarget = false
		if params.inflictor then
			local abilityBehavior = params.inflictor:GetBehavior()
			spellValidTargeting =  HasBit( abilityBehavior, DOTA_ABILITY_BEHAVIOR_UNIT_TARGET) and not HasBit( abilityBehavior, DOTA_ABILITY_BEHAVIOR_AOE) 
			spellHasTarget = ( params.unit == params.inflictor:GetCursorTarget() or not params.inflictor:GetCursorTarget() )
			spellValid = ( spellValidTargeting and spellHasTarget ) or ( params.inflictor.HasAreaDamage and params.inflictor:HasAreaDamage() )
		end
		if countsAsAttack or spellValid then
			local healing = params.original_damage * self.conversion
			if healing > 0 then
				for _, ally in ipairs( params.attacker:FindFriendlyUnitsInRadius( params.unit:GetAbsOrigin(), self.radius ) ) do
					ally:HealEvent( healing, self:GetAbility(), params.attacker )
				end
			end
			ParticleManager:FireParticle("particles/units/heroes/hero_omniknight/omniknight_purification.vpcf", PATTACH_POINT_FOLLOW,  params.unit, {[1] = Vector(self.radius, 0, 0), [2] =  params.unit:GetAbsOrigin()})
			self:GetAbility():SetCooldown()
		end
	end
end

function modifier_omniknight_lightbringer:OnHeal(params)
	if params.amount <= 0 or params.source == self:GetAbility() or not self:GetAbility():IsCooldownReady() or self:GetCaster():PassivesDisabled() then
		return
	else
		local damage = params.original_amount * self.conversion
		if damage > 0 then
			for _, enemy in ipairs( params.unit:FindEnemyUnitsInRadius( params.target:GetAbsOrigin(), self.radius ) ) do
				self:GetAbility():DealDamage( self:GetCaster(), enemy, damage )
			end
		end
		ParticleManager:FireParticle("particles/units/heroes/hero_omniknight/omniknight_purification.vpcf", PATTACH_POINT_FOLLOW, params.target, {[1] = Vector(self.radius, 0, 0), [2] = params.target:GetAbsOrigin()})
		self:GetAbility():SetCooldown()
	end
end

function modifier_omniknight_lightbringer:IsHidden()
	return true
end