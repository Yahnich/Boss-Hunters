pudge_flesh_heap_lua = class({})

function pudge_flesh_heap_lua:GetIntrinsicModifierName()
	return "modifier_pudge_flesh_heap_lua"
end

modifier_pudge_flesh_heap_lua = class({})
LinkLuaModifier("modifier_pudge_flesh_heap_lua", "heroes/hero_pudge/pudge_flesh_heap_lua", LUA_MODIFIER_MOTION_NONE)
function modifier_pudge_flesh_heap_lua:OnCreated(table)
	self:OnRefresh()
	self.permanentStacks = 0
	if IsServer() then
		self.funcID = EventManager:SubscribeListener("boss_hunters_event_finished", function(args) self:OnEventFinished(args) end)
	end
end

function modifier_pudge_flesh_heap_lua:OnRefresh()
    self.mr = self:GetSpecialValueFor("magic_resist")
    self.bonus_str = self:GetTalentSpecialValueFor("str_bonus")
    self.bonus_regen = self:GetTalentSpecialValueFor("health_regen")
	
    self.radius = self:GetTalentSpecialValueFor("radius")
    self.minion_stacks = self:GetTalentSpecialValueFor("minion_stacks")
    self.temp_stacks = self:GetTalentSpecialValueFor("temp_stacks")
    self.minion_regen = self:GetTalentSpecialValueFor("minion_regen") / 100
	
    self.monster_stacks = self:GetTalentSpecialValueFor("death_stacks")
    self.boss_stacks = self:GetTalentSpecialValueFor("boss_stacks")
    if IsServer() then self:GetParent():CalculateStatBonus() end
end

function modifier_pudge_flesh_heap_lua:OnEventFinished(args)
	self:SetStackCount( self.permanentStacks )
	self:ForceRefresh()
end

function modifier_pudge_flesh_heap_lua:OnDestroy()
	if IsServer() then
		EventManager:UnsubscribeListener("boss_hunters_event_finished", self.funcID)
	end
end

function modifier_pudge_flesh_heap_lua:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_MODEL_SCALE,
		MODIFIER_EVENT_ON_DEATH
    }
    return funcs
end

function modifier_pudge_flesh_heap_lua:OnDeath(params)
	local caster = self:GetCaster()
	if params.attacker == self:GetParent()
	or ( not params.unit:IsSameTeam( caster ) and CalculateDistance( params.unit, caster ) <= self.radius ) then
		local permaStacks = TernaryOperator( self.boss_stacks, params.unit:IsBoss(), self.monster_stacks )
		local tempStacks =  TernaryOperator( 0, params.unit:IsBoss(), self.temp_stacks )
		if params.unit:IsMinion() then
			tempStacks = self.minion_stacks
			permaStacks = 0
			caster:HealEvent( caster:GetHealthDeficit() * self.minion_regen, self:GetAbility(), caster, {} )
			caster:RestoreMana( caster:GetManaDeficit() * self.minion_regen )
		else
			-- not a minion
		end
		if params.unit:HasModifier("modifier_pudge_regurgitate_debuff") and caster:HasTalent("special_bonus_unique_pudge_regurgitate_2") then
			tempStacks = tempStacks + caster:FindTalentValue("special_bonus_unique_pudge_regurgitate_2")
		end
		self.permanentStacks = self.permanentStacks + permaStacks
		self:SetStackCount( self:GetStackCount() + permaStacks + tempStacks )
		self:ForceRefresh()
	end
end

function modifier_pudge_flesh_heap_lua:GetModifierMagicalResistanceBonus()
    return self.mr
end

function modifier_pudge_flesh_heap_lua:GetModifierConstantHealthRegen()
    return self.bonus_regen * self:GetStackCount()
end

function modifier_pudge_flesh_heap_lua:GetModifierBonusStats_Strength()
    return self.bonus_str * self:GetStackCount()
end

function modifier_pudge_flesh_heap_lua:GetModifierModelScale()
    return math.min( self:GetStackCount(), 50 )
end

function modifier_pudge_flesh_heap_lua:IsHidden()
    return self:GetStackCount() == 0
end

function modifier_pudge_flesh_heap_lua:IsPermanent()
	return true
end

function modifier_pudge_flesh_heap_lua:IsPurgable()
	return false
end

function modifier_pudge_flesh_heap_lua:RemoveOnDeath()
	return false
end