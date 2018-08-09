sven_storm_bolt_bh = class({})

function sven_storm_bolt_bh:GetAOERadius()
	local radius = self:GetTalentSpecialValueFor("bolt_aoe") * math.max(1, self:GetCaster():FindTalentValue("special_bonus_unique_sven_storm_bolt_1"))
	return radius
end

function sven_storm_bolt_bh:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	
	local bolt_speed = self:GetTalentSpecialValueFor("bolt_speed")
	local vision_radius = self:GetTalentSpecialValueFor("vision_radius")
	if caster:HasTalent("special_bonus_unique_sven_storm_bolt_1") then
		local radius = self:GetTalentSpecialValueFor("bolt_aoe") * caster:FindTalentValue("special_bonus_unique_sven_storm_bolt_1")
		for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( target:GetAbsOrigin(), radius ) ) do
			if enemy ~= target then
				enemy:ApplyKnockBack( target:GetAbsOrigin(), 0.25, 0.25, -math.abs(CalculateDistance( enemy, target ) - 150) )
			end
		end
	end
	caster:EmitSound("Hero_Sven.StormBolt")
	self:FireTrackingProjectile("particles/units/heroes/hero_sven/sven_spell_storm_bolt.vpcf", target, bolt_speed, {}, 0, false, true, vision_radius)
end

function sven_storm_bolt_bh:OnProjectileHit( target, position )
	if target then
		local caster = self:GetCaster()
		local damage = self:GetAbilityDamage()
		local stunDur = self:GetTalentSpecialValueFor("bolt_stun_duration")
		local radius = self:GetTalentSpecialValueFor("bolt_aoe")
		
		local talent = caster:HasTalent("special_bonus_unique_sven_storm_bolt_2")
		local tDuration = caster:FindTalentValue("special_bonus_unique_sven_storm_bolt_2", "duration")
		for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( target:GetAbsOrigin(), radius ) ) do
			self:Stun( enemy, stunDur )
			self:DealDamage( caster, target, damage )
			if talent then
				caster:AddNewModifier(caster, self, "modifier_sven_storm_bolt_talent", {duration = tDuration})
			end
		end
		target:EmitSound("Hero_Sven.StormBoltImpact")
	end
end

modifier_sven_storm_bolt_talent = class({})
LinkLuaModifier("modifier_sven_storm_bolt_talent", "heroes/hero_sven/sven_storm_bolt_bh", LUA_MODIFIER_MOTION_NONE)


function modifier_sven_storm_bolt_talent:OnCreated()
	self.str = self:GetCaster():FindTalentValue("special_bonus_unique_sven_storm_bolt_2")
	if IsServer() then
		self:SetStackCount(1)
	end
end
	
function modifier_sven_storm_bolt_talent:OnRefresh()
	self.str = self:GetCaster():FindTalentValue("special_bonus_unique_sven_storm_bolt_2")
	if IsServer() then
		self:GetCaster():CalculateStatBonus()
		self:AddIndependentStack(self:GetRemainingTime())
	end
end

function modifier_sven_storm_bolt_talent:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS}
end

function modifier_sven_storm_bolt_talent:GetModifierBonusStats_Strength()
	return self.str * self:GetStackCount()
end
