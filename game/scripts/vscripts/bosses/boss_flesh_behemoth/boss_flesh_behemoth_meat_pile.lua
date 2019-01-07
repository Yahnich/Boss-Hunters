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
	self.hp = self:GetSpecialValueFor("zombie_health")
	self.chance = self:GetSpecialValueFor("zombie_chance")
end

function modifier_boss_flesh_behemoth_meat_pile:OnRefresh()
	self.hp = self:GetSpecialValueFor("zombie_health")
	self.chance = self:GetSpecialValueFor("zombie_chance")
end

function modifier_boss_flesh_behemoth_meat_pile:DeclareFunctions()
	return {MODIFIER_EVENT_ON_TAKEDAMAGE}
end

function modifier_boss_flesh_behemoth_meat_pile:OnTakeDamage(params)
	if params.unit == self:GetParent() and self:GetAbility():IsCooldownReady() and not params.unit:PassivesDisabled() and self:RollPRNG( self.chance ) then
		local zombie = CreateUnitByName("npc_dota_boss3a_b", params.unit:GetAbsOrigin() + RandomVector(150), true, nil, nil, params.unit:GetTeamNumber() )
		local bonusHP = 0
		if self:GetParent():HasModifier("modifier_boss_flesh_behemoth_decay_buff") then
			local buff = self:GetParent():FindModifierByName("modifier_boss_flesh_behemoth_decay_buff")
			if buff then
				bonusHP = buff:GetModifierExtraHealthBonus()
			end
		end
		zombie:SetCoreHealth( self.hp + bonusHP )
		zombie:SetModelScale( 0.7 )
		zombie:SetAverageBaseDamage( 110, 35 )
		self:GetAbility():SetCooldown()
	end
end

function modifier_boss_flesh_behemoth_meat_pile:IsHidden()
	return true
end