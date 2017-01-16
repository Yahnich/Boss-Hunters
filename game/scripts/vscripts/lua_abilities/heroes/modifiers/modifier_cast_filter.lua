modifier_cast_filter = class({})

function modifier_cast_filter:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ABILITY_START
	}
	return funcs
end

--------------------------------------------------------------------------------

function modifier_cast_filter:OnAbilityStart( params )
	if IsServer() then
		if params.unit == self:GetParent() then
			self:GetParent():Interrupt()
			FireGameEvent( 'custom_error_show', { player_ID = self:GetParent():GetPlayerOwnerID(), _error = "FUCKED"} )
		end
	end
end

------------------------------------------------------------------------------

function modifier_cast_filter:RemoveOnDeath()
	return false
end


