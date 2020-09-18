dazzle_weave_bh = class({})

function dazzle_weave_bh:GetIntrinsicModifierName()
	return "modifier_dazzle_weave_bh_handler"
end

modifier_dazzle_weave_bh_handler = class({})
LinkLuaModifier("modifier_dazzle_weave_bh_handler", "heroes/hero_dazzle/dazzle_weave_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_dazzle_weave_bh_handler:OnCreated()
	self.cdr = self:GetTalentSpecialValueFor("cdr")
	self.mana_cost = self:GetTalentSpecialValueFor("mana_cost")
	self.radius = self:GetTalentSpecialValueFor("radius")
	self.duration = self:GetTalentSpecialValueFor("duration")
	self.talent1 = self:GetCaster():HasTalent("special_bonus_unique_dazzle_weave_1")
	if IsServer() then
		self:SetStackCount( self.mana_cost )
	end
end

function modifier_dazzle_weave_bh_handler:OnRefresh()
	self:OnCreated()
end

function modifier_dazzle_weave_bh_handler:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ABILITY_FULLY_CAST, MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE }
end

function modifier_dazzle_weave_bh_handler:OnAbilityFullyCast(params)
	local caster = params.unit
	local castedAbility = params.ability
	if caster == self:GetCaster() and not castedAbility:IsOrbAbility() and castedAbility:GetCooldownTimeRemaining() > 0 then
		local ability = self:GetAbility()
		local casterPos = caster:GetAbsOrigin()
		caster:EmitSound("Hero_Dazzle.Weave")
		for _, ally in ipairs( caster:FindFriendlyUnitsInRadius( casterPos, self.radius ) ) do
			ally:AddNewModifier( caster, ability, "modifier_dazzle_weave_bh", {duration = self.duration} )
			if not self.talent1 then
				break
			end
		end
		for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( casterPos, self.radius ) ) do
			enemy:AddNewModifier( caster, ability, "modifier_dazzle_weave_bh", {duration = self.duration} )
			if not self.talent1 then
				break
			end
		end
	end
end

function modifier_dazzle_weave_bh_handler:GetModifierPercentageCooldown()
	return self.cdr
end

function modifier_dazzle_weave_bh_handler:IsHidden()
	return true
end

modifier_dazzle_weave_bh = class({})
LinkLuaModifier("modifier_dazzle_weave_bh", "heroes/hero_dazzle/dazzle_weave_bh", 0)

function modifier_dazzle_weave_bh:OnCreated()
	self.armor = self:GetTalentSpecialValueFor("armor_per_second")
	self.talent2 = self:GetCaster():HasTalent("special_bonus_unique_dazzle_weave_2")
	self.hAmp = self:GetCaster():FindTalentValue("special_bonus_unique_dazzle_weave_2")
	if IsServer() then
		self:AddIndependentStack()
	end
end

function modifier_dazzle_weave_bh:OnRefresh()
	self:OnCreated()
end

function modifier_dazzle_weave_bh:IsDebuff()
	return ( not self:GetParent():IsSameTeam( self:GetCaster() ) )
end

function modifier_dazzle_weave_bh:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end

function modifier_dazzle_weave_bh:GetModifierPhysicalArmorBonus()
	if self:GetParent():IsSameTeam( self:GetCaster() ) then
		return self.armor * self:GetStackCount()
	else
		return self.armor * self:GetStackCount() * -1
	end
end

function modifier_dazzle_weave_bh:GetModifierHealAmplify_Percentage()
	if not self.talent2 then return end
	if self:GetParent():IsSameTeam( self:GetCaster() ) then
		return self.hAmp
	else
		return self.hAmp * -1
	end
end

function modifier_dazzle_weave_bh:GetStatusEffectName()
	return "particles/status_fx/status_effect_armor_dazzle.vpcf"
end

function modifier_dazzle_weave_bh:GetEffectName()
	if self:GetParent():IsSameTeam( self:GetCaster() ) then
		return "particles/units/heroes/hero_dazzle/dazzle_armor_friend.vpcf"
	else
		return "particles/units/heroes/hero_dazzle/dazzle_armor_enemy.vpcf"
	end
end

function modifier_dazzle_weave_bh:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_dazzle_weave_bh:StatusEffectPriority()
	return 3
end