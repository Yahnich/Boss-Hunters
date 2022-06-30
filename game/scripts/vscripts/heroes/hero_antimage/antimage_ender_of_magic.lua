antimage_ender_of_magic = class ({})

function antimage_ender_of_magic:GetIntrinsicModifierName()
	return "modifier_antimage_ender_of_magic_handler"
end

modifier_antimage_ender_of_magic_handler = class({})
LinkLuaModifier( "modifier_antimage_ender_of_magic_handler", "heroes/hero_antimage/antimage_ender_of_magic", LUA_MODIFIER_MOTION_NONE )

function modifier_antimage_ender_of_magic_handler:OnCreated()
	self.duration = self:GetTalentSpecialValueFor("duration")
	self.radius = self:GetTalentSpecialValueFor("radius")
end

function modifier_antimage_ender_of_magic_handler:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ABILITY_EXECUTED}
end

function modifier_antimage_ender_of_magic_handler:OnAbilityExecuted(params)
	if CalculateDistance( params.unit, self:GetParent() ) < self.radius and params.ability and not params.ability:IsItem() and params.ability:GetCooldown(-1) ~= 0 then
		self:GetParent():AddNewModifier( self:GetParent(), self:GetAbility(), "modifier_antimage_ender_of_magic_buff", {duration = self.duration})
	end
end

function modifier_antimage_ender_of_magic_handler:IsHidden()
	return true
end

modifier_antimage_ender_of_magic_buff = class({})
LinkLuaModifier( "modifier_antimage_ender_of_magic_buff", "heroes/hero_antimage/antimage_ender_of_magic", LUA_MODIFIER_MOTION_NONE )

function modifier_antimage_ender_of_magic_buff:OnCreated()
	self:OnRefresh()
end

function modifier_antimage_ender_of_magic_buff:OnRefresh()
	self.as = TernaryOperator( self:GetTalentSpecialValueFor("scepter_as"), self:GetCaster():HasScepter(), self:GetTalentSpecialValueFor("bonus_attackspeed") )
	self.ms = TernaryOperator( self:GetTalentSpecialValueFor("scepter_ms"), self:GetCaster():HasScepter(), self:GetTalentSpecialValueFor("bonus_movespeed") )
	self.limit = TernaryOperator( self:GetTalentSpecialValueFor("scepter_stacks"), self:GetCaster():HasScepter(), self:GetTalentSpecialValueFor("max_stacks") )
	if IsServer() then
		self:AddIndependentStack( self:GetRemainingTime(), self.limit )
	end
end

function modifier_antimage_ender_of_magic_buff:DeclareFunctions()
	return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
			 MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}
end

function modifier_antimage_ender_of_magic_buff:GetModifierAttackSpeedBonus_Constant()
	return self.as * self:GetStackCount()
end

function modifier_antimage_ender_of_magic_buff:GetModifierMoveSpeedBonus_Percentage()
	return self.ms * self:GetStackCount()
end