mystic_life_weaver = class({})

function mystic_life_weaver:GetIntrinsicModifierName()
	return "modifier_mystic_life_weaver_passive"
end

LinkLuaModifier("modifier_mystic_life_weaver_passive", "heroes/justicar/mystic_life_weaver.lua", 0)

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
	return true
end

function modifier_mystic_life_weaver_passive:IsPurgable()
	return false
end

function modifier_mystic_life_weaver_passive:OnHeal(params)
	if params.unit == self:GetParent() and params.source ~= self:GetAbility() then
		local prevHealUnit = self:GetParent():GetWeaveUnit()
		local currHealUnit = params.target
		self:GetParent():SetWeaveUnit(currHealUnit) -- shift previous target
		
		local duration = self:GetAbility():GetTalentSpecialValueFor("duration")
		prevHealUnit:AddNewModifier(params.unit, self:GetAbility, "modifier_mystic_life_weaver_hot", {duration = duration, totalheal = params.amount * self.heal_share})
		currHealUnit:AddNewModifier(params.unit, self:GetAbility, "modifier_mystic_life_weaver_hot", {duration = duration, totalheal = params.amount * self.heal_share})
	end
end


LinkLuaModifier("modifier_mystic_life_weaver_hot", "heroes/justicar/mystic_life_weaver.lua", 0)
modifier_mystic_life_weaver_hot = class({})

function modifier_mystic_life_weaver_hot:OnCreated(kv)
	self.totalheal = kv.totalheal
	self.healtick = self.totalheal / self:GetRemainingTime()
	if IsServer() then self:StartIntervalThink(1) end
end

function modifier_mystic_life_weaver_hot:OnRefresh(kv)
	self.totalheal = self.totalheal + kv.totalheal
	self.healtick = self.totalheal / self:GetRemainingTime()
end

function modifier_mystic_life_weaver_hot:OnIntervalThink()
	self.totalheal = self.totalheal - self.healtick
	self:GetParent():HealEvent(self.healtick, self:GetAbility(), self:GetCaster())
	if self.totalheal < 0 then self:Destroy() end
end

