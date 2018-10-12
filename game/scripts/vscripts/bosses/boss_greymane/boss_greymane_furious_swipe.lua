boss_greymane_furious_swipe = class({})

function boss_greymane_furious_swipe:OnAbilityPhaseStart()
	ParticleManager:FireLinearWarningParticle(	self:GetCaster():GetAbsOrigin(), 
												self:GetCaster():GetAbsOrigin() + CalculateDirection( self:GetCursorPosition(), self:GetCaster() ) * self:GetCaster():GetAttackRange() * 2,
												self:GetSpecialValueFor("cone_angle") * 2)
	return true
end

function boss_greymane_furious_swipe:OnSpellStart()
	local caster = self:GetCaster()
	local direction = CalculateDirection( self:GetCursorPosition(), caster )
	
	local duration = self:GetSpecialValueFor("duration")
	
	caster:EmitSound("Hero_Riki.Backstab")
	for _, enemy in ipairs( caster:FindEnemyUnitsInCone(direction, caster:GetAbsOrigin(), self:GetSpecialValueFor("cone_angle"), self:GetCaster():GetAttackRange() * 2) ) do
		if not enemy:TriggerSpellAbsorb(self) then
			ParticleManager:FireParticle("particles/units/heroes/hero_riki/riki_backstab.vpcf", PATTACH_POINT_FOLLOW, enemy)
			caster:PerformGenericAttack( enemy, true )
			enemy:AddNewModifier( caster, self, "modifier_boss_greymane_furious_swipe", {duration = duration})
		end
	end
end

modifier_boss_greymane_furious_swipe = class({})
LinkLuaModifier("modifier_boss_greymane_furious_swipe", "bosses/boss_greymane/boss_greymane_furious_swipe", LUA_MODIFIER_MOTION_NONE)

function modifier_boss_greymane_furious_swipe:OnCreated()
	self.as = self:GetSpecialValueFor("as_slow")
	self.ms = self:GetSpecialValueFor("ms_slow")
	self.bleed = self:GetSpecialValueFor("bleed")
	if self.bleed > 0 then
		self:StartIntervalThink(1)
	end
end

function modifier_boss_greymane_furious_swipe:OnIntervalThink()
	self:GetAbility():DealDamage( self:GetCaster(), self:GetParent(), self.bleed, {damage_type = DAMAGE_TYPE_PHYSICAL} )
end

function modifier_boss_greymane_furious_swipe:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_boss_greymane_furious_swipe:GetModifierMoveSpeedBonus_Percentage()
	return self.ms
end

function modifier_boss_greymane_furious_swipe:GetModifierAttackSpeedBonus_Constant()
	return self.as
end

function modifier_boss_greymane_furious_swipe:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end