leshrac_lightning_storm_bh = class({})

function leshrac_lightning_storm_bh:IsStealable()
	return true
end

function leshrac_lightning_storm_bh:IsHiddenWhenStolen()
	return false
end

function leshrac_lightning_storm_bh:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	
	self:Zap( target )
end

function leshrac_lightning_storm_bh:Zap( target )
end