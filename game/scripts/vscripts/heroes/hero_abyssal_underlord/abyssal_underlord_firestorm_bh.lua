abyssal_underlord_firestorm_bh = class({})

function abyssal_underlord_firestorm_bh:IsStealable()
	return true
end

function abyssal_underlord_firestorm_bh:IsHiddenWhenStolen()
	return false
end

function abyssal_underlord_firestorm_bh:OnSpellStart()
	local caster = self:GetCaster()
	local position = self:GetCursorPosition()
	
	local waves = self:GetTalentSpecialValueFor("")
	
end