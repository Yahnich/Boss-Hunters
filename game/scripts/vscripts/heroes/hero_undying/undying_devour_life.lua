undying_devour_life = class({})

function undying_devour_life:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end

function undying_devour_life:OnSpellStart()
	self:Decay( self:GetCursorPosition() )
end

function undying_devour_life:Decay( position, radiusMod )
	local caster = self:GetCaster()
	local radius = self:GetSpecialValueFor("radius") * (radiusMod or 1)
	
	local damage = self:GetSpecialValueFor("damage")
	local duration = self:GetSpecialValueFor("duration")
	local bossStr = self:GetSpecialValueFor("str_per_boss")
	local monsterStr = self:GetSpecialValueFor("str_per_monster")
	local mobStr = self:GetSpecialValueFor("str_per_mob")
	
	for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( position, radius) ) do
		if not enemy:TriggerSpellAbsorb( self ) then
			local str = TernaryOperator( mobStr, enemy:IsMinion(), TernaryOperator( bossStr, enemy:IsBoss(), monsterStr ) ) / mobStr
			for i = 1, str do
				caster:AddNewModifier(caster, self, "modifier_undying_devour_life", {duration = duration})
			end
			self:DealDamage( caster, enemy, damage )
			local debuff = enemy:AddNewModifier( caster, self, "modifier_undying_devour_life_debuff", {} )
			if debuff then debuff:SetStackCount( debuff:GetStackCount() + str ) end
			ParticleManager:FireRopeParticle("particles/units/heroes/hero_undying/undying_devour_life_strength_xfer.vpcf", PATTACH_POINT_FOLLOW, enemy, caster)
		end
	end
	
	ParticleManager:FireParticle("particles/units/heroes/hero_undying/undying_devour_life.vpcf", PATTACH_WORLDORIGIN, nil, {[0] = position, [1] = Vector(radius,0,0)})
	EmitSoundOnLocationWithCaster( position, "Hero_Undying.Decay.Cast", caster )
end

modifier_undying_devour_life = class({})
LinkLuaModifier("modifier_undying_devour_life", "heroes/hero_undying/undying_devour_life", LUA_MODIFIER_MOTION_NONE)

function modifier_undying_devour_life:OnCreated()
	self:OnRefresh()
end

function modifier_undying_devour_life:OnRefresh()
	self.str = self:GetSpecialValueFor("str_per_mob")
	self.dmg = self:GetSpecialValueFor("attack_damage_per_stack")
	self.range = self:GetSpecialValueFor("attack_range_per_stack")
	if IsServer() then
		self:AddIndependentStack( self:GetRemainingTime() )
		self:GetParent():CalculateStatBonus()
	end
end

function modifier_undying_devour_life:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
			MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
			MODIFIER_PROPERTY_ATTACK_RANGE_BONUS 
			}
end

function modifier_undying_devour_life:GetModifierBonusStats_Strength()
	return self:GetStackCount() * self.str
end

function modifier_undying_devour_life:GetModifierPreAttack_BonusDamage()
	return self:GetStackCount() * self.dmg
end

function modifier_undying_devour_life:GetModifierAttackRangeBonus()
	return self:GetStackCount() * self.range
end

function modifier_undying_devour_life:GetEffectName()
	return "particles/units/heroes/hero_undying/undying_devour_life_strength_buff.vpcf"
end

function modifier_undying_devour_life:IsPurgable()
	return false
end

modifier_undying_devour_life_debuff = class({})
LinkLuaModifier("modifier_undying_devour_life_debuff", "heroes/hero_undying/undying_devour_life", LUA_MODIFIER_MOTION_NONE)

function modifier_undying_devour_life_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS}
end

function modifier_undying_devour_life_debuff:GetModifierExtraHealthBonus()
	return self:GetStackCount() * -25
end
