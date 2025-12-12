ember_fist = class({})
LinkLuaModifier("modifier_ember_fist", "heroes/hero_ember_spirit/ember_fist", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ember_fist_charges", "heroes/hero_ember_spirit/ember_fist", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ember_fist_charges_handle", "heroes/hero_ember_spirit/ember_fist", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ember_fist_damage_buff", "heroes/hero_ember_spirit/ember_fist", LUA_MODIFIER_MOTION_NONE)

function ember_fist:IsStealable()
	return true
end

function ember_fist:IsHiddenWhenStolen()
	return false
end

function ember_fist:GetCooldown(iLvl)
    local cooldown = self.BaseClass.GetCooldown(self, iLvl)
    local caster = self:GetCaster()
    local talent = "special_bonus_unique_ember_fist_1"
    local value = caster:FindTalentValue(talent, "cd")
    if caster:HasTalent( talent ) then cooldown = cooldown + value end
    return cooldown
end

function ember_fist:GetIntrinsicModifierName()
	return "modifier_ember_fist_charges_handle"
end

function ember_fist:HasCharges()
	return true
end

function ember_fist:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end

function ember_fist:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
	caster:StartGesture(ACT_DOTA_CAST_ABILITY_2)

	EmitSoundOn("Hero_EmberSpirit.SleightOfFist.Cast", caster)

	local startPos = caster:GetAbsOrigin()

	local radius = self:GetSpecialValueFor("radius")
	local baseDamage = self:GetSpecialValueFor("damage")
	local jumpRate = self:GetSpecialValueFor("jump_rate")

	self.hitUnits = {}

	local current = 0

	local castFx = 	ParticleManager:CreateParticle("particles/units/heroes/hero_ember_spirit/ember_spirit_sleight_of_fist_cast.vpcf", PATTACH_POINT, caster)
					ParticleManager:SetParticleControl(castFx, 0, point)
					ParticleManager:SetParticleControl(castFx, 1, Vector(radius, radius, radius))
					ParticleManager:ReleaseParticleIndex(castFx)
	local hasTalent2 = caster:HasTalent("special_bonus_unique_ember_fist_2")
	local talent2Duration = caster:FindTalentValue("special_bonus_unique_ember_fist_2", "duration")
	---Remnant Only lasts 10 seconds.-----
	local enemies = caster:FindEnemyUnitsInRadius(point, radius, {flag = self:GetAbilityTargetFlags()})
	if #enemies > 0 then
		local duration = self:GetSpecialValueFor("duration")
		local remnant = caster:FindAbilityByName("ember_remnant")
		if remnant then
			remnant:SpawnRemnant(startPos, duration)
		end
		local remenantFx = 	ParticleManager:CreateParticle("particles/units/heroes/hero_ember_spirit/ember_spirit_sleight_of_fist_caster.vpcf", PATTACH_POINT, caster)
				 			ParticleManager:SetParticleControl(remenantFx, 0, startPos)
				 			ParticleManager:SetParticleControlForward(remenantFx, 1, caster:GetForwardVector())

		caster:AddNewModifier(caster, self, "modifier_ember_fist", {Duration = math.max(#enemies*jumpRate+0.1,jumpRate)})
		Timers:CreateTimer(function()
			if current < #enemies then
				for _,enemy in pairs(enemies) do
					if not self.hitUnits[enemy:entindex()] and not enemy:TriggerSpellAbsorb(self) then
						EmitSoundOn("Hero_EmberSpirit.SleightOfFist.Damage", enemy)

						local firstPoint = caster:GetAbsOrigin()
						local secondPoint = enemy:GetAbsOrigin() + caster:GetForwardVector() * 50

						----Damage Buff for Talent 2-------
						if hasTalent2 then
							caster:AddNewModifier(caster, self, "modifier_ember_fist_damage_buff", {Duration = talent2Duration}):IncrementStackCount()
						end

						ParticleManager:FireRopeParticle("particles/units/heroes/hero_ember_spirit/ember_spirit_sleightoffist_trail.vpcf", PATTACH_POINT, caster, secondPoint, {[0]=firstPoint, [1]=secondPoint})

						FindClearSpaceForUnit(caster, secondPoint, true)
						caster:FaceTowards(enemy:GetAbsOrigin())
						caster:PerformGenericAttack(enemy, true, baseDamage, false, true)
			            self.hitUnits[enemy:entindex()] = true
			            current = current + 1
			            return jumpRate
			        end
				end
			else
				local firstPoint = caster:GetAbsOrigin()

				ParticleManager:ClearParticle(remenantFx)

				caster:RemoveModifierByName("modifier_ember_fist")
				FindClearSpaceForUnit(caster, startPos, true)

				local secondPoint = caster:GetAbsOrigin()

				ParticleManager:FireRopeParticle("particles/units/heroes/hero_ember_spirit/ember_spirit_sleightoffist_trail.vpcf", PATTACH_POINT, caster, secondPoint, {[0]=firstPoint, [1]=secondPoint})
				return nil
			end
		end)
	else
		self:GetCaster():RemoveGesture(ACT_DOTA_CAST_ABILITY_2)
	end
	
end

modifier_ember_fist = class({})

function modifier_ember_fist:OnRemoved()
	if IsServer() then
		self:GetCaster():RemoveGesture(ACT_DOTA_CAST_ABILITY_2)
	end
end

function modifier_ember_fist:CheckState()
	local state = { [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
					[MODIFIER_STATE_DISARMED] = true,
					[MODIFIER_STATE_INVULNERABLE] = true,
					[MODIFIER_STATE_IGNORING_MOVE_AND_ATTACK_ORDERS ] = true}
	return state
end

function modifier_ember_fist:GetStatusEffectName()
	return "particles/status_fx/status_effect_snapfire_magma.vpcf"
end

function modifier_ember_fist:StatusEffectPriority()
	return 20
end

function modifier_ember_fist:IsHidden()
	return true
end

modifier_ember_fist_charges_handle = class({})

function modifier_ember_fist_charges_handle:OnCreated()
    if IsServer() then
        self:StartIntervalThink(0.1)
    end
end

function modifier_ember_fist_charges_handle:OnIntervalThink()
    local caster = self:GetCaster()

    if self:GetCaster():HasTalent("special_bonus_unique_ember_fist_1") then
        if not caster:HasModifier("modifier_ember_fist_charges") then
            self:GetAbility():EndCooldown()
            caster:AddNewModifier(caster, self:GetAbility(), "modifier_ember_fist_charges", {})
        end
    else
    	if caster:HasModifier("modifier_ember_fist_charges") then
    		caster:RemoveModifierByName("modifier_ember_fist_charges")
    	end
    end
end

function modifier_ember_fist_charges_handle:DestroyOnExpire()
    return false
end

function modifier_ember_fist_charges_handle:IsPurgable()
    return false
end

function modifier_ember_fist_charges_handle:RemoveOnDeath()
    return false
end

function modifier_ember_fist_charges_handle:IsHidden()
    return true
end


modifier_ember_fist_charges = class({})
if IsServer() then
    function modifier_ember_fist_charges:Update()
		self.kv.replenish_time = self:GetAbility():GetTrueCooldown()
		self.kv.max_count = self:GetSpecialValueFor("charges")

		if self:GetStackCount() == self.kv.max_count then
			self:SetDuration(-1, true)
		elseif self:GetStackCount() > self.kv.max_count then
			self:SetDuration(-1, true)
			self:SetStackCount(self.kv.max_count)
		elseif self:GetStackCount() < self.kv.max_count then
			local duration = self.kv.replenish_time* self:GetCaster():GetCooldownReduction()
            self:SetDuration(duration, true)
            self:StartIntervalThink(duration)
		end

        if self:GetStackCount() == 0 then
            self:GetAbility():StartCooldown(self:GetRemainingTime())
        end
    end

    function modifier_ember_fist_charges:OnCreated()
		kv = {
			max_count = self:GetSpecialValueFor("charges"),
			replenish_time = self:GetAbility():GetTrueCooldown()
		}
        self:SetStackCount(kv.start_count or kv.max_count)
        self.kv = kv

        if kv.start_count and kv.start_count ~= kv.max_count then
            self:Update()
        end
    end
	
	function modifier_ember_fist_charges:OnRefresh()
		self.kv.max_count = self:GetSpecialValueFor("charges")
		self.kv.replenish_time = self:GetAbility():GetTrueCooldown()
        if self:GetStackCount() ~= kv.max_count then
            self:Update()
        end
    end
	
    function modifier_ember_fist_charges:DeclareFunctions()
        local funcs = {
            MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
        }

        return funcs
    end

    function modifier_ember_fist_charges:OnAbilityFullyCast(params)
        if params.unit == self:GetParent() then
			self.kv.replenish_time = self:GetAbility():GetTrueCooldown()
			self.kv.max_count = self:GetSpecialValueFor("charges")
			
            local ability = params.ability
            if params.ability == self:GetAbility() then
                self:DecrementStackCount()
				ability:EndCooldown()
                self:Update()
			elseif string.find( params.ability:GetName(), "orb_of_renewal" ) and self:GetStackCount() < self.kv.max_count then
                self:IncrementStackCount()
                self:Update()
            end
        end

        return 0
    end

    function modifier_ember_fist_charges:OnIntervalThink()
        local stacks = self:GetStackCount()
		local caster = self:GetCaster()
		local octarine = caster:GetCooldownReduction()
		
		self.kv.replenish_time = self:GetAbility():GetTrueCooldown()
		self.kv.max_count = self:GetSpecialValueFor("charges")
		
        if stacks < self.kv.max_count then
            self:IncrementStackCount()
			self:Update()
        end
    end
end

function modifier_ember_fist_charges:DestroyOnExpire()
    return false
end

function modifier_ember_fist_charges:IsPurgable()
    return false
end

function modifier_ember_fist_charges:RemoveOnDeath()
    return false
end

function modifier_ember_fist_charges:IsHidden()
	return false
end

modifier_ember_fist_damage_buff = class({})

function modifier_ember_fist_damage_buff:OnCreated(table)
	self.damage = self:GetCaster():FindTalentValue("special_bonus_unique_ember_fist_2")
	print( self.damage )
end

function modifier_ember_fist_damage_buff:OnRefresh(table)
	self.damage = self:GetCaster():FindTalentValue("special_bonus_unique_ember_fist_2")
end

function modifier_ember_fist_damage_buff:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE
    }
    return funcs
end

function modifier_ember_fist_damage_buff:GetModifierPreAttack_BonusDamage()
	return self.damage * self:GetStackCount()
end

function modifier_ember_fist_damage_buff:IsDebuff()
	return false
end