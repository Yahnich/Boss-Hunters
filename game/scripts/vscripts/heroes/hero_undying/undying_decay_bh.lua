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
	for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( position, radius) ) do
		local str = TernaryOperator( bossStr, enemy:IsRoundBoss(), mobStr )
		for i = 1, str do
			caster:AddNewModifier(caster, self, "modifier_undying_decay_bh", {duration = duration})
		end
		self:DealDamage( caster, enemy, damage )
	end
	
	ParticleManager:FireParticle(pEffect, PATTACH_WORLDORIGIN, nil, {[0] = position})
	EmitSoundOnLocationWithCaster( position, sEffect, caster )
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
	return {MODIFIER_PROPERTY_STRENGTH_BONUS}
end

function modifier_undying_decay_bh:GetStrength()
	return self:GetStackCount()
end