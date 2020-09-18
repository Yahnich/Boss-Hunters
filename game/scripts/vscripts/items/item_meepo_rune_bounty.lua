item_meepo_rune_bounty = class({})

function item_meepo_rune_bounty:OnSpellStart()
	local caster = self:GetCaster()
	if caster:IsAlive() then
		
		EmitSoundOn("Rune.Bounty", caster)

		local goldBase = self:GetSpecialValueFor("gold_base")
		local goldPer30 = 1 * math.ceil( GameRules:GetGameTime()/30 )

		local allies = caster:FindFriendlyUnitsInRadius(caster:GetAbsOrigin(), FIND_UNITS_EVERYWHERE)
		for _,ally in ipairs(allies) do
			if ally:IsRealHero() then
				ally:AddGold(goldBase + goldPer30)
			end
		end

		self:Destroy()
	end
end