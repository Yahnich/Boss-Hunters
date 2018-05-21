relic_cursed_first_sin = class(relicBaseClass)

function relic_cursed_first_sin:OnCreated()
	if IsServer() then 
		self:OnIntervalThink()
		self:StartIntervalThink(0.5) 
	end
end

function relic_cursed_first_sin:OnIntervalThink()
	if self:GetParent():IsAlive() then
		for _, enemy in ipairs( self:GetParent():FindEnemyUnitsInRadius( Vector(0,0,0), -1 ) ) do
			enemy:Taunt(nil, self:GetParent(), 0.51)
		end
	end
end