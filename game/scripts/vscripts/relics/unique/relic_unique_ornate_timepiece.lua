relic_unique_ornate_timepiece = class({})

function relic_unique_ornate_timepiece:OnCreated()
	if IsServer() then
		for i = 0, self:GetParent():GetAbilityCount() - 1 do
			local ability = self:GetParent():GetAbilityByIndex( i )
			if ability then
				ability.baseCastPoint = ability:GetCastPoint()
				ability:SetOverrideCastPoint(0)
			end
		end
	end
end

function relic_unique_ornate_timepiece:OnDestroy()
	if IsServer() then
		for i = 0, self:GetParent():GetAbilityCount() - 1 do
			local ability = self:GetParent():GetAbilityByIndex( i )
			if ability then
				ability:SetOverrideCastPoint(ability.baseCastPoint)
			end
		end
	end
end

function relic_unique_ornate_timepiece:IsHidden()
	return true
end

function relic_unique_ornate_timepiece:IsPurgable()
	return false
end

function relic_unique_ornate_timepiece:RemoveOnDeath()
	return false
end

function relic_unique_ornate_timepiece:IsPermanent()
	return true
end

function relic_unique_ornate_timepiece:AllowIllusionDuplicate()
	return true
end