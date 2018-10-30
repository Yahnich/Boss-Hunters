relic_unique_rusty_dumbbell = class(relicBaseClass)

function relic_unique_rusty_dumbbell:OnCreated()
	if IsServer() then
		self:GetParent():ModifyAttributePoints( 2 )
	end
end
