ember_remnant = class({})
LinkLuaModifier("modifier_ember_remnant", "heroes/hero_ember_spirit/ember_remnant", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ember_remnant_charges", "heroes/hero_ember_spirit/ember_remnant", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ember_remnant_charges_handle", "heroes/hero_ember_spirit/ember_remnant", LUA_MODIFIER_MOTION_NONE)

function ember_remnant:IsStealable()
	return false
end

function ember_remnant:IsHiddenWhenStolen()
	return false
end

function ember_remnant:GetIntrinsicModifierName()
	return "modifier_ember_remnant_charges"
end

function ember_remnant:HasCharges()
	return true
end

function ember_remnant:GetCooldown(iLvl)
    local cooldown = self.BaseClass.GetCooldown(self, iLvl)
    local caster = self:GetCaster()
    local talent = "special_bonus_unique_ember_remnant_1"
    local value = caster:FindTalentValue("special_bonus_unique_ember_remnant_1", "cooldown")
    if caster:HasTalent( talent ) then cooldown = cooldown + value end
    return cooldown
end

function ember_remnant:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
	caster:StartGesture(ACT_DOTA_CAST_ABILITY_4)

	EmitSoundOn("Hero_EmberSpirit.FireRemnant.Cast", caster)

	---Because 100% + 250% = 350%
	local speed = caster:GetIdealSpeedNoSlows() * 3.5

	local direction = CalculateDirection(point, caster:GetAbsOrigin())
	local distance = CalculateDistance(point, caster:GetAbsOrigin())
	local vel = direction * speed

	local vision = 0

	if GameRules:IsDaytime() then
		vision = caster:GetDayTimeVisionRange()
	else
		vision = caster:GetNightTimeVisionRange()
	end

	self:FireLinearProjectile("particles/units/heroes/hero_ember_spirit/ember_spirit_fire_remnant_trail.vpcf", vel, distance, caster:BoundingRadius2D()*3, {}, false, true, vision/2)
end

function ember_remnant:OnProjectileThink(vLocation)
	local caster = self:GetCaster()

	local point = GetGroundPosition(vLocation, caster)
	GridNav:DestroyTreesAroundPoint(point, caster:BoundingRadius2D()*3, true)
end

function ember_remnant:OnProjectileHit(hTarget, vLocation)
	local caster = self:GetCaster()

	if hTarget then
		caster:PerformAttack(hTarget, true, true, true, true, false, false, true)
	else
		local point = GetGroundPosition(vLocation, caster)
		GridNav:DestroyTreesAroundPoint(point, caster:BoundingRadius2D()*3, true)
		local duration = self:GetTalentSpecialValueFor("duration")
		self:SpawnRemnant(point, duration)
	end
end

function ember_remnant:SpawnRemnant(targetLocation, duration)
	local caster = self:GetCaster()

	local remnant = caster:CreateSummon("npc_dota_ember_spirit_remnant", targetLocation, duration)
	EmitSoundOn("Hero_EmberSpirit.FireRemnant.Create", remnant)
	remnant:AddNewModifier(caster, self, "modifier_ember_remnant", {})
end

modifier_ember_remnant = class({})

function modifier_ember_remnant:OnCreated(table)
	if IsServer() then
		local caster = self:GetCaster()
		local parent = self:GetParent()

		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_ember_spirit/ember_spirit_fire_remnant.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
					ParticleManager:SetParticleControlEnt(nfx, 0, parent, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
					ParticleManager:SetParticleControlEnt(nfx, 1, caster, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
					local randAnimation = math.random(39, 44)
					ParticleManager:SetParticleControl(nfx, 2, Vector(randAnimation, 0, 0))

		self:AttachEffect(nfx)
	end
end

function modifier_ember_remnant:CheckState()
	local state = { [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
					[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
					[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
					[MODIFIER_STATE_UNSELECTABLE] = true,
					[MODIFIER_STATE_UNTARGETABLE] = true,
					[MODIFIER_STATE_NO_HEALTH_BAR] = true,
					[MODIFIER_STATE_INVULNERABLE] = true}
	return state
end

modifier_ember_remnant_charges = class({})
if IsServer() then
    function modifier_ember_remnant_charges:Update()
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

    function modifier_ember_remnant_charges:OnCreated()
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
	
	function modifier_ember_remnant_charges:OnRefresh()
		self.kv.max_count = self:GetTalentSpecialValueFor("charges")
		self.kv.replenish_time = self:GetAbility():GetTrueCooldown()
        if self:GetStackCount() ~= kv.max_count then
            self:Update()
        end
    end
	
    function modifier_ember_remnant_charges:DeclareFunctions()
        local funcs = {
            MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
        }

        return funcs
    end

    function modifier_ember_remnant_charges:OnAbilityFullyCast(params)
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

    function modifier_ember_remnant_charges:OnIntervalThink()
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

function modifier_ember_remnant_charges:DestroyOnExpire()
    return false
end

function modifier_ember_remnant_charges:IsPurgable()
    return false
end

function modifier_ember_remnant_charges:RemoveOnDeath()
    return false
end