pl_phantom_rush = class({})
LinkLuaModifier("modifier_pl_phantom_rush", "heroes/hero_phantom_lancer/pl_phantom_rush", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_pl_phantom_rush_speed", "heroes/hero_phantom_lancer/pl_phantom_rush", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_pl_phantom_rush_agi", "heroes/hero_phantom_lancer/pl_phantom_rush", LUA_MODIFIER_MOTION_NONE)

function pl_phantom_rush:IsStealable()
    return true
end

function pl_phantom_rush:IsHiddenWhenStolen()
    return false
end

function pl_phantom_rush:GetCastRange( target, location)
	return self:GetTalentSpecialValueFor("max_distance")
end

function pl_phantom_rush:GetCooldown( iLvl )
	return self.BaseClass.GetCooldown( self, iLvl ) + self:GetCaster():FindTalentValue("special_bonus_unique_pl_phantom_rush_2")
end

function pl_phantom_rush:GetIntrinsicModifierName()
    return "modifier_pl_phantom_rush"
end

modifier_pl_phantom_rush = class({})

function modifier_pl_phantom_rush:DeclareFunctions()
    local funcs = { MODIFIER_EVENT_ON_ORDER,
                    MODIFIER_EVENT_ON_ATTACK_START,
					MODIFIER_EVENT_ON_ATTACK_LANDED}
    return funcs
end

function modifier_pl_phantom_rush:OnOrder(params)
    if IsServer() then
        local caster = self:GetCaster()
        local parent = params.unit
        local target = params.target
        local caster_origin = caster:GetAbsOrigin()
		
		if params.unit ~= caster or params.ability then return end
        
        local ability = self:GetAbility()
        local cooldown = ability:GetCooldown(ability:GetLevel())
        local min_distance = self:GetTalentSpecialValueFor("min_distance")
        local max_distance = self:GetTalentSpecialValueFor("max_distance")
        local duration = 5
        
        -- Checks if the ability is off cooldown and if the caster is attacking a target
        if target ~= null and ability:IsCooldownReady() and not ability:GetAutoCastState() and CalculateDistance then
			if caster:HasTalent("special_bonus_unique_pl_phantom_rush_1") and CalculateDistance( caster, target) < max_distance then
				local agiDuration = self:GetTalentSpecialValueFor("agility_duration")
				local blinkPos = target:GetAbsOrigin() - target:GetForwardVector() * (parent:GetAttackRange() - 25)
				ParticleManager:FireParticle("particles/units/heroes/hero_phantom_lancer/phantom_lancer_deathflash.vpcf", PATTACH_WORLDORIGIN, nil, {[0] = parent:GetAbsOrigin() + Vector(0,0,32)} )
				FindClearSpaceForUnit( parent, blinkPos, true )
				ParticleManager:FireParticle("particles/units/heroes/hero_phantom_lancer/phantom_lancer_deathflash.vpcf", PATTACH_WORLDORIGIN, nil, {[0] = blinkPos + Vector(0,0,32)} )
				self.rootAttack = true
				caster:AddNewModifier(caster, self:GetAbility(), "modifier_pl_phantom_rush_agi", {Duration = agiDuration})
				ability:SetCooldown()
				if caster:HasScepter() and caster:IsRealHero() then
					local juxtapose = caster:FindAbilityByName("pl_juxtapose")
					if juxtapose then
						local illusion = juxtapose:SpawnIllusion( true )
						illusion:SetThreat( caster:GetThreat() )
					end
				end
			else
				-- Checks if the target is an enemy
				if caster:GetTeam() ~= target:GetTeam() then
					local target_origin = target:GetAbsOrigin()
					local distance = CalculateDistance(target, caster)
					ability.target = target
					-- Checks if the caster is in range of the target
					if distance >= min_distance and distance <= max_distance then
						-- Removes the 522 move speed cap
						caster:AddNewModifier(caster, ability, "modifier_pl_phantom_rush_speed", { duration = duration })
						-- Start cooldown on the passive
						ability:SetCooldown()
					-- If the caster is too far from the target, we continuously check his distance until the attack command is canceled
					elseif distance >= max_distance then
						distance = CalculateDistance(target, caster)
					end
				end
			end
        elseif not target then
            caster:RemoveModifierByName("modifier_pl_phantom_rush_speed")
        end
    end
end

function modifier_pl_phantom_rush:OnAttackLanded(params)
    if IsServer() then
        local caster = self:GetCaster()
		local ability = self:GetAbility()
        local attacker = params.attacker

        if attacker == caster and self.rootAttack then
			params.target:Root(ability, caster, caster:FindTalentValue("special_bonus_unique_pl_phantom_rush_1"))
			self.rootAttack = false
        end
    end
end

function modifier_pl_phantom_rush:OnAttackStart(params)
    if IsServer() then
        local caster = self:GetCaster()
        local target = params.target
		local ability = self:GetAbility()
        local attacker = params.attacker
		
        if attacker == caster then
			local agiDuration = self:GetTalentSpecialValueFor("agility_duration")
			if caster:HasModifier("modifier_pl_phantom_rush_speed") then
				caster:AddNewModifier(caster, self:GetAbility(), "modifier_pl_phantom_rush_agi", {Duration = agiDuration})
				caster:RemoveModifierByName("modifier_pl_phantom_rush_speed")
				if caster:HasScepter() and caster:IsRealHero() then
					local juxtapose = caster:FindAbilityByName("pl_juxtapose")
					if juxtapose then
						local illusion = juxtapose:SpawnIllusion( true )
						illusion:SetThreat( caster:GetThreat() )
					end
				end
			elseif ability:IsCooldownReady() and not ability:GetAutoCastState() then
				caster:AddNewModifier(caster, self:GetAbility(), "modifier_pl_phantom_rush_agi", {Duration = agiDuration})
				ability:SetCooldown()
				if caster:HasScepter() and caster:IsRealHero() then
					local juxtapose = caster:FindAbilityByName("pl_juxtapose")
					if juxtapose then
						local illusion = juxtapose:SpawnIllusion( true )
						illusion:SetThreat( caster:GetThreat() )
					end
				end
				if caster:HasTalent("special_bonus_unique_pl_phantom_rush_1") then
					local blinkPos = target:GetAbsOrigin() - target:GetForwardVector() * (attacker:GetAttackRange() - 25)
					ParticleManager:FireParticle("particles/units/heroes/hero_phantom_lancer/phantom_lancer_deathflash.vpcf", PATTACH_WORLDORIGIN, nil, {[0] = attacker:GetAbsOrigin() + Vector(0,0,32)} )
					FindClearSpaceForUnit( attacker, blinkPos, true )
					ParticleManager:FireParticle("particles/units/heroes/hero_phantom_lancer/phantom_lancer_deathflash.vpcf", PATTACH_WORLDORIGIN, nil, {[0] = blinkPos + Vector(0,0,32)} )
					self.rootAttack = true
				end
			end
        end
    end
end

function modifier_pl_phantom_rush:GetEffectName()
    return "particles/units/heroes/hero_phantom_lancer/phantomlancer_edge_boost.vpcf"
end

function modifier_pl_phantom_rush:IsHidden()
    return true
end

function modifier_pl_phantom_rush:IsPurgable()
    return false
end

function modifier_pl_phantom_rush:IsPurgeException()
    return false
end

function modifier_pl_phantom_rush:IsPermanent()
    return true
end

modifier_pl_phantom_rush_speed = class({})
function modifier_pl_phantom_rush_speed:OnCreated(table)
	self:OnRefresh()
end

function modifier_pl_phantom_rush_speed:OnRefresh(table)
    self.bonus_ms = self:GetTalentSpecialValueFor("bonus_speed")
    self:GetParent():HookInModifier("GetMoveSpeedLimitBonus", self)
end

function modifier_pl_phantom_rush_speed:OnDestroy(table)
    self:GetParent():HookOutModifier("GetMoveSpeedLimitBonus", self)
end

function modifier_pl_phantom_rush_speed:DeclareFunctions()
    return {MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT, }
end

function modifier_pl_phantom_rush_speed:GetModifierMoveSpeedBonus_Constant()
    return self.bonus_ms
end

function modifier_pl_phantom_rush_speed:GetMoveSpeedLimitBonus()
    return self.bonus_ms
end

function modifier_pl_phantom_rush_speed:CheckState()
    local state = { [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
                    [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true }
    return state
end

function modifier_pl_phantom_rush_speed:IsDebuff()
    return false
end

function modifier_pl_phantom_rush_speed:IsPurgable()
    return true
end

modifier_pl_phantom_rush_agi = class({})
function modifier_pl_phantom_rush_agi:OnCreated(table)
    EmitSoundOn("Hero_PhantomLancer.PhantomEdge", self:GetParent())
    self.bonus_agility = self:GetTalentSpecialValueFor("bonus_agility")
end

function modifier_pl_phantom_rush_agi:OnRefresh(table)
    EmitSoundOn("Hero_PhantomLancer.PhantomEdge", self:GetParent())
    self.bonus_agility = self:GetTalentSpecialValueFor("bonus_agility")
end

function modifier_pl_phantom_rush_agi:DeclareFunctions()
    return {MODIFIER_PROPERTY_STATS_AGILITY_BONUS}
end

function modifier_pl_phantom_rush_agi:GetModifierBonusStats_Agility()
    return self.bonus_agility
end

function modifier_pl_phantom_rush_agi:IsDebuff()
    return false
end

function modifier_pl_phantom_rush_agi:IsPurgable()
    return true
end

function modifier_pl_phantom_rush_agi:AllowIllusionDuplicate()
    return true
end