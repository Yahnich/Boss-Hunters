antimage_void_of_hatred = class ({})

function antimage_void_of_hatred:GetAOERadius()
	return self:GetTalentSpecialValueFor("radius")
end

function antimage_void_of_hatred:OnAbilityPhaseStart()
	self:GetCaster():EmitSound("Hero_Antimage.ManaVoidCast")
	return true
end

function antimage_void_of_hatred:OnAbilityPhaseInterrupted()
	self:GetCaster():StopSound("Hero_Antimage.ManaVoidCast")
end

function antimage_void_of_hatred:GetCastAnimation()
	return ACT_DOTA_CAST_ABILITY_4
end

function antimage_void_of_hatred:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	
	local baseDmg = self:GetTalentSpecialValueFor("base_damage")
	local stackDmg = self:GetTalentSpecialValueFor("stack_damage")
	local stunDur = self:GetTalentSpecialValueFor("ministun")
	local radius = self:GetTalentSpecialValueFor("radius")
	
	local damage = baseDmg
	local magus = target:FindModifierByNameAndCaster("modifier_antimage_magus_breaker_debuff", caster)
	local breaker = caster:FindModifierByNameAndCaster("modifier_antimage_ender_of_magic_buff", caster)
	if magus then 
		damage = damage + stackDmg * magus:GetStackCount()
		magus:Destroy()
	end
	if breaker then
		damage = damage + stackDmg * breaker:GetStackCount()
		breaker:Destroy()
	end
	
	self:Stun( target, stunDur )
	
	ParticleManager:FireParticle("particles/antimage_ragevoid.vpcf", PATTACH_POINT_FOLLOW, target, {[1] = Vector(radius,1,1)})
	target:EmitSound("Hero_Antimage.ManaVoid")
	
	local talent = caster:HasTalent("special_bonus_unique_antimage_void_of_hatred_2")
	local silenceDur = caster:FindTalentValue("special_bonus_unique_antimage_void_of_hatred_2")
	for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( target:GetAbsOrigin(), radius ) ) do
		self:DealDamage( caster, enemy, damage )
		if talent then
			enemy:Silence( self, caster, silenceDur )
		end
	end
end