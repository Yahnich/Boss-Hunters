tide_turtle_shell = class({})
LinkLuaModifier( "modifier_turtle_shell", "heroes/hero_tide/tide_turtle_shell.lua" ,LUA_MODIFIER_MOTION_NONE )

function tide_turtle_shell:GetIntrinsicModifierName()
    return "modifier_turtle_shell"
end

function tide_turtle_shell:ShouldUseResources()
	return true
end

modifier_turtle_shell = class({})
function modifier_turtle_shell:OnCreated()
    self.blockPct = self:GetAbility():GetSpecialValueFor("damage_reduction_mult")
    self.crit = self:GetAbility():GetSpecialValueFor("critical_chance")
    self.heal = self:GetAbility():GetSpecialValueFor("critical_heal") / 100
    self.currBlock = 0
end

function modifier_turtle_shell:DeclareFunctions()
    funcs = {
                MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK,
            }
    return funcs
end

function modifier_turtle_shell:IsHidden()
    return true
end

function modifier_turtle_shell:GetModifierTotal_ConstantBlock(params)
    if IsServer() and params.attacker ~= self:GetParent() then
        self.currBlock = self:GetParent():GetPhysicalArmorValue(false) * self.blockPct
        if RollPercentage(self.crit) and self:GetAbility():IsCooldownReady() then 
            self.currBlock = self.currBlock * 2
            self:GetParent():HealEvent(self:GetParent():GetMaxHealth() * self.heal, self:GetAbility(), self:GetParent())
            ParticleManager:FireParticle( "particles/units/heroes/hero_tidehunter/tidehunter_krakenshell_purge.vpcf", PATTACH_POINT_FOLLOW, self:GetParent() )
            EmitSoundOn("Hero_Tidehunter.KrakenShell", self:GetParent())
            self:GetParent():Dispel(self:GetParent(), true)

            if self:GetParent():HasScepter() then
                local friends = caster:FindFriendlyUnitsInRadius(point, 350, {})
                for _,friend in pairs(friends) do
                    if friend ~= self:GetParent() then
						ParticleManager:FireParticle( "particles/units/heroes/hero_tidehunter/tidehunter_krakenshell_purge.vpcf", PATTACH_POINT_FOLLOW, friend )
                        self:GetParent():HealEvent(self:GetParent():GetMaxHealth() * self.heal, self:GetAbility(), self:GetParent())
                        self:GetParent():Purge(false, true, false, true, true)
                    end
                end
            end
			self:GetAbility():SetCooldown()
        end
        return self.currBlock
    end
end