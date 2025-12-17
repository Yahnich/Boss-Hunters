pudge_graft_flesh = class({})

function pudge_graft_flesh:GetIntrinsicModifierName()
	return "modifier_pudge_graft_flesh_kills"
end


modifier_pudge_graft_flesh_kills = class({})
LinkLuaModifier("modifier_pudge_graft_flesh_kills", "heroes/hero_pudge/pudge_flesh_heap_lua", LUA_MODIFIER_MOTION_NONE)
function modifier_pudge_graft_flesh_kills:OnCreated(table)
	self:OnRefresh()
	self.permanentStacks = 0
	if IsServer() then
		self.funcID = EventManager:SubscribeListener("boss_hunters_event_finished", function(args) self:OnEventFinished(args) end)
	end
end

function modifier_pudge_graft_flesh_kills:OnRefresh()
	self.strength_per_stack = self:GetSpecialValueFor("bonus_strength")
	self.flesh_heap_range = self:GetSpecialValueFor("flesh_heap_range")
	
	self.creep_stacks = self:GetSpecialValueFor("creep_stacks")
	self.monster_temp_stacks = self:GetSpecialValueFor("monster_temp_stacks")
	self.monster_stacks = self:GetSpecialValueFor("monster_stacks")
	self.boss_stacks = self:GetSpecialValueFor("boss_stacks")
	
	self.bonus_maximum_health = self:GetSpecialValueFor("bonus_maximum_health")
	self.bonus_base_damage = self:GetSpecialValueFor("bonus_base_damage")
	
    if IsServer() then self:GetParent():CalculateStatBonus() end
end

function modifier_pudge_graft_flesh_kills:OnEventFinished(args)
	self:SetStackCount( self.permanentStacks )
	self:ForceRefresh()
end

function modifier_pudge_graft_flesh_kills:OnDestroy()
	if IsServer() then
		EventManager:UnsubscribeListener("boss_hunters_event_finished", self.funcID)
	end
end

function modifier_pudge_graft_flesh_kills:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS,
		MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
		MODIFIER_EVENT_ON_DEATH
    }
    return funcs
end

function modifier_pudge_graft_flesh_kills:OnDeath(params)
	local caster = self:GetCaster()
	if params.attacker == self:GetParent()
	or ( not params.unit:IsSameTeam( caster ) and CalculateDistance( params.unit, caster ) <= self.radius ) then
		local permaStacks = TernaryOperator( self.boss_stacks, params.unit:IsBoss(), self.monster_stacks )
		local tempStacks =  TernaryOperator( 0, params.unit:IsBoss(), self.monster_temp_stacks )
		if params.unit:IsMinion() then
			tempStacks = self.minion_stacks
			permaStacks = 0
		end
		local regurgitate = params.unit:FindModifierByName("modifier_pudge_regurgitate_debuff")
		if regurgitate and regurgitate.bonus_skin_heap then
			tempStacks = tempStacks + regurgitate.bonus_skin_heap
		end
		self.permanentStacks = self.permanentStacks + permaStacks
		self:SetStackCount( self:GetStackCount() + permaStacks + tempStacks )
		self:ForceRefresh()
	end
end

function modifier_pudge_graft_flesh_kills:GetModifierExtraHealthBonus()
	return self:GetStackCount() * self.bonus_maximum_health
end

function modifier_pudge_graft_flesh_kills:GetModifierBaseAttack_BonusDamage()
	return self:GetStackCount() * self.bonus_base_damage
end

function modifier_pudge_graft_flesh_kills:GetModifierBonusStats_Strength()
    return self.bonus_str * self:GetStackCount()
end

function modifier_pudge_graft_flesh_kills:GetModifierModelScale()
    return math.min( self:GetStackCount(), 50 )
end

function modifier_pudge_graft_flesh_kills:RemoveOnDeath()
	return false
end

function modifier_pudge_graft_flesh_kills:IsPermanent()
	return true
end

function modifier_pudge_graft_flesh_kills:IsPurgable()
	return false
end

function modifier_pudge_graft_flesh_kills:DestroyOnExpire()
	return false
end