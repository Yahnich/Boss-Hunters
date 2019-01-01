abaddon_curse_ebf = class({})

function abaddon_curse_ebf:GetIntrinsicModifierName()
	return "modifier_abaddon_curse_passive"
end

LinkLuaModifier( "modifier_abaddon_curse_passive", "heroes/hero_abaddon/abaddon_curse_ebf", LUA_MODIFIER_MOTION_NONE )
modifier_abaddon_curse_passive = class({})

function modifier_abaddon_curse_passive:OnCreated()
	self.duration = self:GetAbility():GetTalentSpecialValueFor("buff_duration")
end

function modifier_abaddon_curse_passive:OnRefresh()
	self.duration = self:GetAbility():GetTalentSpecialValueFor("buff_duration")
end

function modifier_abaddon_curse_passive:IsHidden()
	return true
end

function modifier_abaddon_curse_passive:DeclareFunctions()
	funcs = {
				MODIFIER_EVENT_ON_TAKEDAMAGE
			}
	return funcs
end

function modifier_abaddon_curse_passive:OnTakeDamage(params)
	if IsServer() then
		if params.attacker == self:GetParent() and not params.unit:HasModifier("modifier_abaddon_curse_curse") then
			params.unit:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_abaddon_curse_debuff", {duration = self.duration} )
		end
	end
end

LinkLuaModifier( "modifier_abaddon_curse_buff", "heroes/hero_abaddon/abaddon_curse_ebf", LUA_MODIFIER_MOTION_NONE )
modifier_abaddon_curse_buff = class({})

function modifier_abaddon_curse_buff:OnCreated()
	self.cdr = self:GetAbility():GetTalentSpecialValueFor("buff_cdr")
	self.attackspeed = self:GetAbility():GetTalentSpecialValueFor("buff_as")
end

function modifier_abaddon_curse_buff:DeclareFunctions()
	funcs = {
				MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
			}
	return funcs
end

function modifier_abaddon_curse_buff:GetCooldownReduction()
	return self.cdr
end

function modifier_abaddon_curse_buff:GetModifierAttackSpeedBonus()
	return self.attackspeed
end

function modifier_abaddon_curse_buff:GetEffectName()
	return "particles/units/heroes/hero_abaddon/abaddon_frost_buff.vpcf"
end

LinkLuaModifier( "modifier_abaddon_curse_debuff", "heroes/hero_abaddon/abaddon_curse_ebf", LUA_MODIFIER_MOTION_NONE )
modifier_abaddon_curse_debuff = class({})

function modifier_abaddon_curse_debuff:OnCreated()
	self.movespeed = self:GetAbility():GetTalentSpecialValueFor("initial_slow")
	self.trigger_count = self:GetAbility():GetTalentSpecialValueFor("trigger_count")
	if IsServer() then
		self:IncrementStackCount()
	end
end

function modifier_abaddon_curse_debuff:OnRefresh()
	self.movespeed = self:GetAbility():GetTalentSpecialValueFor("initial_slow")
	self.trigger_count = self:GetAbility():GetTalentSpecialValueFor("trigger_count")
	if IsServer() then
		self:IncrementStackCount()
		if self:GetStackCount() >= self.trigger_count then
			self:Destroy()
			
			local caster =  self:GetCaster()
			local parent = self:GetParent()
			local ability =  self:GetAbility()
			local duration = self:GetTalentSpecialValueFor("buff_duration")
			parent:AddNewModifier( caster, ability, "modifier_abaddon_curse_curse", {duration = duration})
			for _, ally in ipairs( self:GetCaster():FindFriendlyUnitsInRadius( parent:GetAbsOrigin(), self:GetTalentSpecialValueFor("trigger_radius") ) ) do
				if ally ~= caster then ally:AddNewModifier( caster, ability, "modifier_abaddon_curse_buff", {duration = duration}) end
			end
			caster:AddNewModifier( caster, ability, "modifier_abaddon_curse_buff", {duration = duration})
			
			ParticleManager:FireParticle("particles/abaddon_brume_proc.vpcf", PATTACH_POINT_FOLLOW, parent)
		end
	end
end

function modifier_abaddon_curse_debuff:DeclareFunctions()
	funcs = {
				MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
				
			}
	return funcs
end

function modifier_abaddon_curse_debuff:GetModifierMoveSpeedBonus_Percentage()
	return self.movespeed
end

function modifier_abaddon_curse_debuff:GetEffectName()
	return "particles/units/heroes/hero_abaddon/abaddon_frost_slow.vpcf"
end

LinkLuaModifier( "modifier_abaddon_curse_curse", "heroes/hero_abaddon/abaddon_curse_ebf", LUA_MODIFIER_MOTION_NONE )
modifier_abaddon_curse_curse = class({})

function modifier_abaddon_curse_curse:GetEffectName()
	return "particles/units/heroes/hero_abaddon/abaddon_frost_slow.vpcf"
end

function modifier_abaddon_curse_curse:OnCreated()
	self.movespeed = self:GetAbility():GetTalentSpecialValueFor("curse_slow")
	self.attackspeed = self:GetAbility():GetTalentSpecialValueFor("curse_as")
end

function modifier_abaddon_curse_curse:DeclareFunctions()
	funcs = {
				MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
			}
	return funcs
end

function modifier_abaddon_curse_curse:GetModifierMoveSpeedBonus_Percentage()
	return self.movespeed
end

function modifier_abaddon_curse_curse:GetModifierAttackSpeedBonus()
	return self.attackspeed
end

function modifier_abaddon_curse_curse:GetEffectName()
	return "particles/units/heroes/hero_abaddon/abaddon_frost_slow.vpcf"
end