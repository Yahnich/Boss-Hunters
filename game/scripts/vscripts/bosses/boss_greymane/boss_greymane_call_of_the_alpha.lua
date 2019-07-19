boss_greymane_call_of_the_alpha = class({})

function boss_greymane_call_of_the_alpha:GetIntrinsicModifierName()
	return "modifier_boss_greymane_call_of_the_alpha"
end

modifier_boss_greymane_call_of_the_alpha = class({})
LinkLuaModifier("modifier_boss_greymane_call_of_the_alpha", "bosses/boss_greymane/boss_greymane_call_of_the_alpha", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
	function modifier_boss_greymane_call_of_the_alpha:OnCreated()
		self.wolf = self:GetSpecialValueFor("wolf_interval")
		self.alpha = self:GetSpecialValueFor("alpha_interval")
		
		self.wolfCounter = self.wolf
		self.alphaCounter = self.alpha
		self:StartIntervalThink(1)
		self:SetDuration( math.min(self.wolfCounter, self.alphaCounter), true )
	end

	function modifier_boss_greymane_call_of_the_alpha:OnIntervalThink()
		self.wolfCounter = self.wolfCounter - 1
		self.alphaCounter = self.alphaCounter - 1
		local spawn = false
		if self.wolfCounter <= 0 then
			local wolf = CreateUnitByName("npc_dota_boss_wolf", RoundManager:PickRandomSpawn(), true, nil, nil, DOTA_TEAM_BADGUYS)
			wolf:SetCoreHealth(750)
			self.wolfCounter = self.wolf
			spawn = true
		end
		if self.alphaCounter <= 0 then
			local alpha = CreateUnitByName("npc_dota_boss_alpha_wolf", RoundManager:PickRandomSpawn(), true, nil, nil, DOTA_TEAM_BADGUYS)
			alpha:SetCoreHealth(1000)
			self.alphaCounter = self.alpha
			spawn = true
		end
		if spawn then
			self:SetDuration( math.min(self.wolfCounter, self.alphaCounter), true )
		end
	end
end

function modifier_boss_greymane_call_of_the_alpha:DestroyOnExpire()
	return false
end