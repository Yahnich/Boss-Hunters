undying_decay_bh = class({})

function undying_decay_bh:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end

function undying_decay_bh:OnSpellStart()
	self:Decay( self:GetCursorPosition() )
end

function undying_decay_bh:Decay( position, radiusMod )
	local caster = self:GetCaster()
	local radius = self:GetSpecialValueFor("radius") * (radiusMod or 1)
	
	local damage = self:GetSpecialValueFor("damage")
	local duration = self:GetSpecialValueFor("duration")
	local bossStr = TernaryOperator( self:GetSpecialValueFor("scepter_str_per_boss"), caster:HasScepter(), self:GetSpecialValueFor("str_per_boss") )
	local monsterStr = TernaryOperator( self:GetSpecialValueFor("scepter_str_per_monster"), caster:HasScepter(), self:GetSpecialValueFor("str_per_monster") )
	local mobStr = self:GetSpecialValueFor("str_per_mob")
	
	local modifierName = TernaryOperator("modifier_undying_decay_bh_talent", caster:HasTalent("special_bonus_unique_undying_decay_2"), "modifier_undying_decay_bh")
	for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( position, radius) ) do
		if not enemy:TriggerSpellAbsorb( self ) then
			local str = TernaryOperator( mobStr, enemy:IsMinion(), TernaryOperator( bossStr, enemy:IsBoss(), monsterStr ) )
			for i = 1, str do
				caster:AddNewModifier(caster, self, modifierName, {duration = duration})
			end
			self:DealDamage( caster, enemy, damage )
			enemy:ModifyHealth( enemy:GetHealth() - GameRules:GetGameModeEntity():GetCustomAttributeDerivedStatValue( DOTA_ATTRIBUTE_STRENGTH_HP ) * str, self, true, DOTA_DAMAGE_FLAG_NONE )
			local debuff = enemy:AddNewModifier( caster, self, "modifier_undying_decay_bh_debuff", {} )
			if debuff then debuff:SetStackCount( debuff:GetStackCount() + str ) end
			ParticleManager:FireRopeParticle("particles/units/heroes/hero_undying/undying_decay_strength_xfer.vpcf", PATTACH_POINT_FOLLOW, enemy, caster)
		end
	end
	
	ParticleManager:FireParticle("particles/units/heroes/hero_undying/undying_decay.vpcf", PATTACH_WORLDORIGIN, nil, {[0] = position, [1] = Vector(radius,0,0)})
	EmitSoundOnLocationWithCaster( position, "Hero_Undying.Decay.Cast", caster )
end

modifier_undying_decay_bh = class({})
LinkLuaModifier("modifier_undying_decay_bh", "heroes/hero_undying/undying_decay_bh", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
	function modifier_undying_decay_bh:OnCreated()
		self:OnRefresh()
	end
	
	function modifier_undying_decay_bh:OnRefresh()
		self:AddIndependentStack( self:GetRemainingTime() )
		self:GetParent():CalculateStatBonus()
	end
end

function modifier_undying_decay_bh:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS}
end

function modifier_undying_decay_bh:GetModifierBonusStats_Strength()
	return self:GetStackCount()
end

function modifier_undying_decay_bh:GetEffectName()
	return "particles/units/heroes/hero_undying/undying_decay_strength_buff.vpcf"
end

function modifier_undying_decay_bh:IsPurgable()
	return false
end

modifier_undying_decay_bh_talent = class({})
LinkLuaModifier("modifier_undying_decay_bh_talent", "heroes/hero_undying/undying_decay_bh", LUA_MODIFIER_MOTION_NONE)


function modifier_undying_decay_bh_talent:OnCreated()
	self:OnRefresh()
end

function modifier_undying_decay_bh_talent:OnRefresh()
	self.dmg = self:GetCaster():FindTalentValue("special_bonus_unique_undying_decay_2")
	self.range = self:GetCaster():FindTalentValue("special_bonus_unique_undying_decay_2", "value2")
	if IsServer() then 
		self:AddIndependentStack( self:GetRemainingTime() )
		self:GetParent():CalculateStatBonus()
	end
end


function modifier_undying_decay_bh_talent:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
			MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
			MODIFIER_PROPERTY_ATTACK_RANGE_BONUS 
			}
end

function modifier_undying_decay_bh_talent:GetModifierBonusStats_Strength()
	return self:GetStackCount()
end

function modifier_undying_decay_bh_talent:GetModifierPreAttack_BonusDamage()
	return self:GetStackCount() * self.dmg
end

function modifier_undying_decay_bh_talent:GetModifierAttackRangeBonus()
	return self:GetStackCount() * self.range
end

function modifier_undying_decay_bh_talent:GetEffectName()
	return "particles/units/heroes/hero_undying/undying_decay_strength_buff.vpcf"
end

function modifier_undying_decay_bh_talent:IsPurgable()
	return false
end

modifier_undying_decay_bh_debuff = class({})
LinkLuaModifier("modifier_undying_decay_bh_debuff", "heroes/hero_undying/undying_decay_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_undying_decay_bh_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS}
end

function modifier_undying_decay_bh_debuff:GetModifierExtraHealthBonus()
	return self:GetStackCount() * -25
end
