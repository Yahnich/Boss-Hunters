huskar_sacred_inferno = class({})

function huskar_sacred_inferno:GetCooldown( iLvl )
	local cd = self.BaseClass.GetCooldown( self, iLvl )
	if self:GetCaster():HasTalent("special_bonus_unique_huskar_ignited_spears_1") then
		cd = 0
	end
	return cd
end

function huskar_sacred_inferno:GetIntrinsicModifierName()
	return "modifier_huskar_sacred_inferno_passive"
end

function huskar_sacred_inferno:ShouldUseResources()
	return true
end

function huskar_sacred_inferno:FireSacredInferno(target)
	self:FireTrackingProjectile("particles/econ/items/templar_assassin/templar_assassin_focal/templar_assassin_meld_focal_attack.vpcf", target, self:GetCaster():GetProjectileSpeed(), nil, DOTA_PROJECTILE_ATTACHMENT_ATTACK_1)
end

function huskar_sacred_inferno:OnProjectileHit(target, position)
	if target then
		local caster = self:GetCaster()
		local spears = caster:FindAbilityByName("huskar_ignited_spears")
		local bsDebuff = target:FindModifierByName("modifier_huskar_ignited_spears_debuff")
		local stacks = 1
		if bsDebuff then 
			stacks = bsDebuff:GetStackCount()
		end
		
		local damage = stacks * spears:GetSpecialValueFor("burn_damage")
		
		local radius = self:GetSpecialValueFor("radius")
		ParticleManager:FireParticle("particles/huskar_flashfire_hit.vpcf", PATTACH_POINT_FOLLOW, target, {[1] = Vector(radius,radius,radius)})
		
		local units = FindUnitsInRadius(caster:GetTeam(),
								  target:GetAbsOrigin(),
								  nil,
								  radius,
								  DOTA_UNIT_TARGET_TEAM_ENEMY,
								  DOTA_UNIT_TARGET_ALL,
								  DOTA_UNIT_TARGET_FLAG_NONE,
								  FIND_ANY_ORDER,
								  false)
		for _,unit in pairs(units) do
			spears:BurnTarget( unit )
			self:DealDamage(caster, unit, damage)
			ParticleManager:FireParticle("particles/huskar_flashfire_spark.vpcf", PATTACH_POINT_FOLLOW, unit)
		end
		self:SetCooldown()
	end
end

modifier_huskar_sacred_inferno_passive = class({})
LinkLuaModifier("modifier_huskar_sacred_inferno_passive", "heroes/hero_huskar/huskar_sacred_inferno", LUA_MODIFIER_MOTION_NONE)

function modifier_huskar_sacred_inferno_passive:OnCreated()
	self.chance = self:GetSpecialValueFor("chance")
end

function modifier_huskar_sacred_inferno_passive:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK}
end

function modifier_huskar_sacred_inferno_passive:OnAttack(params)
	if params.attacker == self:GetParent() and RollPercentage( self.chance ) and self:GetAbility():IsCooldownReady() then
		self:GetAbility():FireSacredInferno(params.target)
	end
end

function modifier_huskar_sacred_inferno_passive:IsHidden()
	return true
end