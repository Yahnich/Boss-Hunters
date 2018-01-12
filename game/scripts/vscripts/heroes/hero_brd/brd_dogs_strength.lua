brd_dogs_strength = class({})
LinkLuaModifier( "modifier_dogs_strength", "heroes/hero_brd/brd_dogs_strength.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_dogs_strength_stack", "heroes/hero_brd/brd_dogs_strength.lua" ,LUA_MODIFIER_MOTION_NONE )

function brd_dogs_strength:GetIntrinsicModifierName()
	return "modifier_dogs_strength"
end

modifier_dogs_strength = class({})
function modifier_dogs_strength:OnCreated(table)
	if IsServer() then
		self:StartIntervalThink(FrameTime())
	end
end

function modifier_dogs_strength:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_HEALTH_BONUS,
	}
	return funcs
end

function modifier_dogs_strength:GetModifierPhysicalArmorBonus()
	return self:GetSpecialValueFor("bonus_health")
end

function modifier_dogs_strength:IsHidden()
	return true
end

function modifier_dogs_strength:OnIntervalThink()
	local caster = self:GetCaster()

	if caster:GetHealthPercent() < 100 then
		caster:AddNewModifier(caster, self:GetAbility(), "modifier_dogs_strength_stack", {}):SetStackCount(1)
		if caster:GetHealthPercent() < 90 then
			caster:AddNewModifier(caster, self:GetAbility(), "modifier_dogs_strength_stack", {}):SetStackCount(2)
			if caster:GetHealthPercent() < 80 then
				caster:AddNewModifier(caster, self:GetAbility(), "modifier_dogs_strength_stack", {}):SetStackCount(3)
				if caster:GetHealthPercent() < 70 then
					caster:AddNewModifier(caster, self:GetAbility(), "modifier_dogs_strength_stack", {}):SetStackCount(4)
					if caster:GetHealthPercent() < 60 then
						caster:AddNewModifier(caster, self:GetAbility(), "modifier_dogs_strength_stack", {}):SetStackCount(5)
						if caster:GetHealthPercent() < 50 then
							caster:AddNewModifier(caster, self:GetAbility(), "modifier_dogs_strength_stack", {}):SetStackCount(6)
							if caster:GetHealthPercent() < 40 then
								caster:AddNewModifier(caster, self:GetAbility(), "modifier_dogs_strength_stack", {}):SetStackCount(7)
								if caster:GetHealthPercent() < 30 then
									caster:AddNewModifier(caster, self:GetAbility(), "modifier_dogs_strength_stack", {}):SetStackCount(8)
									if caster:GetHealthPercent() < 20 then
										caster:AddNewModifier(caster, self:GetAbility(), "modifier_dogs_strength_stack", {}):SetStackCount(9)
										if caster:GetHealthPercent() < 10 then
											caster:AddNewModifier(caster, self:GetAbility(), "modifier_dogs_strength_stack", {}):SetStackCount(10)
										end
									end
								end
							end
						end
					end
				end
			end
		end
	elseif caster:GetHealthPercent() == 100 then
		caster:RemoveModifierByName("modifier_dogs_strength_stack")
	end
end

modifier_dogs_strength_stack = class({})
function modifier_dogs_strength_stack:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
	}
	return funcs
end

function modifier_dogs_strength_stack:GetModifierPhysicalArmorBonus()
	return self:GetSpecialValueFor("bonus_armor") * self:GetStackCount()
end

function modifier_dogs_strength_stack:IsDebuff()
	return false
end