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
end

function modifier_alchemist_corrosive_arsenal_passive:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_TAKEDAMAGE
    }
end
function modifier_alchemist_corrosive_arsenal_passive:OnTakeDamage(params)
    if params.attacker ~= self:GetParent() then return end
	if params.attacker:PassivesDisabled() then return end
	if params.inflictor and not params.attacker:HasAbility( params.inflictor:GetAbilityName() ) then return end
    
	local debuff = params.unit:FindModifierByName("modifier_alchemist_corrosive_arsenal_debuff")
	local stacks = 0
	if debuff then
		stacks = debuff:GetStackCount()
	end
	debuff = params.unit:AddNewModifier( params.attacker, self:GetAbility(), "modifier_alchemist_corrosive_arsenal_debuff", {duration = self.debuff_duration} )
	if stacks >= self.max_stacks then return end
	if params.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK then
		debuff:SetStackCount( math.min( self.max_stacks, stacks + self.stacks_per_attack ) )
	elseif params.damage_category == DOTA_DAMAGE_CATEGORY_SPELL then
		if params.inflictor:GetAbilityName() == "alchemist_acid_spray" then
			debuff:SetStackCount( math.min( self.max_stacks, stacks + self.stacks_per_second ) )
		elseif params.inflictor:GetAbilityName() == "alchemist_unstable_concoction_throw" then
			debuff:SetStackCount( math.min( self.max_stacks, math.floor( stacks + self.stacks_per_second * params.inflictor._lastBrewTime ) ) )
		end
	end
end
function modifier_alchemist_corrosive_arsenal_passive:IsHidden()
    return true
end