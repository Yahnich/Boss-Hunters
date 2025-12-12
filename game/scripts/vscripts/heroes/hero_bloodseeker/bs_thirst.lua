bs_thirst = class({})

function bs_thirst:IsStealable()
	return false
end

function bs_thirst:IsHiddenWhenStolen()
	return false
end

function bs_thirst:GetIntrinsicModifierName()
	return "modifier_bs_thirst"
end

modifier_bs_thirst = class({})
LinkLuaModifier("modifier_bs_thirst", "heroes/hero_bloodseeker/bs_thirst", LUA_MODIFIER_MOTION_NONE)

function modifier_bs_thirst:OnCreated()
	self:OnRefresh()
end

function modifier_bs_thirst:OnRefresh()
	self.lifesteal = self:GetSpecialValueFor("lifesteal")
	if IsServer() then
		self:GetCaster():HookInModifier( "GetModifierLifestealBonus", self )
	end
end

function modifier_bs_thirst:OnDestroy()
	if IsServer() then
		self:GetCaster():HookOutModifier( "GetModifierLifestealBonus", self )
	end
end

function modifier_bs_thirst:GetModifierLifestealBonus(params)
	if params.attacker == self:GetParent() and ( params.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK or HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_PROPERTY_FIRE) ) then
		local parent = self:GetParent()
		local lifesteal = 0
		for _, modifier in ipairs( parent:FindAllModifiers() ) do
			if modifier:GetAbility() and modifier ~= self and parent:HasAbility( modifier:GetAbility():GetName() ) then
				lifesteal = lifesteal + self.lifesteal
			end
		end
		for _, modifier in ipairs( params.unit:FindAllModifiers() ) do
			if modifier:GetAbility() and parent:HasAbility( modifier:GetAbility():GetName() ) then
				lifesteal = lifesteal + self.lifesteal
			end
		end
		return lifesteal
	end
end

function modifier_bs_thirst:IsHidden()
	return true
end