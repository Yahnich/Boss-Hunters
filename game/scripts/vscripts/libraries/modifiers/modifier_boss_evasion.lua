modifier_boss_evasion = class({})

function modifier_boss_evasion:OnCreated()
	if IsServer() then
		self:StartIntervalThink(210 - GameRules:GetGameDifficulty() * 15)
	end
end

function modifier_boss_evasion:OnIntervalThink()
	self:StartIntervalThink(-1)
	self:GetParent():EmitSound("hero_bloodseeker.rupture.cast")
	self:GetParent():AddNewModifier(nil, nil, "modifier_boss_hard_enrage", {})
end

function modifier_boss_evasion:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_EVASION_CONSTANT,
    }

    return funcs
end

function modifier_boss_evasion:GetModifierEvasion_Constant()
  return math.min( 75, math.max( 10, self:GetStackCount() ) )
end

function modifier_boss_evasion:IsHidden()
    return true
end

function modifier_boss_evasion:IsPurgable()
	return false
end