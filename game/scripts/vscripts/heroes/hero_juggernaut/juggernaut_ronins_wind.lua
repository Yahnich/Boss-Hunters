juggernaut_ronins_wind = class({})

function juggernaut_ronins_wind:OnSpellStart()
	local caster = self:GetCaster()
	
	if caster:AttemptDecrementMomentum(1) then
		self:Refresh()
	end
end