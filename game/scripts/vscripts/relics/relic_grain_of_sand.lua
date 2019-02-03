relic_grain_of_sand = class(relicBaseClass)

function relic_grain_of_sand:OnCreated()
	self.delay = 15
	if IsServer() then
		self:StartIntervalThink(self.delay)
		self:SetDuration(self.delay, true)
	end
end

function relic_grain_of_sand:OnIntervalThink()
	local abilityTable = {}
	for i = 0, 23 do
        local ability = self:GetParent():GetAbilityByIndex( i )
        if ability and not ability:IsCooldownReady() and not ability:IsPassive() then
			table.insert(abilityTable, ability)
        end
    end
	if #abilityTable > 0 then
		abilityTable[RandomInt(1, #abilityTable)]:Refresh()
	end
	self:SetDuration(self.delay, true)
end

function relic_grain_of_sand:IsHidden()
	return false
end