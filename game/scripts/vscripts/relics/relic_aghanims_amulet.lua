relic_aghanims_amulet = class(relicBaseClass)

function relic_aghanims_amulet:OnCreated()
	if IsServer() then
		self.scepterBuff = self:GetParent():AddNewModifier(self:GetParent(), nil, "modifier_item_ultimate_scepter_consumed", {})
	end
end

function relic_aghanims_amulet:OnDestroy()
	if IsServer() and self.scepterBuff then
		self.scepterBuff:Destroy()
		local parent = self:GetParent()
		for i = 0, parent:GetAbilityCount() - 1 do
			local scepterAbility = parent:GetAbilityByIndex( i )
			if scepterAbility and scepterAbility.OnInventoryContentsChanged then
				scepterAbility:OnInventoryContentsChanged()
			end
		end
	end
end