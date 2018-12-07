modifier_summon_handler = modifier_summon_handler or class({})

function modifier_summon_handler:OnCreated()
	self:GetParent().unitOwnerEntity = self:GetCaster()
end

if IsServer() then
	function modifier_summon_handler:OnRemoved()
		self:GetCaster():RemoveSummon(self:GetParent())
	end
end

function modifier_summon_handler:IsHidden()
	return true
end