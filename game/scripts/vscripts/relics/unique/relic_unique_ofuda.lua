relic_unique_ofuda = class(relicBaseClass)

function relic_unique_ofuda:OnCreated()
	self:SetStackCount(3)
	if IsServer() then
		for _, modifier in ipairs( self:GetCaster():FindAllModifiers() ) do
			if modifier.IsCurse and modifier:IsCurse() then
				modifier:Destroy()
				self:DecrementStackCount()
				if self:GetStackCount() == 0 then
					break
				end
			end
		end
	end
end

function relic_unique_ofuda:IsHidden()
	return self:GetStackCount() == 0
end