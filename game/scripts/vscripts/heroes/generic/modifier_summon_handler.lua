modifier_summon_handler = modifier_summon_handler or class({})

if IsServer() then
	function modifier_summon_handler:OnRemoved()
		self:GetCaster():RemoveSummon(self:GetParent())
	end
end

function modifier_summon_handler:IsHidden()
	return true
end