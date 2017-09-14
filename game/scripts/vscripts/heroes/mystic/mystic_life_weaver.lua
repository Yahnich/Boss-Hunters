mystic_life_weaver = class({})

function mystic_life_weaver:GetIntrinsicModifierName()
	return "modifier_mystic_life_weaver_passive"
end

LinkLuaModifier("modifier_mystic_life_weaver_passive", "heroes/mystic/mystic_life_weaver.lua", 0)

modifier_mystic_life_weaver_passive = class({})

function modifier_mystic_life_weaver_passive:OnCreated()
	self.heal_share = self:GetAbility():GetSpecialValueFor("heal_share") / 100
	self:InitFunctions()
end

function modifier_mystic_life_weaver_passive:OnRefresh()
	self.heal_share = self:GetAbility():GetSpecialValueFor("heal_share") / 100
end

function modifier_mystic_life_weaver_passive:InitFunctions()
	local caster = self:GetCaster()
	caster.prevTarget = caster.prevTarget or self:GetCaster()
	if not caster.GetWeaveUnit then
		caster.GetWeaveUnit = function(caster) return caster.prevTarget	end
	end
	if not caster.SetWeaveUnit then
		caster.SetWeaveUnit = function(caster, target) caster.prevTarget = target end
	end
end

function modifier_mystic_life_weaver_passive:IsHidden()
	return (not self:GetCaster():HasScepter())
end

function modifier_mystic_life_weaver_passive:IsPurgable()
	return false
end

function modifier_mystic_life_weaver_passive:OnHeal(params)
	if params.unit == self:GetParent() and self:GetParent():HasTalent("mystic_life_weaver_talent_1") and params.amount - params.target:GetHealthDeficit() > 0 then
		local overheal = (params.amount - params.target:GetHealthDeficit()) * self:GetSpecialValueFor("talent_overheal_barrier") / 100
		params.target:AddBarrier(overheal, params.unit, self:GetAbility(), nil)
	end
	if params.unit == self:GetParent() and params.source ~= self:GetAbility() then
		local prevHealUnit = self:GetParent():GetWeaveUnit()
		if prevHealUnit:IsNull() then prevHealUnit = self:GetCaster() end
		local currHealUnit = params.target
		
		if params.target ~= self:GetParent():GetWeaveUnit() then
			self:GetParent():SetWeaveUnit(currHealUnit)
		end
		
		local duration = self:GetAbility():GetTalentSpecialValueFor("duration")
		prevHealUnit:AddNewModifier(params.unit, self:GetAbility(), "modifier_mystic_life_weaver_hot", {duration = duration, totalheal = params.amount * self.heal_share})
		currHealUnit:AddNewModifier(params.unit, self:GetAbility(), "modifier_mystic_life_weaver_hot", {duration = duration, totalheal = params.amount * self.heal_share})
		
		if self:GetCaster():HasScepter() then
			self:IncrementStackCount()
			Timers:CreateTimer(self:GetSpecialValueFor("scepter_duration"), function() self:DecrementStackCount() end)
		end
	end
end

function modifier_mystic_life_weaver_passive:GetOnHealBonus()
	if self:GetCaster():HasScepter() then
		return self:GetSpecialValueFor("scepter_bonus_heal") * self:GetStackCount()
	end
end

LinkLuaModifier("modifier_mystic_life_weaver_hot", "heroes/mystic/mystic_life_weaver.lua", 0)
modifier_mystic_life_weaver_hot = class({})

if IsServer() then
	function modifier_mystic_life_weaver_hot:OnCreated(kv)
		self.totalheal = kv.totalheal
		self.healtick = self.totalheal / self:GetRemainingTime()
		self:StartIntervalThink(1)
	end

	function modifier_mystic_life_weaver_hot:OnRefresh(kv)
		self.totalheal = self.totalheal + kv.totalheal
		self.healtick = self.totalheal / self:GetRemainingTime()
	end

	function modifier_mystic_life_weaver_hot:OnIntervalThink()
		self.totalheal = self.totalheal - self.healtick
		EmitSoundOn("Hero_Dazzle.Foley", self:GetParent())
		self:GetParent():HealEvent(self.healtick, self:GetAbility(), self:GetCaster())
		if self.totalheal < 0 then self:Destroy() end
	end
end

function modifier_mystic_life_weaver_hot:GetEffectName()
	return "particles/heroes/mystic/mystic_life_weaver.vpcf"
end
