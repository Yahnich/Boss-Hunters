modifier_movespeed_cap = class({})

function modifier_movespeed_cap:OnCreated()
	self:GetParent():HookInModifier( "GetMoveSpeedLimitBonus", self )
end

function modifier_movespeed_cap:OnDestroy()
	self:GetParent():HookOutModifier( "GetMoveSpeedLimitBonus", self )
end

function modifier_movespeed_cap:GetMoveSpeedLimitBonus( params )
    return 9999
end

function modifier_movespeed_cap:IsHidden()
    return true
end