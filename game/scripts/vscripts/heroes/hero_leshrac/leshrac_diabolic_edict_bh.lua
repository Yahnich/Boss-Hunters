leshrac_diabolic_edict_bh = class({})

function leshrac_diabolic_edict_bh:IsStealable()
	return true
end

function leshrac_diabolic_edict_bh:IsHiddenWhenStolen()
	return false
end

function leshrac_diabolic_edict_bh:GetCastRange( target, position )
	return self:GetSpecialValueFor("radius")
end

function leshrac_diabolic_edict_bh:GetBehavior()
	if self:GetCaster():HasTalent("special_bonus_unique_leshrac_diabolic_edict_1") then
		return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
	else
		return DOTA_ABILITY_BEHAVIOR_NO_TARGET
	end
end

function leshrac_diabolic_edict_bh:CastFilterResultTarget( target )
	return UnitFilter( target, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_NONE, self:GetCaster():GetTeamNumber() )
end

function leshrac_diabolic_edict_bh:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget() or caster
	
	target:AddNewModifier( caster, self, "modifier_leshrac_diabolic_edict_bh", {duration = self:GetSpecialValueFor("duration_tooltip")})
end

modifier_leshrac_diabolic_edict_bh = class({})
LinkLuaModifier("modifier_leshrac_diabolic_edict_bh", "heroes/hero_leshrac/leshrac_diabolic_edict_bh", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
	function modifier_leshrac_diabolic_edict_bh:OnCreated()
		self.radius = self:GetSpecialValueFor("radius")
		self.damage = self:GetAbility():GetAbilityDamage() + self:GetParent():GetAverageTrueAttackDamage( self:GetParent() ) * self:GetCaster():FindTalentValue("special_bonus_unique_leshrac_diabolic_edict_2") / 100
		self.tick = self:GetSpecialValueFor("duration_tooltip") / self:GetSpecialValueFor("num_explosions")
		self:StartIntervalThink( self.tick )
		
		self:GetCaster():StopSound("Hero_Leshrac.Diabolic_Edict_lp")
		self:GetCaster():EmitSound("Hero_Leshrac.Diabolic_Edict_lp")
	end
	
	function modifier_leshrac_diabolic_edict_bh:OnIntervalThink()
		local caster = self:GetCaster()
		local parent = self:GetParent()
		local ability = self:GetAbility()
		for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( parent:GetAbsOrigin(), self.radius, {flag = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES} ) ) do
			ability:DealDamage( caster, enemy, self.damage )
			ParticleManager:FireParticle("particles/units/heroes/hero_leshrac/leshrac_diabolic_edict.vpcf", PATTACH_ABSORIGIN_FOLLOW, enemy, {[1] = "attach_hitloc"})
			enemy:EmitSound("Hero_Leshrac.Diabolic_Edict")
			return
		end
		ParticleManager:FireParticle("particles/units/heroes/hero_leshrac/leshrac_diabolic_edict.vpcf", PATTACH_WORLDORIGIN, nil, {[1] = parent:GetAbsOrigin() + ActualRandomVector( self.radius, 100 ) })
	end
	
	function modifier_leshrac_diabolic_edict_bh:OnRemoved()
		self:GetCaster():StopSound("Hero_Leshrac.Diabolic_Edict_lp")
	end
end

function modifier_leshrac_diabolic_edict_bh:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end