modifier_boss_damagedecrease = class({})

function modifier_boss_damagedecrease:IsHidden()
	return true
end

function modifier_boss_damagedecrease:OnCreated()
	
end


function modifier_boss_damagedecrease:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}
	return funcs
end

--------------------------------------------------------------------------------

function modifier_boss_damagedecrease:OnTakeDamage( params )
	return -40
end


