relic_cursed_mysterious_stone = class({})

function relic_cursed_mysterious_stone:OnIntervalThink()
	self:SetDuration(-1, true)
	self:StartIntervalThink(-1)
end

function relic_cursed_mysterious_stone:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING, MODIFIER_PROPERTY_ABSORB_SPELL  }
end

function relic_cursed_mysterious_stone:GetModifierStatusResistanceStacking()
	return -50
end

function relic_cursed_mysterious_stone:GetAbsorbSpell(params)
	if self:GetDuration() == -1 and params.ability:GetCaster():GetTeam() ~= self:GetParent():GetTeam() then
		ParticleManager:FireParticle( "particles/items_fx/immunity_sphere.vpcf", PATTACH_POINT_FOLLOW, self:GetParent() )
		self:SetDuration(12.1, true)
		self:StartIntervalThink(12)
		return 1
	end
end


function relic_cursed_mysterious_stone:IsHidden()
	return true
end

function relic_cursed_mysterious_stone:IsPurgable()
	return false
end

function relic_cursed_mysterious_stone:RemoveOnDeath()
	return false
end

function relic_cursed_mysterious_stone:IsPermanent()
	return true
end

function relic_cursed_mysterious_stone:AllowIllusionDuplicate()
	return true
end