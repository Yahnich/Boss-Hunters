morph_wave = class({})
LinkLuaModifier( "modifier_morph_wave", "heroes/hero_morphling/morph_wave.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_morph_wave_charges", "heroes/hero_morphling/morph_wave", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_morph_wave_charges_handle", "heroes/hero_morphling/morph_wave", LUA_MODIFIER_MOTION_NONE)

function morph_wave:IsStealable()
    return true
end

function morph_wave:IsHiddenWhenStolen()
    return false
end

function morph_wave:GetIntrinsicModifierName()
	return "modifier_morph_wave_charges_handle"
end

function morph_wave:HasCharges()
	return true
end

function morph_wave:GetManaCost(iLevel)
	if self:GetCaster():IsIllusion() then
		return 0
	end
end

function morph_wave:GetCastRange(vLocation, hTarget)
	return self:GetTalentSpecialValueFor("range")
end

function morph_wave:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()

	local casterPos = caster:GetAbsOrigin()

	local dir = CalculateDirection(point, casterPos)
	local distance = CalculateDistance(point, casterPos)
	local speed = self:GetTalentSpecialValueFor("speed")
	local radius = self:GetTalentSpecialValueFor("radius")
	local damage = self:GetTalentSpecialValueFor("damage")

	local velocity = dir * speed

	EmitSoundOn("Hero_Morphling.Waveform", caster)

    caster:AddNewModifier(caster, self, "modifier_morph_wave", {duration = (distance / speed) + 0.1})

    ProjectileManager:ProjectileDodge(caster)

    self:FireLinearProjectile("particles/units/heroes/hero_morphling/morphling_waveform.vpcf", velocity, distance, radius, {}, false, false, false)
end

function morph_wave:OnProjectileHit(hTarget, vLocation)
	local caster = self:GetCaster()

	if hTarget and not hTarget:TriggerSpellAbsorb(self) then
		local damage = self:GetTalentSpecialValueFor("damage")

		self:DealDamage(caster, hTarget, damage, {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)

		if hTarget:IsAlive() and caster:HasTalent("special_bonus_unique_morph_wave_1") then
			caster:PerformGenericAttack(hTarget, true, 0, false, false)
		end
	end
end

modifier_morph_wave = class({})
function modifier_morph_wave:OnCreated(table)
	if IsServer() then
		local point = self:GetAbility():GetCursorPosition()
		local casterPos = self:GetParent():GetAbsOrigin()

		self.dir = CalculateDirection(point, casterPos)
		self.distance = CalculateDistance(point, casterPos)
		self.speed = self:GetTalentSpecialValueFor("speed") * FrameTime()

		self.velocity = self.dir * self.speed

		self:GetParent():AddNoDraw()

		self:StartMotionController()
	end
end

function modifier_morph_wave:OnRefresh(table)
	if IsServer() then
		local point = self:GetAbility():GetCursorPosition()
		local casterPos = self:GetParent():GetAbsOrigin()

		self.dir = CalculateDirection(point, casterPos)
		self.distance = CalculateDistance(point, casterPos)
		self.speed = self:GetTalentSpecialValueFor("speed") * FrameTime()

		self.velocity = self.dir * self.speed
	end
end

function modifier_morph_wave:CheckState()
	local state = {	[MODIFIER_STATE_ROOTED] = true,
					[MODIFIER_STATE_INVULNERABLE] = true,
					[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true}
	return state
end

function modifier_morph_wave:DoControlledMotion()
	local parent = self:GetParent()
	local ability = self:GetAbility()

	if self.distance > 0 then
		GridNav:DestroyTreesAroundPoint(parent:GetAbsOrigin(), self:GetTalentSpecialValueFor("radius"), false)
		parent:SetAbsOrigin(GetGroundPosition(parent:GetAbsOrigin(), parent) + self.velocity)

		self.distance = self.distance - self.speed
	else
		FindClearSpaceForUnit(parent, parent:GetAbsOrigin(), true)
		
		self:StopMotionController(true)
	end
end

function modifier_morph_wave:OnRemoved()
	if IsServer() then
		self:GetParent():RemoveNoDraw()
		self:GetParent():StartGesture(ACT_DOTA_CHANNEL_END_ABILITY_1)
	end
end

function modifier_morph_wave:IsHidden()
	return true
end

modifier_morph_wave_charges_handle = class({})

function modifier_morph_wave_charges_handle:OnCreated()
    if IsServer() then
        self:StartIntervalThink(0.1)
    end
end

function modifier_morph_wave_charges_handle:OnIntervalThink()
    local caster = self:GetCaster()

    if self:GetCaster():HasTalent("special_bonus_unique_morph_wave_2") then
        if not caster:HasModifier("modifier_morph_wave_charges") then
            self:GetAbility():EndCooldown()
            caster:AddNewModifier(caster, self:GetAbility(), "modifier_morph_wave_charges", {})
        end
    else
    	caster:RemoveModifierByName("modifier_morph_wave_charges")
    end
end

function modifier_morph_wave_charges_handle:DestroyOnExpire()
    return false
end

function modifier_morph_wave_charges_handle:IsPurgable()
    return false
end

function modifier_morph_wave_charges_handle:RemoveOnDeath()
    return false
end

function modifier_morph_wave_charges_handle:IsHidden()
    return true
end


modifier_morph_wave_charges = class({})
if IsServer() then
    function modifier_morph_wave_charges:Update()
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

    function modifier_morph_wave_charges:OnCreated()
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
	
	function modifier_morph_wave_charges:OnRefresh()
		self.kv.max_count = self:GetTalentSpecialValueFor("charges")
		self.kv.replenish_time = self:GetAbility():GetTrueCooldown()
        if self:GetStackCount() ~= kv.max_count then
            self:Update()
        end
    end
	
    function modifier_morph_wave_charges:DeclareFunctions()
        local funcs = {
            MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
        }

        return funcs
    end

    function modifier_morph_wave_charges:OnAbilityFullyCast(params)
        if params.unit == self:GetParent() then
			self.kv.replenish_time = self:GetAbility():GetTrueCooldown()
			self.kv.max_count = self:GetTalentSpecialValueFor("charges")
			
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

    function modifier_morph_wave_charges:OnIntervalThink()
        local stacks = self:GetStackCount()
		local caster = self:GetCaster()
		
		self.kv.replenish_time = self:GetAbility():GetTrueCooldown()
		self.kv.max_count = self:GetTalentSpecialValueFor("charges")
		
        if stacks < self.kv.max_count then
            self:IncrementStackCount()
			self:Update()
        end
    end
end

function modifier_morph_wave_charges:DestroyOnExpire()
    return false
end

function modifier_morph_wave_charges:IsPurgable()
    return false
end

function modifier_morph_wave_charges:RemoveOnDeath()
    return false
end

function modifier_morph_wave_charges:IsHidden()
	if self:GetCaster():HasTalent("special_bonus_unique_morph_wave_2") then
    	return false
    else
    	return true
    end
end