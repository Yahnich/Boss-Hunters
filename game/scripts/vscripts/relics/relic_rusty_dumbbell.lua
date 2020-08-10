relic_rusty_dumbbell = class(relicBaseClass)

function relic_rusty_dumbbell:OnCreated()
	if IsServer() then
		self:GetParent():ModifyAbilityPoints( 2 )
	end
end
