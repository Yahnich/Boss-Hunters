archangel_fraternitas = class({})

function archangel_fraternitas:GetIntrinsicModifierName()
	return "modifier_archangel_fraternitas"
end

modifier_archangel_fraternitas = class({})
LinkLuaModifier("modifier_archangel_fraternitas", "bosses/boss_archangel/archangel_fraternitas", LUA_MODIFIER_MOTION)

function modifier_archangel_fraternitas:OnCreated()
	self.duration = self:GetSpecialValueFor("duration")
end

function modifier_archangel_fraternitas:OnRefresh()
	self.duration = self:GetSpecialValueFor("duration")
end

function modifier_archangel_fraternitas:DeclareFunctions()
	return {MODIFIER_EVENT_ON_DEATH}
end

function modifier_archangel_fraternitas:OnDeath(params)
	if params.unit == self:GetParent() then
		params.unit:EmitSound("Hero_SkywrathMage.ConcussiveShot.Cast")
		for _, ally in ipairs( self:GetParent():FindFriendlyUnitsInRadius( self:GetParent():GetAbsOrigin(), 900 ) ) do
			ally:AddNewModifier( params.unit, self:GetAbility(), "modifier_archangel_fraternitas_buff", {duration = self.duration} )
			ally:RefreshAllCooldowns(false, false)
			ally:EmitSound("Hero_SkywrathMage.ConcussiveShot.Target")
		end
	end
end

function modifier_archangel_fraternitas:IsHidden()
	return true
end

modifier_archangel_fraternitas_buff = class({})
LinkLuaModifier("modifier_archangel_fraternitas_buff", "bosses/boss_archangel/archangel_fraternitas", LUA_MODIFIER_MOTION)

function modifier_archangel_fraternitas_buff:OnCreated()
	self.cdr = self:GetSpecialValueFor("cdr")
end

function modifier_archangel_fraternitas_buff:OnRefresh()
	self.cdr = self:GetSpecialValueFor("cdr")
end

function modifier_archangel_fraternitas_buff:DeclareFunctions()
	return {MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE_STACKING}
end

function modifier_archangel_fraternitas_buff:GetModifierPercentageCooldownStacking()
	return self.cdr
end

function modifier_archangel_fraternitas_buff:GetEffectName()
	return "skywrath_mage_concussive_shot_slow_debuff.vpcf"
end