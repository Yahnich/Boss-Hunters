mirana_celestial_jump = class({})
LinkLuaModifier("modifier_mirana_celestial_jump_movement", "heroes/hero_mirana/mirana_celestial_jump", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mirana_celestial_jump_agi", "heroes/hero_mirana/mirana_celestial_jump", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mirana_celestial_jump_charges", "heroes/hero_mirana/mirana_celestial_jump", LUA_MODIFIER_MOTION_NONE)

function mirana_celestial_jump:IsStealable()
	return true
end

function mirana_celestial_jump:IsHiddenWhenStolen()
	return false
end

function mirana_celestial_jump:GetIntrinsicModifierName()
	return "modifier_mirana_celestial_jump_charges"
end

function mirana_celestial_jump:HasCharges()
	return true
end

function mirana_celestial_jump:GetCastRange(target, position)
	return self:GetTalentSpecialValueFor("jump_distance")
end

function mirana_celestial_jump:OnSpellStart()
	local caster = self:GetCaster()

	EmitSoundOn("Ability.Leap", caster)

	caster:AddNewModifier(caster, self, "modifier_mirana_celestial_jump_movement", {duration = self:GetTalentSpecialValueFor("jump_duration") + 0.01})
end

modifier_mirana_celestial_jump_movement = class({})
if IsServer() then
	function modifier_mirana_celestial_jump_movement:OnCreated()
		local parent = self:GetParent()
		self.endPos = self:GetAbility():GetCursorPosition()
		self.distance = CalculateDistance( self.endPos, parent )
		self.direction = CalculateDirection( self.endPos, parent )
		self.speed = self.distance / self:GetTalentSpecialValueFor("jump_duration") * FrameTime()
		self.initHeight = GetGroundHeight(parent:GetAbsOrigin(), parent)
		self.height = self.initHeight
		self.maxHeight = self:GetTalentSpecialValueFor("max_height")
		self:StartMotionController()
	end
	
	function modifier_mirana_celestial_jump_movement:OnDestroy()
		local parent = self:GetParent()
		local parentPos = parent:GetAbsOrigin()
		FindClearSpaceForUnit(parent, parentPos, true)
		local ability = self:GetAbility()
		local radius = self:GetTalentSpecialValueFor("radius")
		self:StopMotionController()

		parent:AddNewModifier(parent, ability, "modifier_mirana_celestial_jump_agi", {Duration = self:GetSpecialValueFor("duration")})

		local enemies = parent:FindEnemyUnitsInRadius(parentPos, self:GetSpecialValueFor("radius"))
		for _,enemy in pairs(enemies) do
			enemy:ApplyKnockBack(parentPos, 0.5, 0.5, self:GetSpecialValueFor("radius"), 0)
		end
	end
	
	function modifier_mirana_celestial_jump_movement:DoControlledMotion()
		if self:GetParent():IsNull() then return end
		local parent = self:GetParent()
		self.distanceTraveled =  self.distanceTraveled or 0
		if parent:IsAlive() and self.distanceTraveled < self.distance then
			local newPos = GetGroundPosition(parent:GetAbsOrigin(), parent) + self.direction * self.speed
			newPos.z = self.height + self.maxHeight * math.sin( (self.distanceTraveled/self.distance) * math.pi )
			parent:SetAbsOrigin( newPos )
			
			self.distanceTraveled = self.distanceTraveled + self.speed
		else
			FindClearSpaceForUnit(parent, parent:GetAbsOrigin(), true)
			self:Destroy()
			return nil
		end       
	end
end

function modifier_mirana_celestial_jump_movement:CheckState()
	return {[MODIFIER_STATE_ROOTED] = true,
			[MODIFIER_STATE_NO_UNIT_COLLISION] = true}
end

function modifier_mirana_celestial_jump_movement:DeclareFunctions()
	return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION}
end

function modifier_mirana_celestial_jump_movement:GetOverrideAnimation()
	return ACT_DOTA_FLAIL
end

function modifier_mirana_celestial_jump_movement:IsHidden()
	return true
end

modifier_mirana_celestial_jump_agi = class({})
function modifier_mirana_celestial_jump_agi:OnCreated(table)
	self.agi = self:GetTalentSpecialValueFor("bonus_agi")

	if self:GetCaster():HasTalent("special_bonus_unique_mirana_celestial_jump_1") then
		self.agi = self:GetTalentSpecialValueFor("bonus_agi") + self:GetTalentSpecialValueFor("bonus_agi")*self:GetCaster():FindTalentValue("special_bonus_unique_mirana_celestial_jump_1")/100
	end
end

function modifier_mirana_celestial_jump_agi:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_AGILITY_BONUS}
end

function modifier_mirana_celestial_jump_agi:GetModifierBonusStats_Agility()
	return self.agi
end

modifier_mirana_celestial_jump_charges = class({})

if IsServer() then
    function modifier_mirana_celestial_jump_charges:Update()
		self.kv.replenish_time = self:GetAbility():GetTrueCooldown()
		self.kv.max_count = self:GetTalentSpecialValueFor("charges")

		if self:GetStackCount() == self.kv.max_count then
			self:SetDuration(-1, true)
		elseif self:GetStackCount() > self.kv.max_count then
			self:SetDuration(-1, true)
			self:SetStackCount(self.kv.max_count)
		elseif self:GetStackCount() < self.kv.max_count then
			local duration = self.kv.replenish_time* get_octarine_multiplier( self:GetCaster() )
            self:SetDuration(duration, true)
            self:StartIntervalThink(duration)
		end

        if self:GetStackCount() == 0 then
            self:GetAbility():StartCooldown(self:GetRemainingTime())
        end
    end

    function modifier_mirana_celestial_jump_charges:OnCreated()
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
	
	function modifier_mirana_celestial_jump_charges:OnRefresh()
		self.kv.max_count = self:GetTalentSpecialValueFor("charges")
		self.kv.replenish_time = self:GetAbility():GetTrueCooldown()
        if self:GetStackCount() ~= kv.max_count then
            self:Update()
        end
    end
	
    function modifier_mirana_celestial_jump_charges:DeclareFunctions()
        local funcs = {
            MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
        }

        return funcs
    end

    function modifier_mirana_celestial_jump_charges:OnAbilityFullyCast(params)
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

    function modifier_mirana_celestial_jump_charges:OnIntervalThink()
        local stacks = self:GetStackCount()
		local caster = self:GetCaster()
		local octarine = get_octarine_multiplier(caster)
		
		self.kv.replenish_time = self:GetAbility():GetTrueCooldown()
		self.kv.max_count = self:GetTalentSpecialValueFor("charges")
		
        if stacks < self.kv.max_count then
            self:IncrementStackCount()
			self:Update()
        end
    end
end

function modifier_mirana_celestial_jump_charges:DestroyOnExpire()
    return false
end

function modifier_mirana_celestial_jump_charges:IsPurgable()
    return false
end

function modifier_mirana_celestial_jump_charges:RemoveOnDeath()
    return false
end

function modifier_mirana_celestial_jump_charges:IsHidden()
	if self:GetCaster():HasTalent("special_bonus_unique_mirana_celestial_jump_2") then
    	return false
    else
    	return true
    end
end