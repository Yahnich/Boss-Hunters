queenofpain_scream_of_pain_bh = class({})

function queenofpain_scream_of_pain_bh:GetCastRange( target, position )
	return self:GetTalentSpecialValueFor("area_of_effect")
end

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
	local caster = self:GetCaster()
	if target then
		if not target:IsSameTeam(caster) and not target:TriggerSpellAbsorb( self ) then
			local damage = self:DealDamage( caster, target )
			if caster:HasTalent("special_bonus_unique_queenofpain_scream_of_pain_1") and not target:IsMinion() then
				for _, ally in ipairs( caster:FindFriendlyUnitsInRadius( target:GetAbsOrigin(), self:GetTalentSpecialValueFor("area_of_effect") ) ) do
					self:FireTrackingProjectile("particles/units/heroes/hero_queenofpain/queen_scream_of_pain.vpcf", ally, self:GetTalentSpecialValueFor("projectile_speed"), {source = target})
				end
			end
			if caster:HasTalent("special_bonus_unique_queenofpain_scream_of_pain_2") then
				local talentDur = caster:FindTalentValue("special_bonus_unique_queenofpain_scream_of_pain_2", "duration")
				target:AddNewModifier( caster, self, "modifier_queenofpain_scream_of_pain_bh_talent_debuff", {duration = talentDur})
				caster:AddNewModifier( caster, self, "modifier_queenofpain_scream_of_pain_bh_talent_buff", {duration = talentDur})
			end
		elseif target:IsSameTeam( caster ) then
			local heal = self:GetAbilityDamage() * caster:FindTalentValue("special_bonus_unique_queenofpain_scream_of_pain_1") / 100
			target:HealEvent( heal, self, caster )
		end
	end
end

modifier_queenofpain_scream_of_pain_bh_talent_debuff = class({})
LinkLuaModifier( "modifier_queenofpain_scream_of_pain_bh_talent_debuff", "heroes/hero_queenofpain/queenofpain_scream_of_pain_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_queenofpain_scream_of_pain_bh_talent_debuff:OnCreated()
	self:OnRefresh()
	if IsServer() then
		self:OnIntervalThink(0.1)
	end
end

function modifier_queenofpain_scream_of_pain_bh_talent_debuff:OnRefresh()
	self.attack_speed = self:GetCaster():FindTalentValue("special_bonus_unique_queenofpain_scream_of_pain_2")
	self.cdr = (self:GetCaster():FindTalentValue("special_bonus_unique_queenofpain_scream_of_pain_2", "cdr")/100) * 0.1
end

function modifier_queenofpain_scream_of_pain_bh_talent_debuff:OnIntervalThink()
	local parent = self:GetParent()
	for i = 0, parent:GetAbilityCount() - 1 do
		local ability = parent:GetAbilityByIndex( i )
		if ability and not ability:IsCooldownReady() then
			ability:ModifyCooldown( self.cdr  )
		end
	end
end

function modifier_queenofpain_scream_of_pain_bh_talent_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}
end

function modifier_queenofpain_scream_of_pain_bh_talent_debuff:GetModifierAttackSpeedBonus_Constant(params)
	return -self.attack_speed
end


modifier_queenofpain_scream_of_pain_bh_talent_buff = class({})
LinkLuaModifier( "modifier_queenofpain_scream_of_pain_bh_talent_buff", "heroes/hero_queenofpain/queenofpain_scream_of_pain_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_queenofpain_scream_of_pain_bh_talent_buff:OnCreated()
	self:OnRefresh()
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end

function modifier_queenofpain_scream_of_pain_bh_talent_buff:OnRefresh()
	self.attack_speed = self:GetCaster():FindTalentValue("special_bonus_unique_queenofpain_scream_of_pain_2")
	self.cdr = (self:GetCaster():FindTalentValue("special_bonus_unique_queenofpain_scream_of_pain_2", "cdr")/100) * 0.1
end

function modifier_queenofpain_scream_of_pain_bh_talent_buff:OnIntervalThink()
	local parent = self:GetParent()
	for i = 0, parent:GetAbilityCount() - 1 do
		local ability = parent:GetAbilityByIndex( i )
		if ability and not ability:IsCooldownReady() then
			ability:ModifyCooldown( -self.cdr  )
		end
	end
end

function modifier_queenofpain_scream_of_pain_bh_talent_buff:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}
end

function modifier_queenofpain_scream_of_pain_bh_talent_buff:GetModifierAttackSpeedBonus_Constant(params)
	return self.attack_speed
end