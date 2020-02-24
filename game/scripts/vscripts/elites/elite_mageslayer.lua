elite_mageslayer = class({})

function elite_mageslayer:GetIntrinsicModifierName()
	return "modifier_elite_mageslayer"
end

modifier_elite_mageslayer = class({})
LinkLuaModifier("modifier_elite_mageslayer", "elites/elite_mageslayer", LUA_MODIFIER_MOTION_NONE)

function modifier_elite_mageslayer:OnCreated()
	self:OnRefresh()
	if IsServer() then
		self:AddEffect( ParticleManager:CreateParticle( "particles/units/elite_warning_defense_overhead.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent() ) )
	end
end

function modifier_elite_mageslayer:OnRefresh()
	self.mr = self:GetSpecialValueFor("bonus_mr")
end

function modifier_elite_mageslayer:DeclareFunctions()
	return {MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS
			}
end

function modifier_elite_mageslayer:GetModifierMagicalResistanceBonus()
	return self.mr
end

function relicBaseClass:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end

function relicBaseClass:IsHidden()
	return true
end