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

function wk_crit:ShouldUseResources()
	return true
end

-- function wk_crit:GetBehavior()
	-- if self:GetCaster():HasTalent("special_bonus_unique_wk_crit_1") then
		-- return DOTA_ABILITY_BEHAVIOR_POINT
	-- else
		-- return DOTA_ABILITY_BEHAVIOR_PASSIVE
	-- end
-- end

-- function wk_crit:GetCooldown( iLvl )
	-- return self.BaseClass.GetCooldown( self, iLvl ) + self:GetCaster():FindTalentValue("special_bonus_unique_wk_crit_1")
-- end

-- function wk_crit:GetManaCost( iLvl )
	-- return self:GetCaster():FindTalentValue("special_bonus_unique_wk_crit_1", "mana_cost")
-- end

-- function wk_crit:GetCastRange( position, target )
	-- if self:GetCaster():HasTalent("special_bonus_unique_wk_crit_1") then
		-- return self:GetCaster():GetAttackRange() * self:GetCaster():FindTalentValue("special_bonus_unique_wk_crit_1", "range")
	-- else
		-- return DOTA_ABILITY_BEHAVIOR_PASSIVE
	-- end
-- end

function wk_crit:OnSpellStart()
	local caster = self:GetCaster()
	local position = self:GetCursorPosition()
	
	self.projectiles = self.projectiles or {} 
	
	local directionVector = 900 * CalculateDirection(position, caster)
	self:FireLinearProjectile( "particles/units/heroes/hero_wraith_king/wraith_king_grim_harvest.vpcf", directionVector, self:GetTrueCastRange(), self:GetCaster():GetAttackRange() )
end

function wk_crit:OnProjectileHitHandle(target, vLocation, projectile)
	local caster = self:GetCaster()

	if target then
		caster:PerformAbilityAttack(target, true, self)
	else
	end
end

modifier_wk_crit_passive = class({})
LinkLuaModifier("modifier_wk_crit_passive", "heroes/hero_wraith_king/wk_crit", LUA_MODIFIER_MOTION_NONE)

function modifier_wk_crit_passive:OnCreated()
	self:OnRefresh()
end

function modifier_wk_crit_passive:OnRefresh()
	self.crit_dmg = self:GetSpecialValueFor("crit_mult")
	
	self.talent1 = self:GetCaster():HasTalent("special_bonus_unique_wk_crit_1")
	self.talent1AOE = self:GetCaster():FindTalentValue("special_bonus_unique_wk_crit_1")
	
	self.talent2 = self:GetCaster():HasTalent("special_bonus_unique_wk_crit_2")
	self.talent2Dur = self:GetCaster():FindTalentValue("special_bonus_unique_wk_crit_2")
	if IsServer() then
		self:GetParent():HookInModifier("GetModifierCriticalDamage", self)
		self:GetParent():HookInModifier("GetModifierAreaDamage", self)
	end
end

function modifier_wk_crit_passive:OnDestroy()
	if IsServer() then
		self:GetParent():HookOutModifier("GetModifierCriticalDamage", self)
		self:GetParent():HookOutModifier("GetModifierAreaDamage", self)
	end
end

function modifier_wk_crit_passive:GetModifierCriticalDamage(params)
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	if not caster:PassivesDisabled() and ability:IsCooldownReady() and not caster:PassivesDisabled() then
		caster:AddNewModifier( caster, self:GetAbility(), "modifier_wk_crit_str", {} )
		
		ability:SetCooldown()
		params.target:EmitSound( "Hero_SkeletonKing.CriticalStrike" )
		
		if self.talent1 then
			self.aoeDamage = true
			local blast = caster:FindAbilityByName("wk_blast")
			if blast and blast:GetLevel() > 0 then
				blast:OnProjectileHit( params.target, params.target:GetAbsOrigin(), true)
			end
		end
		
		if self.talent2 then
			caster:AddNewModifier( caster, ability, "modifier_wk_crit_pound_of_flesh", {duration = self.talent2Dur} )
			params.target:AddNewModifier( caster, ability, "modifier_wk_crit_pound_of_flesh", {duration = self.talent2Dur})
		end
		return self.crit_dmg
	end
end

function modifier_wk_crit_passive:GetModifierAreaDamage()
	if self.aoeDamage then
		self.aoeDamage = false
		return self.talent1AOE 
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

function modifier_wk_crit_str:OnDestroy(args)
	if IsServer() then
		EventManager:UnsubscribeListener("boss_hunters_event_finished", self.funcID)
	end
end

function modifier_wk_crit_str:OnRefresh()
	self.bonus_str = self:GetSpecialValueFor("bonus_str")
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

modifier_wk_crit_pound_of_flesh = class({})
LinkLuaModifier("modifier_wk_crit_pound_of_flesh", "heroes/hero_wraith_king/wk_crit", LUA_MODIFIER_MOTION_NONE)
function modifier_wk_crit_pound_of_flesh:OnCreated()
	self:OnRefresh()
end

function modifier_wk_crit_pound_of_flesh:OnRefresh()
	self.talent2Val = self:GetCaster():FindTalentValue("special_bonus_unique_wk_crit_2")
	self.talent2Max = self:GetCaster():FindTalentValue("special_bonus_unique_wk_crit_2", "stacks")
	if self:GetCaster() == self:GetParent() then
		if IsServer() then self:SetStackCount( math.min( self.talent2Max, self:GetStackCount() + 1 ) ) end
	else
		self.talent2Val = -self.talent2Val
		self:SetStackCount( 1 )
	end
	if IsServer() then self:GetParent():CalculateGenericBonuses() end
	self:GetParent():HookInModifier("GetModifierExtraHealthBonusPercentage", self)
end

function modifier_wk_crit_pound_of_flesh:OnDestroy()
	self:GetParent():HookOutModifier("GetModifierExtraHealthBonusPercentage", self)
	
	if IsServer() then self:GetParent():CalculateGenericBonuses() end
end

function modifier_wk_crit_pound_of_flesh:GetModifierExtraHealthBonusPercentage()
	return self.talent2Val * self:GetStackCount()
end