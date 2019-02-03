relic_ornate_timepiece = class(relicBaseClass)

function relic_ornate_timepiece:OnCreated()
	if IsServer() then
		for i = 0, self:GetParent():GetAbilityCount() - 1 do
			local ability = self:GetParent():GetAbilityByIndex( i )
			if ability then
				ability.baseCastPoint = ability:GetCastPoint()
				ability:SetOverrideCastPoint(0)
			end
		end
		self:StartIntervalThink(5)
	end
end

function relic_ornate_timepiece:OnIntervalThink()
	for i = 0, self:GetParent():GetAbilityCount() - 1 do
		local ability = self:GetParent():GetAbilityByIndex( i )
		if ability then
			ability:SetOverrideCastPoint(0)
		end
	end
end

function relic_ornate_timepiece:OnDestroy()
	if IsServer() then
		for i = 0, self:GetParent():GetAbilityCount() - 1 do
			local ability = self:GetParent():GetAbilityByIndex( i )
			if ability then
				ability:SetOverrideCastPoint(ability.baseCastPoint)
			end
		end
	end
end