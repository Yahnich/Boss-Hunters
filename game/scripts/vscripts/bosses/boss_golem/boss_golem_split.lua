boss_golem_split = class({})

function boss_golem_split:GetIntrinsicModifierName()
	return "modifier_boss_golem_split"
end

modifier_boss_golem_split = class({})
LinkLuaModifier( "modifier_boss_golem_split", "bosses/boss_golem/boss_golem_split", LUA_MODIFIER_MOTION_NONE )

function modifier_boss_golem_split:OnCreated()
	self.modelScale = self:GetParent():GetModelScale()
	self.originalTeam = self:GetParent():GetTeamNumber()
	if IsServer() then
		self:StartIntervalThink(0.25)
	end
end

function modifier_boss_golem_split:OnIntervalThink()
	if self.modelScale ~= self:GetParent():GetModelScale() then
		self.modelScale = self:GetParent():GetModelScale()
		self:SetStackCount( self:GetParent():GetModelScale() * 100 )
		self:GetParent():SetHullRadius( 32 * self:GetParent():GetModelScale() )
	end
end

function modifier_boss_golem_split:DeclareFunctions()
	return {MODIFIER_EVENT_ON_DEATH,
			MODIFIER_PROPERTY_ATTACK_RANGE_BASE_OVERRIDE}
end

function modifier_boss_golem_split:OnDeath(params)
	if params.unit == self:GetParent() and self:GetParent():GetModelScale() > self:GetSpecialValueFor("minimum_scale") and self:GetAbility():IsActivated() and not params.unit:IsIllusion() then
		local divider = self:GetSpecialValueFor("golem_hp") / 100
		local hp = self:GetParent():GetMaxHealth() * divider
		local scale = math.max( self:GetParent():GetModelScale() * 0.75, self:GetSpecialValueFor("minimum_scale") - 0.01 )
		for i = 1, self:GetSpecialValueFor("split_count") do
			golem = CreateUnitByName("npc_dota_boss12_golem", self:GetParent():GetAbsOrigin() + RandomVector(250), true, nil, nil, self.originalTeam)
			
			golem:SetModelScale( scale )
			golem:SetBaseMoveSpeed( math.min( 300, golem:GetBaseMoveSpeed() / ( scale / 1.8 )) )
			golem:SetAverageBaseDamage( golem:GetAverageBaseDamage() * 0.8, 25 )
			
			golem:SetCoreHealth( math.max(1, hp) )
			if self.originalTeam == DOTA_TEAM_BADGUYS then
				golem.unitIsRoundNecessary = true
				golem.hasBeenInitialized = true
			end
		end
		ResolveNPCPositions( self:GetParent():GetAbsOrigin(), 500 ) 
	end
end

function modifier_boss_golem_split:GetModifierAttackRangeOverride()
	return math.max( 90, 200 * self:GetStackCount() / 100 )
end

function modifier_boss_golem_split:IsHidden()
	return true
end