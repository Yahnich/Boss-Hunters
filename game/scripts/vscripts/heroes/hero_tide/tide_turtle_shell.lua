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
    self.blockPct = self:GetAbility():GetSpecialValueFor("damage_reduction_pct") / 100
    self.crit = self:GetAbility():GetSpecialValueFor("critical_chance")
    self.heal = self:GetAbility():GetSpecialValueFor("critical_heal") / 100
    self.currBlock = 0
end

function modifier_turtle_shell:DeclareFunctions()
    funcs = {
                MODIFIER_PROPERTY_PHYSICAL_CONSTANT_BLOCK,
            }
    return funcs
end

function modifier_turtle_shell:IsHidden()
    return true
end

function modifier_turtle_shell:GetModifierPhysical_ConstantBlock(params)
    if IsServer() then
        self.currBlock = params.damage * self.blockPct
        if RollPercentage(self.crit) and self:GetAbility():IsCooldownReady() then 
            self.currBlock = self.currBlock * 2
            self:GetParent():HealEvent(self:GetParent():GetMaxHealth() * self.heal, self:GetAbility(), self:GetParent())
            local FXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_tidehunter/tidehunter_krakenshell_purge.vpcf", PATTACH_POINT_FOLLOW, self:GetParent() )
                ParticleManager:SetParticleControl( FXIndex, 0, self:GetParent():GetOrigin() )
            ParticleManager:ReleaseParticleIndex(FXIndex)
            EmitSoundOn("Hero_Tidehunter.KrakenShell", self:GetParent())
            self:GetParent():Purge(false, true, false, true, true)

            if self:GetParent():HasScepter() then
                local friends = caster:FindFriendlyUnitsInRadius(point, 350, {})
                for _,friend in pairs(friends) do
                    if friend ~= self:GetParent() then
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