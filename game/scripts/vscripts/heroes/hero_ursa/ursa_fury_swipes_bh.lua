ursa_fury_swipes_bh = class({})

function ursa_fury_swipes_bh:IsStealable()
	return false
end

function ursa_fury_swipes_bh:IsHiddenWhenStolen()
	return false
end

function ursa_fury_swipes_bh:GetIntrinsicModifierName()
	return "modifier_ursa_fury_swipes_bh_handle"
end

modifier_ursa_fury_swipes_bh_handle = class({})
LinkLuaModifier("modifier_ursa_fury_swipes_bh_handle", "heroes/hero_ursa/ursa_fury_swipes_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_ursa_fury_swipes_bh_handle:OnCreated()
	self:OnRefresh()
end

function modifier_ursa_fury_swipes_bh_handle:OnRefresh()
	self.damage = self:GetSpecialValueFor("bonus_ad")
	self.duration = self:GetSpecialValueFor("duration")
	self.talent1 = self:GetCaster():HasTalent("special_bonus_unique_ursa_fury_swipes_1")
	self.talent1Heal = self:GetCaster():FindTalentValue("special_bonus_unique_ursa_fury_swipes_1") / 100
	
	self.ultTalent1 = self:GetCaster():HasTalent("special_bonus_unique_ursa_enrage_1")
	self.ultTalent1Val = self:GetCaster():FindTalentValue("special_bonus_unique_ursa_enrage_1")
end

function modifier_ursa_fury_swipes_bh_handle:DeclareFunctions()
	return {MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL }
end

function modifier_ursa_fury_swipes_bh_handle:GetModifierProcAttack_BonusDamage_Physical(params)
	local caster = self:GetCaster()
	if caster:PassivesDisabled() then return nil end
	local damage = self.damage * params.target:GetModifierStackCount( "modifier_ursa_fury_swipes_bh", params.attacker )
	if self.ultTalent1 and caster:HasModifier("modifier_ursa_enrage_bh") then
		damage = damage * self.ultTalent1Val
	end
	local duration = self.duration
	if params.target:IsMinion() then
		duration = -1
	end
	local modifier = params.target:AddNewModifier( params.attacker, self:GetAbility(), "modifier_ursa_fury_swipes_bh", {duration = duration} )
	if caster:HasModifier("modifier_ursa_fury_swipes_bh_talent") then
		local stacks = caster:FindModifierByName("modifier_ursa_fury_swipes_bh_talent"):GetStackCount()
		caster:RemoveModifierByName("modifier_ursa_fury_swipes_bh_talent")
		modifier:SetStackCount( modifier:GetStackCount() + stacks )
	end
	if self.talent1 then
		caster:HealEvent( damage * self.talent1Heal, self:GetAbility(), caster )
	end
	return damage
end

function modifier_ursa_fury_swipes_bh_handle:IsHidden()
	return true
end

modifier_ursa_fury_swipes_bh = class({})
LinkLuaModifier("modifier_ursa_fury_swipes_bh", "heroes/hero_ursa/ursa_fury_swipes_bh", LUA_MODIFIER_MOTION_NONE)
function modifier_ursa_fury_swipes_bh:OnCreated(table)
	self:OnRefresh()
end

function modifier_ursa_fury_swipes_bh:OnRefresh(table)
	local caster = self:GetCaster()
	self.damage = self:GetSpecialValueFor("bonus_ad") * self:GetStackCount()
	self.talent2 = caster:HasTalent("special_bonus_unique_ursa_fury_swipes_2")
	self.talent2Percent = caster:FindTalentValue("special_bonus_unique_ursa_fury_swipes_2") / 100
	if IsServer() then
		self:IncrementStackCount()
	end
end

function modifier_ursa_fury_swipes_bh:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOOLTIP, MODIFIER_EVENT_ON_DEATH }
end

function modifier_ursa_fury_swipes_bh:OnTooltip()
	return self.damage
end

function modifier_ursa_fury_swipes_bh:OnDeath(params)
	if self.talent2 and params.unit == self:GetParent() then
		local talentBuff = self:GetCaster():AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_ursa_fury_swipes_bh_talent", {duration = self:GetRemainingTime()} )
		talentBuff:SetStackCount( math.max( talentBuff:GetStackCount(), math.ceil( self:GetStackCount() * self.talent2Percent ) ) )
	end
end

function modifier_ursa_fury_swipes_bh:GetEffectName()
	return "particles/units/heroes/hero_ursa/ursa_fury_swipes_debuff.vpcf"
end

function modifier_ursa_fury_swipes_bh:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_ursa_fury_swipes_bh:IsDebuff()
	return true
end

function modifier_ursa_fury_swipes_bh:IsHidden()
	return false
end

function modifier_ursa_fury_swipes_bh:IsPurgable()
	return false
end

modifier_ursa_fury_swipes_bh_talent = class({})
LinkLuaModifier("modifier_ursa_fury_swipes_bh_talent", "heroes/hero_ursa/ursa_fury_swipes_bh", LUA_MODIFIER_MOTION_NONE)