wk_crit = class({})

function wk_crit:IsStealable()
    return false
end

function wk_crit:IsHiddenWhenStolen()
    return false
end

function wk_crit:GetIntrinsicModifierName()
	return "modifier_wk_crit_passive"
end

function wk_crit:GetBehavior()
	if self:GetCaster():HasTalent("special_bonus_unique_wk_crit_1") then
		return DOTA_ABILITY_BEHAVIOR_POINT
	else
		return DOTA_ABILITY_BEHAVIOR_PASSIVE
	end
end

function wk_crit:GetCastRange( position, target )
	if self:GetCaster():HasTalent("special_bonus_unique_wk_crit_1") then
		return self:GetCaster():GetAttackRange() * (4 or self:GetCaster():FindTalentValue("special_bonus_unique_wk_crit_1", "range"))
	else
		return DOTA_ABILITY_BEHAVIOR_PASSIVE
	end
end

function wk_crit:OnSpellStart()
	local caster = self:GetCaster()
	local position = self:GetCursorPosition()
	
	self:FireLinearProjectile( "particles/vampiric_shockwave.vpcf", 900 * CalculateDirection(position, caster), self:GetTrueCastRange(), self:GetCaster():GetAttackRange() )
end

function wk_crit:OnProjectileHit(target, vLocation)
	local caster = self:GetCaster()

	if target then
		caster:PerformAbilityAttack(target, true, self)
	end
end

modifier_wk_crit_passive = class({})
LinkLuaModifier("modifier_wk_crit_passive", "heroes/hero_wraith_king/wk_crit", LUA_MODIFIER_MOTION_NONE)

function modifier_wk_crit_passive:OnCreated()
	self:OnRefresh()
end

function modifier_wk_crit_passive:OnRefresh()
	self.crit_chance = self:GetTalentSpecialValueFor("crit_chance")
	self.crit_dmg = self:GetTalentSpecialValueFor("crit_mult")
	if IsServer() then
		self:GetParent():HookInModifier("GetModifierCriticalDamage", self)
	end
end

function modifier_wk_crit_passive:OnDestroy()
	if IsServer() then
		self:GetParent():HookOutModifier("GetModifierCriticalDamage", self)
	end
end

function modifier_wk_crit_passive:GetModifierCriticalDamage(params)
	local caster = self:GetCaster()
	if not caster:PassivesDisabled() and self:RollPRNG( self.crit_chance ) then
		local skeletons = caster:FindAbilityByName("wk_skeletons")
		if skeletons and skeletons:IsTrained() then
			skeletons:IncrementCharge()
		end
		caster:AddNewModifier( caster, self:GetAbility(), "modifier_wk_crit_str", {} )
		
		self:GetAbility().target = params.target
		params.target:EmitSound( "Hero_SkeletonKing.CriticalStrike" )
		return self.crit_dmg
	end
end

function modifier_wk_crit_passive:IsHidden()
	return true
end

modifier_wk_crit_str = class({})
LinkLuaModifier("modifier_wk_crit_str", "heroes/hero_wraith_king/wk_crit", LUA_MODIFIER_MOTION_NONE)

function modifier_wk_crit_str:OnCreated()
	self:OnRefresh()
	if IsServer() then
		self.funcID = EventManager:SubscribeListener("boss_hunters_event_finished", function(args) self:OnEventFinished(args) end)
	end
end

function modifier_wk_crit_str:OnEventFinished(args)
	self:Destroy()
end

function modifier_wk_crit_str:OnRefresh()
	self.bonus_str = self:GetTalentSpecialValueFor("bonus_str")
	if IsServer() then
		self:IncrementStackCount()
		self:GetCaster():CalculateStatBonus()
	end
end

function modifier_wk_crit_str:DeclareFunctions()
	return {MODIFIER_PROPERTY_EXTRA_STRENGTH_BONUS}
end

function modifier_wk_crit_str:GetModifierExtraStrengthBonus()
	return self.bonus_str * self:GetStackCount()
end