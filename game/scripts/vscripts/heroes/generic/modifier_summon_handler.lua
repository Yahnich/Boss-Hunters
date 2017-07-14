modifier_barrier_handler = modifier_barrier_handler or class({})

if IsServer() then
	function modifier_summon_handler:OnRemoved()
		self:GetCaster():RemoveSummon(self:GetParent())
	end
end