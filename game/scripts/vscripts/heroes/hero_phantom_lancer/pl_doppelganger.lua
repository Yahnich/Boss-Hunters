pl_doppelganger = class({})
LinkLuaModifier("modifier_pl_doppelganger", "heroes/hero_phantom_lancer/pl_doppelganger", LUA_MODIFIER_MOTION_NONE)

function pl_doppelganger:IsStealable()
    return true
end

function pl_doppelganger:IsHiddenWhenStolen()
    return false
end

function pl_doppelganger:GetAOERadius()
    return self:GetTalentSpecialValueFor("target_aoe")
end

function pl_doppelganger:GetCooldown(iLvl)
    local cooldown = self.BaseClass.GetCooldown(self, iLvl)
    if self:GetCaster():HasTalent("special_bonus_unique_pl_doppelganger_2") then cooldown = cooldown + self:GetCaster():FindTalentValue("special_bonus_unique_pl_doppelganger_2") end
    return cooldown
end

function pl_doppelganger:GetCastRange( position, target )
	return self.BaseClass.GetCastRange( self, position, target ) + self:GetCaster():FindTalentValue("special_bonus_unique_pl_doppelganger_2", "value2")
end

function pl_doppelganger:OnSpellStart()
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()

    local delay = self:GetTalentSpecialValueFor("delay")

    local radius = self:GetTalentSpecialValueFor("target_aoe")
	caster:Dispel()
	ProjectileManager:ProjectileDodge( caster )
    EmitSoundOn("Hero_PhantomLancer.Doppelganger.Cast", caster)

    local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_phantom_lancer/phantom_lancer_doppleganger_aoe.vpcf", PATTACH_POINT, caster)
                ParticleManager:SetParticleControl(nfx, 0, caster:GetAbsOrigin())
                ParticleManager:SetParticleControl(nfx, 2, Vector(radius, radius, radius))
                ParticleManager:SetParticleControl(nfx, 3, Vector(1, 0, 0))
                ParticleManager:ReleaseParticleIndex(nfx)

    caster:AddNewModifier(caster, self, "modifier_pl_doppelganger", {Duration = delay})
end

modifier_pl_doppelganger = class({})
function modifier_pl_doppelganger:OnCreated(table)
    if IsServer() then
        local caster = self:GetCaster()
        local parent = self:GetParent()
        
        self.point = self:GetAbility():GetCursorPosition()

		self.radius = self:GetTalentSpecialValueFor("search_radius")
        local illusion_extended_duration = self:GetTalentSpecialValueFor("illusion_extended_duration")
        
        if not parent:IsIllusion() then
            local illusions = caster:FindFriendlyUnitsInRadius(parent:GetAbsOrigin(), self.radius)
            for _,illusion in pairs(illusions) do
                if illusion and illusion:IsIllusion() and illusion:GetOwner() == caster then 
                    --illusion:FindModifierByName("modifier_illusion"):SetDuration(illusion:FindModifierByName("modifier_illusion"):GetRemainingTime() + illusion_extended_duration, true)
                    illusion:AddNewModifier(caster, self:GetAbility(), "modifier_pl_doppelganger", {Duration = self:GetTalentSpecialValueFor("delay")})
                end
            end
		else
			local illuModifier = parent:FindModifierByName("modifier_illusion")
			self.duration = illuModifier:GetRemainingTime()
			self:StartIntervalThink(0)
        end

        local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_phantom_lancer/phantom_lancer_doppleganger_illlmove.vpcf", PATTACH_POINT, caster)
                    ParticleManager:SetParticleControlEnt(nfx, 0, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), false)
                    ParticleManager:SetParticleControlEnt(nfx, 1, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), false)

        self:AttachEffect(nfx)
        --parent:AddNoDraw()
    end
end

function modifier_pl_doppelganger:OnIntervalThink()
	local illuModifier = self:GetParent():FindModifierByName("modifier_illusion")
	illuModifier:SetDuration( self.duration, true )
end

function modifier_pl_doppelganger:DeclareFunctions()
    local funcs = {MODIFIER_PROPERTY_MODEL_CHANGE}
    return funcs
end

function modifier_pl_doppelganger:GetModifierModelChange()
    return "models/development/invisiblebox.vmdl"
end

function modifier_pl_doppelganger:OnRemoved()
    if IsServer() then
        local caster = self:GetCaster()
        local parent = self:GetParent()
		local radius = self:GetAbility():GetAOERadius()
        parent:RemoveNoDraw()
		ParticleManager:FireParticle("particles/units/heroes/hero_phantom_lancer/phantom_lancer_doppleganger_aoe.vpcf", PATTACH_WORLDORIGIN, nil, {[0] = self.point, [2] = Vector(radius,0,0)})
        if not parent:IsIllusion() then
			FindClearSpaceForUnit(parent, self.point, true)
            EmitSoundOn("Hero_PhantomLancer.Doppelganger.Appear", caster)
            
            local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_phantom_lancer/phantom_lancer_spawn.vpcf", PATTACH_POINT, caster)
                        ParticleManager:SetParticleControlEnt(nfx, 0, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
                        ParticleManager:SetParticleControlEnt(nfx, 1, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
                        ParticleManager:SetParticleControlEnt(nfx, 5, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
                        ParticleManager:ReleaseParticleIndex(nfx)

            local image_duration = self:GetTalentSpecialValueFor("illusion_duration")

            local image1_in = self:GetTalentSpecialValueFor("illusion_1_in") - 100
            local image1_out = self:GetTalentSpecialValueFor("illusion_1_out") - 100
            local image1 = caster:ConjureImage( {outgoing_damage = image1_out, incoming_damage = image1_in, scramble = true, illusion_modifier = "modifier_phantom_lancer_juxtapose_illusion", position = self.point + ActualRandomVector(radius)}, image_duration, caster, 1 )
			image1[1]:AddNewModifier( caster, self:GetAbility(), "modifier_pl_juxtapose_illusion", {} )
			image1[1]:SetThreat( caster:GetThreat() )

            local image2_in = self:GetTalentSpecialValueFor("illusion_2_in") - 100
            local image2_out = self:GetTalentSpecialValueFor("illusion_2_out") - 100
            local image2 = caster:ConjureImage( {outgoing_damage = image2_out, incoming_damage = image2_out, scramble = true, illusion_modifier = "modifier_phantom_lancer_juxtapose_illusion", position = self.point + ActualRandomVector(radius)}, image_duration, caster, 1 )
			image2[1]:AddNewModifier( caster, self:GetAbility(), "modifier_pl_juxtapose_illusion", {} )
			image2[1]:SetThreat( caster:GetThreat() )
		else
			FindClearSpaceForUnit(parent, self.point + ActualRandomVector(radius), true)
			local illuModifier = parent:FindModifierByName("modifier_illusion")
			illuModifier:SetDuration( illuModifier:GetRemainingTime() + self:GetTalentSpecialValueFor("illusion_extended_duration"), true )
			parent:SetThreat( caster:GetThreat() )
        end
		if caster:HasTalent("special_bonus_unique_pl_doppelganger_1") then
			local phantom = caster:FindAbilityByName("pl_phantom_rush")
			if phantom and phantom:IsTrained() then
				parent:AddNewModifier( caster, phantom, "modifier_pl_phantom_rush_agi", {duration = phantom:GetTalentSpecialValueFor("agility_duration")} )
			end
			if parent:IsRealHero() then
				for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), radius ) ) do
					caster:PerformGenericAttack(enemy, true)
				end
			end
		end
    end
end

function modifier_pl_doppelganger:CheckState()
    local state = { [MODIFIER_STATE_STUNNED] = true,
                    [MODIFIER_STATE_INVULNERABLE] = true,
                    [MODIFIER_STATE_NO_HEALTH_BAR] = true,
                    [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
                    [MODIFIER_STATE_UNSELECTABLE] = true,
                    [MODIFIER_STATE_UNTARGETABLE] = true }
    return state
end