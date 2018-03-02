modifier_blind_generic = class({})

function modifier_blind_generic:OnCreated(kv)
	self.miss = kv.miss or 0
end

function modifier_blind_generic:GetEffectName()
	return "particles/units/heroes/hero_keeper_of_the_light/keeper_of_the_light_blinding_light_debuff.vpcf"
end

function modifier_blind_generic:GetTexture()
	return "keeper_of_the_light_blinding_light"
end

function modifier_blind_generic:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_blind_generic:CheckState()
	local state = { [MODIFIER_STATE_BLIND] = true}
	return state
end

function modifier_blind_generic:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MISS_PERCENTAGE
	}
	return funcs
end

function modifier_blind_generic:GetModifierMiss_Percentage()
	return self.miss
end

function modifier_blind_generic:IsPurgable()
	return true
end

function modifier_blind_generic:IsPurgeException()
	return true
end

function modifier_blind_generic:IsDebuff()
	return true
end