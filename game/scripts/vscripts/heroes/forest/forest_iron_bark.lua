forest_iron_bark = class({})

function forest_iron_bark:GetIntrinsicModifierName()
	return "modifier_forest_iron_bark_passive"
end

modifier_forest_iron_bark_passive = class({})
LinkLuaModifier("modifier_forest_iron_bark_passive", "heroes/forest/forest_iron_bark.lua", 0)

function modifier_forest_iron_bark_passive:OnCreated()
	self.radius = self:GetSpecialValueFor("radius")
	self.duration = self:GetSpecialValueFor("duration")
end

function modifier_forest_iron_bark_passive:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ABILITY_FULLY_CAST}
end

function modifier_forest_iron_bark_passive:OnAbilityFullyCast(params)
	if params.unit == self:GetParent() and params.unit:HasAbility( params.ability:GetName() ) then
		local caster = self:GetParent()
		local allies = caster:FindFriendlyUnitsInRadius(caster:GetAbsOrigin(), self.radius)
		for _, ally in ipairs(allies) do
			self:AddIronBark(ally)
			if ally == caster and caster:HasScepter() then self:AddIronBark(caster) end
		end
	end
end

function modifier_forest_iron_bark_passive:AddIronBark(target)
	if self:GetCaster():HasTalent("forest_iron_bark_talent_1") then
		target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_forest_iron_bark_buff_talent", {duration = self.duration})
	else
		target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_forest_iron_bark_buff", {duration = self.duration})
	end
end


function modifier_forest_iron_bark_passive:IsHidden(target)
	return true
end

modifier_forest_iron_bark_buff = class({})
LinkLuaModifier("modifier_forest_iron_bark_buff", "heroes/forest/forest_iron_bark.lua", 0)

function modifier_forest_iron_bark_buff:OnCreated()
	self.armorLvl = self:GetSpecialValueFor("armor_per_level")
	self.casterLvl = 1
	
	self:SetStackCount(1)
	
	if IsServer() then
		local barkFX = ParticleManager:CreateParticle( "particles/heroes/forest/forest_iron_bark.vpcf", PATTACH_POINT_FOLLOW, self:GetParent() )
		ParticleManager:SetParticleControlEnt(barkFX, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		ParticleManager:SetParticleControl(barkFX, 1, Vector( self:GetParent():GetHullRadius() + 40, 150, 500) )
		self:AddEffect(barkFX)
	end
end

function modifier_forest_iron_bark_buff:OnRefresh()
	self.armorLvl = self:GetSpecialValueFor("armor_per_level")
	self.casterLvl = 1
	
	self:AddIndependentStack()
end

function modifier_forest_iron_bark_buff:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end

function modifier_forest_iron_bark_buff:GetModifierPhysicalArmorBonus()
	return self.armorLvl * self.casterLvl * self:GetStackCount()
end

modifier_forest_iron_bark_buff_talent = class({})
LinkLuaModifier("modifier_forest_iron_bark_buff_talent", "heroes/forest/forest_iron_bark.lua", 0)

function modifier_forest_iron_bark_buff_talent:OnCreated()
	self.armorLvl = self:GetSpecialValueFor("armor_per_level")
	self.mrLvl = self:GetSpecialValueFor("talent_mr_per_level")
	self.drLvl = self:GetSpecialValueFor("talent_dr_per_level")
	
	self.casterLvl = 1
	
	self:SetStackCount(1)
end

function modifier_forest_iron_bark_buff_talent:OnRefresh()
	self.armorLvl = self:GetSpecialValueFor("armor_per_level")
	self.mrLvl = self:GetSpecialValueFor("talent_mr_per_level")
	self.drLvl = self:GetSpecialValueFor("talent_dr_per_level")
	
	self.casterLvl = 1
	
	self:AddIndependentStack()
end

function modifier_forest_iron_bark_buff_talent:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS, MODIFIER_PROPERTY_TOOLTIP}
end

function modifier_forest_iron_bark_buff_talent:GetModifierPhysicalArmorBonus()
	return self.armorLvl * self.casterLvl * self:GetStackCount()
end

function modifier_forest_iron_bark_buff_talent:GetModifierMagicalResistanceBonus()
	return self.mrLvl * self.casterLvl * self:GetStackCount()
end

function modifier_forest_iron_bark_buff_talent:BonusDebuffDuration_Constant()
	return self.drLvl * self.casterLvl * self:GetStackCount()
end

function modifier_forest_iron_bark_buff_talent:OnTooltip()
	return self.drLvl * self.casterLvl * self:GetStackCount()
end