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
    local value = caster:FindTalentValue("special_bonus_unique_ember_fist_1")
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
	return self:GetTalentSpecialValueFor("radius")
end

function ember_fist:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
	caster:StartGesture(ACT_DOTA_CAST_ABILITY_2)

	EmitSoundOn("Hero_EmberSpirit.SleightOfFist.Cast", caster)

	local startPos = caster:GetAbsOrigin()

	local radius = self:GetTalentSpecialValueFor("radius")
	local baseDamage = self:GetTalentSpecialValueFor("damage")
	local jumpRate = self:GetTalentSpecialValueFor("jump_rate")

	self.hitUnits = {}

	local current = 0

	local castFx = 	ParticleManager:CreateParticle("particles/units/heroes/hero_ember_spirit/ember_spirit_sleight_of_fist_cast.vpcf", PATTACH_POINT, caster)
					ParticleManager:SetParticleControl(castFx, 0, point)
					ParticleManager:SetParticleControl(castFx, 1, Vector(radius, radius, radius))
					ParticleManager:ReleaseParticleIndex(castFx)

	---Remnant Only lasts 10 seconds.-----
	local enemies = caster:FindEnemyUnitsInRadius(point, radius, {flag = self:GetAbilityTargetFlags()})
	if #enemies > 0 then
		local duration = self:GetTalentSpecialValueFor("duration")
		caster:FindAbilityByName("ember_remnant"):SpawnRemnant(startPos, duration)
		local remenantFx = 	ParticleManager:CreateParticle("particles/units/heroes/hero_ember_spirit/ember_spirit_sleight_of_fist_caster.vpcf", PATTACH_POINT, caster)
				 			ParticleManager:SetParticleControl(remenantFx, 0, startPos)
				 			ParticleManager:SetParticleControlForward(remenantFx, 1, caster:GetForwardVector())

		caster:AddNewModifier(caster, self, "modifier_ember_fist", {Duration = #enemies})
		Timers:CreateTimer(jumpRate, function()
			if current < #enemies then
				for _,enemy in pairs(enemies) do
					if not self.hitUnits[enemy:entindex()] and not enemy:TriggerSpellAbsorb(self) then
						EmitSoundOn("Hero_EmberSpirit.SleightOfFist.Damage", enemy)

						local firstPoint = caster:GetAbsOrigin()
						local secondPoint = enemy:GetAbsOrigin() + caster:GetForwardVector() * 50

						----Damage Buff for Talent 2-------
						if caster:HasTalent("special_bonus_unique_ember_fist_2") then
							caster:AddNewModifier(caster, self, "modifier_ember_fist_damage_buff", {Duration = 5}):IncrementStackCount()
						end

						ParticleManager:FireRopeParticle("particles/units/heroes/hero_ember_spirit/ember_spirit_sleightoffist_trail.vpcf", PATTACH_POINT, caster, secondPoint, {[0]=firstPoint, [1]=secondPoint})

						FindClearSpaceForUnit(caster, secondPoint, true)
						caster:FaceTowards(enemy:GetAbsOrigin())
						caster:PerformAttack(enemy, true, true, true, true, true, false, false)
						if enemy:IsAlive() then
							self:DealDamage(caster, enemy, baseDamage, {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
						end
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
	local state = { [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
					[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
					[MODIFIER_STATE_INVULNERABLE] = true}
	return state
end

function modifier_ember_fist:GetEffectName()
	return "particles/units/heroes/hero_ember_spirit/ember_spirit_searing_chains_debuff.vpcf"
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
		self.kv.max_count = self:GetTalentSpecialValueFor("charges")

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
			max_count = self:GetTalentSpecialValueFor("charges"),
			replenish_time = self:GetAbility():GetTrueCooldown()
		}
        self:SetStackCount(kv.start_count or kv.max_count)
        self.kv = kv

        if kv.start_count and kv.start_count ~= kv.max_count then
            self:Update()
        end
    end
	
	function modifier_ember_fist_charges:OnRefresh()
		self.kv.max_count = self:GetTalentSpecialValueFor("charges")
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
			self.kv.max_count = self:GetTalentSpecialValueFor("charges")
			
            local ability = params.ability
            if params.ability == self:GetAbility() then
                self:DecrementStackCount()
				ability:EndCooldown()
                self:Update()
			elseif params.ability:GetName() == "item_refresher" and self:GetStackCount() < self.kv.max_count then
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
		self.kv.max_count = self:GetTalentSpecialValueFor("charges")
		
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
	if self:GetCaster():HasTalent("special_bonus_unique_ember_fist_1") then
    	return false
    else
    	return true
    end
end

modifier_ember_fist_damage_buff = class({})

function modifier_ember_fist_damage_buff:OnCreated(table)
	self.damage = 15 * self:GetStackCount()
end

function modifier_ember_fist_damage_buff:OnRefresh(table)
	self.damage = 15 * self:GetStackCount()
end

function modifier_ember_fist_damage_buff:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE
    }
    return funcs
end

function modifier_ember_fist_damage_buff:GetModifierPreAttack_BonusDamage()
	return self.damage
end

function modifier_ember_fist_damage_buff:IsDebuff()
	return false
end