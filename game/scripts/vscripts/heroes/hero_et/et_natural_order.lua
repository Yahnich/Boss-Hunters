et_natural_order = class({})
LinkLuaModifier( "modifier_et_natural_order_handle", "heroes/hero_et/et_natural_order.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_et_natural_order_both", "heroes/hero_et/et_natural_order.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_et_natural_order_magic", "heroes/hero_et/et_natural_order.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_et_natural_order_phys", "heroes/hero_et/et_natural_order.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_et_natural_order_enemy_both", "heroes/hero_et/et_natural_order.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_et_natural_order_enemy_magic", "heroes/hero_et/et_natural_order.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_et_natural_order_enemy_phys", "heroes/hero_et/et_natural_order.lua",LUA_MODIFIER_MOTION_NONE )

function et_natural_order:GetAbilityTextureName()
	if self:GetCaster():HasModifier("modifier_elder_spirit") or self:GetCaster():HasModifier("modifier_elder_spirit_check_out") then
		return "elder_titan_natural_order_spirit"
	end

	return "elder_titan_natural_order"
end

function et_natural_order:GetIntrinsicModifierName()
    return "modifier_et_natural_order_handle"
end

modifier_et_natural_order_handle = class({})
function modifier_et_natural_order_handle:OnCreated(table)
	if IsServer() then
		self:StartIntervalThink(FrameTime())
	end
end

function modifier_et_natural_order_handle:OnIntervalThink()
	if not self:GetParent():HasModifier("modifier_elder_spirit") then
		if self:GetParent():HasModifier("modifier_elder_spirit_check") then 
			self:GetParent():RemoveModifierByName("modifier_et_natural_order_magic")
			self:GetParent():RemoveModifierByName("modifier_et_natural_order_phys")
			if not self:GetParent():HasModifier("modifier_et_natural_order_both") then
    			self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_et_natural_order_both", {})
    		end
    	else
    		if self:GetParent():HasModifier("modifier_elder_spirit_check_out") then
				self:GetParent():RemoveModifierByName("modifier_et_natural_order_both")
				self:GetParent():RemoveModifierByName("modifier_et_natural_order_magic")
				if not self:GetParent():HasModifier("modifier_et_natural_order_phys") then
					self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_et_natural_order_phys", {})
				end
			else
				self:GetParent():RemoveModifierByName("modifier_et_natural_order_magic")
				self:GetParent():RemoveModifierByName("modifier_et_natural_order_phys")
    			if not self:GetParent():HasModifier("modifier_et_natural_order_both") then
    				self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_et_natural_order_both", {})
    			end
			end
    	end
    else
    	self:GetParent():RemoveModifierByName("modifier_et_natural_order_both")
		self:GetParent():RemoveModifierByName("modifier_et_natural_order_phys")
		if not self:GetParent():HasModifier("modifier_et_natural_order_magic") then
    		self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_et_natural_order_magic", {})
    	end
    end
end

function modifier_et_natural_order_handle:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS
    }
    return funcs
end

function modifier_et_natural_order_handle:GetModifierPhysicalArmorBonus()
	local bonus = 0
	if self:GetCaster():HasScepter() then
		bonus = self:GetCaster():GetPhysicalArmorBaseValue() * (-self:GetSpecialValueFor("reduc")) / 100
	end
	return bonus
end

function modifier_et_natural_order_handle:GetModifierMagicalResistanceBonus()
	local bonus = 0
	if self:GetCaster():HasScepter() then
		bonus = -self:GetSpecialValueFor("reduc")
	end
	return bonus
end

function modifier_et_natural_order_handle:IsHidden()
	return true
end

modifier_et_natural_order_both = class({})
function modifier_et_natural_order_both:IsAura()
    return true
end

function modifier_et_natural_order_both:GetAuraDuration()
    return 0.5
end

function modifier_et_natural_order_both:GetAuraRadius()
    return self:GetSpecialValueFor("radius")
end

function modifier_et_natural_order_both:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_et_natural_order_both:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_et_natural_order_both:GetAuraSearchType()
    return DOTA_UNIT_TARGET_ALL
end

function modifier_et_natural_order_both:GetModifierAura()
   	return "modifier_et_natural_order_enemy_both"
end

function modifier_et_natural_order_both:IsAuraActiveOnDeath()
    return false
end

function modifier_et_natural_order_both:IsHidden()
    return true
end

modifier_et_natural_order_phys = class({})
function modifier_et_natural_order_phys:IsAura()
    return true
end

function modifier_et_natural_order_phys:GetAuraDuration()
    return 0.5
end

function modifier_et_natural_order_phys:GetAuraRadius()
    return self:GetSpecialValueFor("radius")
end

function modifier_et_natural_order_phys:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_et_natural_order_phys:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_et_natural_order_phys:GetAuraSearchType()
    return DOTA_UNIT_TARGET_ALL
end

function modifier_et_natural_order_phys:GetModifierAura()
   	return "modifier_et_natural_order_enemy_phys"
end

function modifier_et_natural_order_phys:IsAuraActiveOnDeath()
    return false
end

function modifier_et_natural_order_phys:IsHidden()
    return true
end

modifier_et_natural_order_magic = class({})
function modifier_et_natural_order_magic:IsAura()
    return true
end

function modifier_et_natural_order_magic:GetAuraDuration()
    return 0.5
end

function modifier_et_natural_order_magic:GetAuraRadius()
    return self:GetSpecialValueFor("radius")
end

function modifier_et_natural_order_magic:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_et_natural_order_magic:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_et_natural_order_magic:GetAuraSearchType()
    return DOTA_UNIT_TARGET_ALL
end

function modifier_et_natural_order_magic:GetModifierAura()
   	return "modifier_et_natural_order_enemy_magic"
end

function modifier_et_natural_order_magic:IsAuraActiveOnDeath()
    return false
end

function modifier_et_natural_order_magic:IsHidden()
    return true
end

modifier_et_natural_order_enemy_both = class({})
function modifier_et_natural_order_enemy_both:OnCreated(table)
	self.armor1 = -(self:GetParent():GetPhysicalArmorValue(false) + self:GetParent():GetPhysicalArmorValue(false) * self:GetSpecialValueFor("reduc")/100)
	if IsServer() then
		self.nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_elder_titan/elder_titan_natural_order_magical.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControl(self.nfx, 0, self:GetParent():GetAbsOrigin())
	end
end

function modifier_et_natural_order_enemy_both:OnRemoved()
	if IsServer() then
		ParticleManager:DestroyParticle(self.nfx, false)
	end
end

function modifier_et_natural_order_enemy_both:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS
    }
    return funcs
end

function modifier_et_natural_order_enemy_both:GetModifierPhysicalArmorBonus()
	return self.armor1
end

function modifier_et_natural_order_enemy_both:GetModifierMagicalResistanceBonus()
	return self:GetSpecialValueFor("reduc")
end

function modifier_et_natural_order_enemy_both:GetEffectName()
	return "particles/units/heroes/hero_elder_titan/elder_titan_natural_order_physical.vpcf"
end

modifier_et_natural_order_enemy_phys = class({})
function modifier_et_natural_order_enemy_phys:OnCreated(table)
	self.armor2 = -(self:GetParent():GetPhysicalArmorValue(false) + self:GetParent():GetPhysicalArmorValue(false) * self:GetSpecialValueFor("reduc")/100)
end

function modifier_et_natural_order_enemy_phys:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
    }
    return funcs
end

function modifier_et_natural_order_enemy_phys:GetModifierPhysicalArmorBonus()
	return self.armor2
end

function modifier_et_natural_order_enemy_phys:GetEffectName()
	return "particles/units/heroes/hero_elder_titan/elder_titan_natural_order_physical.vpcf"
end

modifier_et_natural_order_enemy_magic = class({})
function modifier_et_natural_order_enemy_magic:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS
    }
    return funcs
end

function modifier_et_natural_order_enemy_magic:GetModifierMagicalResistanceBonus()
	return self:GetSpecialValueFor("reduc")
end

function modifier_et_natural_order_enemy_magic:GetEffectName()
	return "particles/units/heroes/hero_elder_titan/elder_titan_natural_order_magical.vpcf"
end