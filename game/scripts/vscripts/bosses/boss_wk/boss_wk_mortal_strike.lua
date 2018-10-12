boss_wk_mortal_strike = class({})

function boss_wk_mortal_strike:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	
	local duration = self:GetSpecialValueFor("duration")
	local steal = self:GetSpecialValueFor("max_hp_steal") / 100
	local stolenHP = math.floor( target:GetMaxHealth() * steal )
	local cHpPct = caster:GetHealth() / caster:GetMaxHealth()
	
	local buff = caster:AddNewModifier( caster, self, "modifier_boss_wk_mortal_strike_buff", {duration = duration} )
	if buff then buff:SetStackCount( stolenHP ) end
	caster:SetHealth( cHpPct * caster:GetMaxHealth() )
	local debuff = target:AddNewModifier( caster, self, "modifier_boss_wk_mortal_strike_debuff", {duration = duration} )
	if debuff then debuff:SetStackCount( stolenHP ) end
end

modifier_boss_wk_mortal_strike_debuff = class({})
LinkLuaModifier("modifier_boss_wk_mortal_strike_debuff", "bosses/boss_wk/boss_wk_mortal_strike", LUA_MODIFIER_MOTION_NONE)

function modifier_boss_wk_mortal_strike_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS }
end

function modifier_boss_wk_mortal_strike_debuff:GetModifierExtraHealthBonus()
	return -self:GetStackCount()
end

modifier_boss_wk_mortal_strike_buff = class({})
LinkLuaModifier("modifier_boss_wk_mortal_strike_buff", "bosses/boss_wk/boss_wk_mortal_strike", LUA_MODIFIER_MOTION_NONE)

function modifier_boss_wk_mortal_strike_buff:DeclareFunctions()
	return {MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS }
end

function modifier_boss_wk_mortal_strike_buff:GetModifierExtraHealthBonus()
	return self:GetStackCount()
end