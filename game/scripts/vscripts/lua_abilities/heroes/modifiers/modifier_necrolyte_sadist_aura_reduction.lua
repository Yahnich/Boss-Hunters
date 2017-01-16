modifier_necrolyte_sadist_aura_reduction = class({})


function modifier_necrolyte_sadist_aura_reduction:OnCreated( kv )
	self.magic_resist = self:GetAbility():GetSpecialValueFor( "bonus_magic_damage" )
end

--------------------------------------------------------------------------------

function modifier_necrolyte_sadist_aura_reduction:OnRefresh( kv )
	self.magic_resist = self:GetAbility():GetSpecialValueFor( "bonus_magic_damage" )
end

function modifier_necrolyte_sadist_aura_reduction:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
	}
	return funcs
end

--------------------------------------------------------------------------------

function modifier_necrolyte_sadist_aura_reduction:GetModifierMagicalResistanceBonus( params )
	return self.magic_resist
end

------------------------------------------------------------------------------

function modifier_necrolyte_sadist_aura_reduction:IsHidden()
	return true
end


