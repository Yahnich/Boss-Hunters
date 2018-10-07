relic_cursed_evil_eye_amulet = class(relicBaseClass)

function relic_cursed_evil_eye_amulet:OnCreated()
	if IsServer() then
		self:StartIntervalThink(0)
	end
end
