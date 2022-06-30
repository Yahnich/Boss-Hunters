boss_flesh_behemoth_meat_pile = class({})

function boss_flesh_behemoth_meat_pile:GetIntrinsicModifierName()
	return "modifier_boss_flesh_behemoth_meat_pile"
end

function boss_flesh_behemoth_meat_pile:ShouldUseResources()
	return true
end

modifier_boss_flesh_behemoth_meat_pile = class({})
LinkLuaModifier("modifier_boss_flesh_behemoth_meat_pile", "bosses/boss_flesh_behemoth/boss_flesh_behemoth_meat_pile", LUA_MODIFIER_MOTION_NONE)

function modifier_boss_flesh_behemoth_meat_pile:OnCreated()
	self:OnRefresh()
end

function modifier_boss_flesh_behemoth_meat_pile:OnRefresh()
	self.hp = self:GetSpecialValueFor("zombie_health")
	self.chance = self:GetSpecialValueFor("zombie_chance")
	self.minimum = self:GetSpecialValueFor("min_dmg")
	self.zombies = self:GetSpecialValueFor("zombie_count")
end

function modifier_boss_flesh_behemoth_meat_pile:DeclareFunctions()
	return {MODIFIER_EVENT_ON_TAKEDAMAGE}
end

function modifier_boss_flesh_behemoth_meat_pile:OnTakeDamage(params)
	if params.unit == self:GetParent() and self:GetAbility():IsCooldownReady() and not params.unit:PassivesDisabled() and self:RollPRNG( self.chance ) and params.damage > self.minimum then
		local caster = self:GetParent()
		local ability = self:GetAbility()
		local bonusHP = 0
		if caster:HasModifier("modifier_boss_flesh_behemoth_decay_buff") then
			local buff = caster:FindModifierByName("modifier_boss_flesh_behemoth_decay_buff")
			if buff then
				bonusHP = buff:GetModifierExtraHealthBonus()
			end
		end
		for i = 1, self.zombies do
			local zombie = CreateUnitByName("npc_dota_boss3a_b", params.unit:GetAbsOrigin(), true, nil, nil, params.unit:GetTeamNumber() )
			local distance = RandomInt( 150, 600 )
			local travelTime = distance / 300
			Timers:CreateTimer( function() zombie:ApplyKnockBack(caster:GetAbsOrigin(), travelTime, travelTime, distance, RandomInt( 150, 600 ), caster, ability, true) end )
			zombie:SetCoreHealth( self.hp + bonusHP )
			zombie:SetModelScale( 0.7 )
			zombie:SetAverageBaseDamage( 95, 35 )
		end
		self:GetAbility():SetCooldown()
	end
end

function modifier_boss_flesh_behemoth_meat_pile:IsHidden()
	return true
end