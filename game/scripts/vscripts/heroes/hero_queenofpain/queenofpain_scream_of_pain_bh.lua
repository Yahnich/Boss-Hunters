queenofpain_scream_of_pain_bh = class({})

function queenofpain_scream_of_pain_bh:OnSpellStart()
	local caster = self:GetCaster()
	
	local radius = self:GetTalentSpecialValueFor("area_of_effect")
	local speed = self:GetTalentSpecialValueFor("projectile_speed")
	for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), radius ) ) do
		self:FireTrackingProjectile("particles/units/heroes/hero_queenofpain/queen_scream_of_pain.vpcf", enemy, speed)
	end
	ParticleManager:FireParticle("particles/units/heroes/hero_queenofpain/queen_scream_of_pain_owner.vpcf", PATTACH_POINT_FOLLOW, caster)
	caster:EmitSound("Hero_QueenOfPain.ScreamOfPain")
end

function queenofpain_scream_of_pain_bh:OnProjectileHit( target, position )
	if target then
		local caster = self:GetCaster()
		local damage = self:DealDamage( caster, target )
		if caster:HasTalent("special_bonus_unique_queenofpain_scream_of_pain_1") then
			local heal = caster:FindTalentValue("special_bonus_unique_queenofpain_scream_of_pain_1")
			if not target:IsRoundNecessary() then
				heal = caster:FindTalentValue("special_bonus_unique_queenofpain_scream_of_pain_1", "value2" )
			end
			caster:HealEvent( damage * heal / 100, self, caster )
		end
		if caster:HasTalent("special_bonus_unique_queenofpain_scream_of_pain_2") then
			target:AddNewModifier( caster, self, "modifier_queenofpain_scream_of_pain_bh_talent", {duration = caster:FindTalentValue("special_bonus_unique_queenofpain_scream_of_pain_2", "duration" )})
		end
	end
end

modifier_queenofpain_scream_of_pain_bh_talent = class({})
LinkLuaModifier( "modifier_queenofpain_scream_of_pain_bh_talent", "heroes/hero_queenofpain/queenofpain_scream_of_pain_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_queenofpain_scream_of_pain_bh_talent:OnCreated()
	self.red = self:GetCaster():FindTalentValue("special_bonus_unique_queenofpain_scream_of_pain_2")
end

function modifier_queenofpain_scream_of_pain_bh_talent:OnRefresh()
	self.red = self:GetCaster():FindTalentValue("special_bonus_unique_queenofpain_scream_of_pain_2")
end

function modifier_queenofpain_scream_of_pain_bh_talent:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE}
end

function modifier_queenofpain_scream_of_pain_bh_talent:GetModifierTotalDamageOutgoing_Percentage(params)
	if IsClient() then
		return self.red
	else
		if params.target == self:GetCaster() then
			return self.red
		end
	end
end