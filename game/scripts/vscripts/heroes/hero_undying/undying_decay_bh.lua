undying_decay_bh = class({})

function undying_decay_bh:GetAOERadius()
	return self:GetTalentSpecialValueFor("radius")
end

function undying_decay_bh:OnSpellStart()
	local caster = self:GetCaster()
	local position = self:GetCursorPosition()
	
	
	local damage = self:GetTalentSpecialValueFor("damage")
	local duration = self:GetTalentSpecialValueFor("duration")
	local radius = self:GetTalentSpecialValueFor("radius")
	local bossStr = TernaryOperator( self:GetTalentSpecialValueFor("str_per_boss"), caster:HasScepter(), self:GetTalentSpecialValueFor("scepter_str_per_boss") )
	local mobStr = self:GetTalentSpecialValueFor("str_per_mob")
	
	local modifierName = TernaryOperator("modifier_undying_decay_bh_talent", caster:HasTalent("special_bonus_unique_undying_decay_2"), "modifier_undying_decay_bh")
	for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( position, radius) ) do
		local str = TernaryOperator( bossStr, enemy:IsRoundBoss(), mobStr )
		for i = 1, str do
			caster:AddNewModifier(caster, self, modifierName, {duration = duration})
		end
		self:DealDamage( caster, enemy, damage )
		ParticleManager:FireRopeParticle("particles/units/heroes/hero_undying/undying_decay_strength_xfer.vpcf", PATTACH_POINT_FOLLOW, enemy, caster)
	end
	
	ParticleManager:FireParticle("particles/units/heroes/hero_undying/undying_decay.vpcf", PATTACH_WORLDORIGIN, nil, {[0] = position, [1] = Vector(radius,0,0)})
	EmitSoundOnLocationWithCaster( position, "Hero_Undying.Decay.Cast", caster )
end

modifier_undying_decay_bh = class({})
LinkLuaModifier("modifier_undying_decay_bh", "heroes/hero_undying/undying_decay_bh", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
	function modifier_undying_decay_bh:OnCreated()
		self:AddIndependentStack( self:GetRemainingTime() )
	end
	
	function modifier_undying_decay_bh:OnRefresh()
		self:AddIndependentStack( self:GetRemainingTime() )
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

modifier_undying_decay_bh_talent = class({})
LinkLuaModifier("modifier_undying_decay_bh_talent", "heroes/hero_undying/undying_decay_bh", LUA_MODIFIER_MOTION_NONE)


function modifier_undying_decay_bh_talent:OnCreated()
	self.dmg = self:GetCaster():FindTalentValue("special_bonus_unique_undying_decay_2")
	if IsServer() then self:AddIndependentStack( self:GetRemainingTime() ) end
end

function modifier_undying_decay_bh_talent:OnRefresh()
	self.dmg = self:GetCaster():FindTalentValue("special_bonus_unique_undying_decay_2")
	if IsServer() then self:AddIndependentStack( self:GetRemainingTime() ) end
end


function modifier_undying_decay_bh_talent:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
			MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE}
end

function modifier_undying_decay_bh_talent:GetModifierBonusStats_Strength()
	return self:GetStackCount()
end

function modifier_undying_decay_bh_talent:GetModifierPreAttack_BonusDamage()
	return self:GetStackCount() * self.dmg
end

function modifier_undying_decay_bh_talent:GetEffectName()
	return "particles/units/heroes/hero_undying/undying_decay_strength_buff.vpcf"
end