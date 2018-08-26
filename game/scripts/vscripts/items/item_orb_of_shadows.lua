item_orb_of_shadows = class({})

function item_orb_of_shadows:OnSpellStart()
	local invis = self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_invisible", {duration = self:GetSpecialValueFor("duration")})
	self:GetCaster():SetThreat(0)
	self:StartDelayedCooldown()
	Timers:CreateTimer(0.1, function()
		if not invis or invis:IsNull() then
			self:EndDelayedCooldown()
			return
		end
		return 0.1
	end)
end