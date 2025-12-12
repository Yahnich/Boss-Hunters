mirana_celestial_jump = class({})

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

function mirana_celestial_jump:GetCooldown( iLvl )
	return self.BaseClass.GetCooldown( self, iLvl ) + self:GetCaster():FindTalentValue("special_bonus_unique_mirana_celestial_jump_1")
end

function mirana_celestial_jump:GetCastRange(target, position)
	return self:GetSpecialValueFor("jump_distance")
end

function mirana_celestial_jump:OnSpellStart()
	local caster = self:GetCaster()

	EmitSoundOn("Ability.Leap", caster)

	caster:AddNewModifier(caster, self, "modifier_mirana_celestial_jump_movement", {})
end

modifier_mirana_celestial_jump_movement = class({})
LinkLuaModifier("modifier_mirana_celestial_jump_movement", "heroes/hero_mirana/mirana_celestial_jump", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
	function modifier_mirana_celestial_jump_movement:OnCreated()
		local parent = self:GetParent()
		self.distance = self:GetSpecialValueFor("jump_distance")
		self.direction = parent:GetForwardVector()
		self.speed = self.distance / self:GetSpecialValueFor("jump_duration") * FrameTime()
		self.initHeight = GetGroundHeight(parent:GetAbsOrigin(), parent)
		self.height = self.initHeight
		self.maxHeight = self:GetSpecialValueFor("max_height")
		self:StartMotionController()
	end
	
	function modifier_mirana_celestial_jump_movement:OnDestroy()
		local parent = self:GetParent()
		local parentPos = parent:GetAbsOrigin()
		FindClearSpaceForUnit(parent, parentPos, true)
		local ability = self:GetAbility()
		local radius = self:GetSpecialValueFor("radius")
		local duration = self:GetSpecialValueFor("duration")
		self:StopMotionController()

		parent:AddNewModifier(parent, ability, "modifier_mirana_celestial_jump_buff", {Duration = duration})

		local enemies = parent:FindEnemyUnitsInRadius(parentPos, radius)
		for _,enemy in pairs(enemies) do
			enemy:ApplyKnockBack(parentPos, 0.5, 0.5, radius, 0)
		end
		if parent:HasTalent("special_bonus_unique_mirana_celestial_jump_1") then
			local allies = parent:FindFriendlyUnitsInRadius(parentPos, radius)
			for _, ally in pairs(allies) do
				if ally ~= parent then
					ally:AddNewModifier(parent, ability, "modifier_mirana_celestial_jump_buff", {Duration = duration})
				end
			end
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

modifier_mirana_celestial_jump_buff = class({})
LinkLuaModifier("modifier_mirana_celestial_jump_buff", "heroes/hero_mirana/mirana_celestial_jump", LUA_MODIFIER_MOTION_NONE)

function modifier_mirana_celestial_jump_buff:OnCreated(table)
	self:OnRefresh()
end


function modifier_mirana_celestial_jump_buff:OnRefresh(table)
	self.as = self:GetSpecialValueFor("bonus_attackspeed")
	self.ms = self:GetSpecialValueFor("bonus_movespeed")

	if self:GetCaster():HasTalent("special_bonus_unique_mirana_celestial_jump_2") then
		self.agi = self.ms * self:GetCaster():FindTalentValue("special_bonus_unique_mirana_celestial_jump_2") / 100
	end
	self:GetParent():HookInModifier("GetModifierAgilityBonusPercentage", self)
end

function modifier_mirana_celestial_jump_buff:OnDestroy(table)
	self:GetParent():HookOutModifier("GetModifierAgilityBonusPercentage", self)
end

function modifier_mirana_celestial_jump_buff:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE }
end

function modifier_mirana_celestial_jump_buff:GetModifierAttackSpeedBonus_Constant()
	return self.as
end

function modifier_mirana_celestial_jump_buff:GetModifierMoveSpeedBonus_Percentage()
	return self.ms
end

function modifier_mirana_celestial_jump_buff:GetModifierAgilityBonusPercentage()
	return self.agi
end

modifier_mirana_celestial_jump_charges = class({})
LinkLuaModifier("modifier_mirana_celestial_jump_charges", "heroes/hero_mirana/mirana_celestial_jump", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
    function modifier_mirana_celestial_jump_charges:Update()
		self.kv.replenish_time = self:GetAbility():GetTrueCooldown()
		self.kv.max_count = self:GetSpecialValueFor("charges")

		if self:GetStackCount() == self.kv.max_count then
			self:SetDuration(-1, true)
			self.timeWhenNextStackIsDone = nil
		elseif self:GetStackCount() > self.kv.max_count then
			self:SetDuration(-1, true)
			self:SetStackCount(self.kv.max_count)
			self.timeWhenNextStackIsDone = nil
		elseif self:GetStackCount() < self.kv.max_count then
			local duration = math.max( self.kv.replenish_time* self:GetCaster():GetCooldownReduction(), (self.timeWhenNextStackIsDone or GameRules:GetGameTime()) - GameRules:GetGameTime() )
            self:SetDuration(duration, true)
            self:StartIntervalThink(duration)
			self.timeWhenNextStackIsDone = GameRules:GetGameTime() + duration
		end

        if self:GetStackCount() == 0 then
            self:GetAbility():StartCooldown( self.timeWhenNextStackIsDone - GameRules:GetGameTime() )
        end
    end

    function modifier_mirana_celestial_jump_charges:OnCreated()
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
	
	function modifier_mirana_celestial_jump_charges:OnRefresh()
		self.kv.max_count = self:GetSpecialValueFor("charges")
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

    function modifier_mirana_celestial_jump_charges:OnIntervalThink()
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

function modifier_mirana_celestial_jump_charges:DestroyOnExpire()
    return false
end

function modifier_mirana_celestial_jump_charges:IsPurgable()
    return false
end

function modifier_mirana_celestial_jump_charges:RemoveOnDeath()
    return false
end