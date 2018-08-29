treant_leech_seed_bh = class({})

function treant_leech_seed_bh:GetIntrinsicModifierName()
	return "modifier_treant_leech_seed_bh_handler"
end

function treant_leech_seed_bh:ShouldUseResources()
	return true
end

function treant_leech_seed_bh:ApplyLeechSeed(target, duration)
	local caster = self:GetCaster()
	local bDur = duration or self:GetTalentSpecialValueFor("duration")
	
	target:AddNewModifier( caster, self, "modifier_treant_leech_seed_bh_debuff", {duration = bDur} )
end

modifier_treant_leech_seed_bh_handler = class({})
LinkLuaModifier("modifier_treant_leech_seed_bh_handler", "heroes/hero_treant_protector/treant_leech_seed_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_treant_leech_seed_bh_handler:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_treant_leech_seed_bh_handler:OnAttackLanded(params)
	if params.attacker == self:GetParent() and self:GetAbility():IsCooldownReady() and not params.target:IsSameTeam(params.attacker) then
		self:GetAbility():ApplyLeechSeed( params.target )
		self:GetAbility():SetCooldown()
	end
end

modifier_treant_leech_seed_bh_debuff = class({})
LinkLuaModifier("modifier_treant_leech_seed_bh_debuff", "heroes/hero_treant_protector/treant_leech_seed_bh", LUA_MODIFIER_MOTION_NONE)