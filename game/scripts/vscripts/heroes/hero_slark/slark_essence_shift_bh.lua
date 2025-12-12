slark_essence_shift_bh = class({})

function slark_essence_shift_bh:GetIntrinsicModifierName()
	return "modifier_slark_essence_shift_handler"
end

function slark_essence_shift_bh:ShouldUseResources()
	return true
end

modifier_slark_essence_shift_handler = class({})
LinkLuaModifier("modifier_slark_essence_shift_handler", "heroes/hero_slark/slark_essence_shift_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_slark_essence_shift_handler:OnCreated()
	self:OnRefresh()
end

function modifier_slark_essence_shift_handler:OnRefresh()
	self.rTalent1 = self:GetCaster():HasTalent("special_bonus_unique_slark_shadow_dance_1")
end


function modifier_slark_essence_shift_handler:DeclareFunctions()
	funcs = {
				MODIFIER_EVENT_ON_ATTACK_LANDED,
			}
	return funcs
end

function modifier_slark_essence_shift_handler:OnAttackLanded(params)
	local ability = self:GetAbility()
	if params.attacker == self:GetParent() and not params.target:IsMinion() then
		ability:SetCooldown()
		local caster = self:GetCaster()
		local duration = self:GetSpecialValueFor("duration")

		local debuff = params.target:AddNewModifier(caster, ability, "modifier_slark_essence_shift_attr_debuff", {})
		local buff = caster:AddNewModifier(caster, ability, "modifier_slark_essence_shift_agi_buff", {})
		
		if caster:HasModifier("modifier_slark_shadow_dance_activated") and self.rTalent1 then
			debuff:ForceRefresh()
			buff:ForceRefresh()
		end
		
		-- if caster:HasTalent("special_bonus_unique_slark_essence_shift_2") then
			-- ability:DealDamage( caster, params.target, caster:GetPrimaryStatValue() * caster:FindTalentValue("special_bonus_unique_slark_essence_shift_2") / 100, {damage_type = DAMAGE_TYPE_PURE, damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION})
		-- end
		caster:CalculateStatBonus()
	end
end

function modifier_slark_essence_shift_handler:IsHidden()
	return true
end

modifier_slark_essence_shift_attr_debuff = class({})
LinkLuaModifier("modifier_slark_essence_shift_attr_debuff", "heroes/hero_slark/slark_essence_shift_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_slark_essence_shift_attr_debuff:OnCreated()
	self:OnRefresh()
end

function modifier_slark_essence_shift_attr_debuff:OnRefresh()
	self.ad = self:GetSpecialValueFor("ad_loss")
	self.as = self:GetSpecialValueFor("as_loss")
	self.hp = self:GetSpecialValueFor("hp_loss")
	self.ar = self:GetSpecialValueFor("ar_loss")
	
	self.perma_agi = self:GetSpecialValueFor("perma_agi")
	self.boss_agi = self:GetSpecialValueFor("boss_agi")
	if IsServer() then
		self:IncrementStackCount()
	end
end

function modifier_slark_essence_shift_attr_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
			MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS,
			MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
			MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
			MODIFIER_EVENT_ON_DEATH }
end

function modifier_slark_essence_shift_attr_debuff:OnDeath(params)
	if params.unit == self:GetParent() and not params.unit:IsMinion() then
		local stacks = TernaryOperator( self.boss_agi, params.unit:IsBoss(), self.perma_agi )
		local modifier = self:GetCaster():AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_slark_essence_shift_perma_buff", {} )
		modifier:SetStackCount( modifier:GetStackCount() + stacks )
	end
end

function modifier_slark_essence_shift_attr_debuff:GetModifierPreAttack_BonusDamage()
	return self.ad * self:GetStackCount()
end

function modifier_slark_essence_shift_attr_debuff:GetModifierAttackSpeedBonus_Constant()
	return self.as * self:GetStackCount()
end

function modifier_slark_essence_shift_attr_debuff:GetModifierExtraHealthBonus()
	return self.hp * self:GetStackCount()
end

function modifier_slark_essence_shift_attr_debuff:GetModifierPhysicalArmorBonus()
	return self.ar * self:GetStackCount()
end

modifier_slark_essence_shift_agi_buff = class({})
LinkLuaModifier("modifier_slark_essence_shift_agi_buff", "heroes/hero_slark/slark_essence_shift_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_slark_essence_shift_agi_buff:OnCreated()
	self:OnRefresh()
	if IsServer() then
		self.funcID = EventManager:SubscribeListener("boss_hunters_event_finished", function(args) self:OnEventFinished(args) end)
	end
end

function modifier_slark_essence_shift_agi_buff:OnRefresh()
	self.agi = self:GetSpecialValueFor("agi_gain")
	if IsServer() then
		self:IncrementStackCount()
	end
end

function modifier_slark_essence_shift_agi_buff:OnEventFinished(args)
	self:Destroy()
end

function modifier_slark_essence_shift_agi_buff:OnDestroy()
	if IsServer() then
		EventManager:UnsubscribeListener("boss_hunters_event_finished", self.funcID)
	end
end


function modifier_slark_essence_shift_agi_buff:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_AGILITY_BONUS}
end

function modifier_slark_essence_shift_agi_buff:GetModifierBonusStats_Agility()
	return self.agi * self:GetStackCount()
end


modifier_slark_essence_shift_perma_buff = class({})
LinkLuaModifier("modifier_slark_essence_shift_perma_buff", "heroes/hero_slark/slark_essence_shift_bh", LUA_MODIFIER_MOTION_NONE)
function modifier_slark_essence_shift_perma_buff:OnCreated()
	self:OnRefresh()
end

function modifier_slark_essence_shift_perma_buff:OnRefresh()
	self.agi = self:GetSpecialValueFor("agi_gain")
end

function modifier_slark_essence_shift_perma_buff:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_AGILITY_BONUS}
end

function modifier_slark_essence_shift_perma_buff:GetModifierBonusStats_Agility()
	return self.agi * self:GetStackCount()
end

function modifier_slark_essence_shift_perma_buff:IsPermanent()
	return true
end

function modifier_slark_essence_shift_perma_buff:IsPurgable()
	return false
end

function modifier_slark_essence_shift_perma_buff:RemoveOnDeath()
	return false
end