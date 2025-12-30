alchemist_corrosive_arsenal = class({})

function alchemist_corrosive_arsenal:GetIntrinsicModifierName()
	return "modifier_alchemist_corrosive_arsenal_passive"
end

modifier_alchemist_corrosive_arsenal_passive = class({})
LinkLuaModifier( "modifier_alchemist_corrosive_arsenal_passive", "heroes/hero_alchemist/alchemist_corrosive_arsenal", LUA_MODIFIER_MOTION_NONE )

function modifier_alchemist_corrosive_arsenal_passive:OnCreated()
    self:OnRefresh()
end
function modifier_alchemist_corrosive_arsenal_passive:OnRefresh()
    self.max_stacks = self:GetSpecialValueFor("max_stacks")
    self.debuff_duration = self:GetSpecialValueFor("debuff_duration")
	
    self.stacks_per_attack = self:GetSpecialValueFor("stacks_per_attack")
    self.stacks_per_second = self:GetSpecialValueFor("stacks_per_second")
	
    self.gain_buff = self:GetSpecialValueFor("attack_damage_gain") > 0
end

function modifier_alchemist_corrosive_arsenal_passive:DeclareFunctions()
    return {MODIFIER_EVENT_ON_TAKEDAMAGE}
end

function modifier_alchemist_corrosive_arsenal_passive:OnTakeDamage(params)
    if params.attacker ~= self:GetParent() then return end
	if params.attacker:PassivesDisabled() then return end
	if params.inflictor and not params.attacker:HasAbility( params.inflictor:GetAbilityName() ) then return end
    
	local debuff = params.unit:FindModifierByName("modifier_alchemist_corrosive_arsenal_debuff") or params.unit:AddNewModifier( params.attacker, self:GetAbility(), "modifier_alchemist_corrosive_arsenal_debuff", {duration = self.debuff_duration} )
	local stacks = 0
	if debuff then
		stacks = debuff:GetStackCount()
	end
	local newStacks = 0
	if params.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK then
		newStacks = self.stacks_per_attack
	elseif params.damage_category == DOTA_DAMAGE_CATEGORY_SPELL then
		if params.inflictor:GetAbilityName() == "alchemist_acid_bomb" then
			newStacks = self.stacks_per_second
		elseif params.inflictor:GetAbilityName() == "alchemist_volatile_brew" then
			newStacks = self.stacks_per_second * params.inflictor._lastBrewTime
		end
	end
	if IsModifierSafe( debuff ) then
		debuff:SetDuration( self.debuff_duration, true )
		debuff:SetStackCount( math.min( self.max_stacks, stacks + newStacks ) )
	end
	if self.gain_buff then
		local buff = params.attacker:AddNewModifier( params.attacker, self:GetAbility(), "modifier_alchemist_corrosive_arsenal_buff", {duration = self.debuff_duration} )
		buff:SetStackCount( math.min( self.max_stacks, buff:GetStackCount() + newStacks ) )
	end
end

function modifier_alchemist_corrosive_arsenal_passive:IsHidden()
    return true
end

function modifier_alchemist_corrosive_arsenal_passive:IsPurgable()
    return false
end

function modifier_alchemist_corrosive_arsenal_passive:IsPermanent()
    return true
end

modifier_alchemist_corrosive_arsenal_debuff = class({})
LinkLuaModifier( "modifier_alchemist_corrosive_arsenal_debuff", "heroes/hero_alchemist/alchemist_corrosive_arsenal", LUA_MODIFIER_MOTION_NONE )

function modifier_alchemist_corrosive_arsenal_debuff:OnCreated()
    self:OnRefresh()
	self:GetParent():HookInModifier( "GetModifierLifestealTargetBonus", self ) 
end
function modifier_alchemist_corrosive_arsenal_debuff:OnRefresh()
    self.slow_per_stack = self:GetSpecialValueFor("slow_per_stack")
    self.alchemist_facet_bonus = self:GetSpecialValueFor("alchemist_facet_bonus") / 100
	
    self.dps_per_stack = self:GetSpecialValueFor("dps_per_stack") / 100
	
    self.attack_damage_loss = self.slow_per_stack * self:GetSpecialValueFor("attack_damage_loss") / 100
    self.bonus_lifesteal = self:GetSpecialValueFor("bonus_lifesteal")
    self.status_resist_per_stack = self.slow_per_stack * self:GetSpecialValueFor("status_resist_per_stack") / 100
	
	if self.dps_per_stack > 0 then
		self:StartIntervalThink( 1 )
	end
end

function modifier_alchemist_corrosive_arsenal_debuff:OnIntervalThink()
	local caster = self:GetCaster()
	self:GetAbility():DealDamage( caster, self:GetParent(), caster:GetIntellect( false ) * self.dps_per_stack * self:GetStackCount(), {damage_type = DAMAGE_TYPE_PURE, damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION }, OVERHEAD_ALERT_BONUS_POISON_DAMAGE )
end

function modifier_alchemist_corrosive_arsenal_debuff:OnDestroy()
	self:GetParent():HookOutModifier( "GetModifierLifestealTargetBonus", self ) 
end

function modifier_alchemist_corrosive_arsenal_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
			MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE }
end

function modifier_alchemist_corrosive_arsenal_debuff:GetModifierMoveSpeedBonus_Percentage( params )
	return -self.slow_per_stack * self:GetStackCount()
end

function modifier_alchemist_corrosive_arsenal_debuff:GetModifierBaseDamageOutgoing_Percentage( params )
	return -self.attack_damage_loss * self:GetStackCount()
end

function modifier_alchemist_corrosive_arsenal_debuff:GetModifierLifestealTargetBonus( params )
	local lifesteal = self.bonus_lifesteal * ( 1 + TernaryOperator( self.alchemist_facet_bonus, params.attacker == self:GetCaster(), 0 ) )
	return lifesteal
end

function modifier_alchemist_corrosive_arsenal_debuff:GetModifierStatusResistanceStacking( params )
	if not params then return self.status_resist_per_stack * self:GetStackCount() end
	local statusResist = self.status_resist_per_stack * self:GetStackCount() * ( 1 + TernaryOperator( self.alchemist_facet_bonus, params.caster == self:GetCaster(), 0 ) )
	return -statusResist
end

modifier_alchemist_corrosive_arsenal_buff = class({})
LinkLuaModifier( "modifier_alchemist_corrosive_arsenal_buff", "heroes/hero_alchemist/alchemist_corrosive_arsenal", LUA_MODIFIER_MOTION_NONE )

function modifier_alchemist_corrosive_arsenal_buff:OnCreated()
    self:OnRefresh()
end

function modifier_alchemist_corrosive_arsenal_buff:OnRefresh()
    self.attack_damage_gain = self:GetSpecialValueFor("slow_per_stack") * self:GetSpecialValueFor("attack_damage_gain") / 100
end

function modifier_alchemist_corrosive_arsenal_buff:DeclareFunctions()
	return {MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE }
end

function modifier_alchemist_corrosive_arsenal_buff:GetModifierBaseDamageOutgoing_Percentage( params )
	return self.attack_damage_gain * self:GetStackCount()
end