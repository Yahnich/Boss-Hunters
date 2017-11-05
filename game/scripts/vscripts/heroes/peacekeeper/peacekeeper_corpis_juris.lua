peacekeeper_corpus_jurius = class({})
LinkLuaModifier( "modifier_corpus_jurius", "heroes/peacekeeper/peacekeeper_corpus_jurius.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------
function peacekeeper_corpus_jurius:OnSpellStart()
	self.caster = self:GetCaster()
	self.cursorTar = self:GetCursorTarget()

	self.duration = self:GetSpecialValueFor("duration")

	self.multiplier = 0 

	for i=0,9 do
		local ability = self.caster:GetAbilityByIndex(i)
		
		if not ability:IsCooldownReady() and ability ~= self and ability:GetAbilityType() == self:GetAbilityType() then
			ability:EndCooldown()
			self.multiplier = self.multiplier + 1
		end
	end

	if self.multiplier > 0 then
		self.caster:AddNewModifier(self.caster,self,"modifier_corpus_jurius",{Duration=self.duration}):SetStackCount(self.multiplier)
	else
		self:EndCooldown()
		self:RefundManaCost()
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
modifier_corpus_jurius = class({})

function modifier_corpus_jurius:OnCreated(table)
	self.caster = self:GetCaster()

	self.bonus_damage = self:GetSpecialValueFor("bonus_damage") * self:GetStackCount()
	self.bonus_move = self:GetSpecialValueFor("bonus_move") * self:GetStackCount()
end

function modifier_corpus_jurius:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE
	}
	return funcs
end


function modifier_corpus_jurius:GetModifierMoveSpeedBonus_Percentage( params )
	return self.bonus_move
end

function modifier_corpus_jurius:GetModifierDamageOutgoing_Percentage( params )
	return self.bonus_damage
end