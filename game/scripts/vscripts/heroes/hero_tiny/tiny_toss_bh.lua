tiny_toss_bh = class({})
LinkLuaModifier("modifier_tiny_toss_bh", "heroes/hero_tiny/tiny_toss_bh", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_tiny_toss_bh_rock", "heroes/hero_tiny/tiny_toss_bh", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_tiny_toss_bh_charge_handle", "heroes/hero_tiny/tiny_toss_bh", LUA_MODIFIER_MOTION_NONE)

function tiny_toss_bh:IsStealable()
    return true
end

function tiny_toss_bh:IsHiddenWhenStolen()
    return false
end

function tiny_toss_bh:PiercesDisableResistance()
	return true
end

function tiny_toss_bh:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end

function tiny_toss_bh:GetIntrinsicModifierName()
	return "modifier_tiny_toss_bh_charge_handle"
end

function tiny_toss_bh:OnSpellStart()
    local caster = self:GetCaster()
    local target = nil
    local duration = CalculateDistance(self:GetCursorPosition(), caster:GetAbsOrigin()) / self:GetTalentSpecialValueFor("duration") * FrameTime()

    EmitSoundOn("Ability.TossThrow", caster)

	local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), caster:GetAttackRange())
	for _,enemy in pairs(enemies) do
		if not enemy:HasModifier("modifier_tiny_toss_bh") then
			target = enemy
			EmitSoundOn("Hero_Tiny.Toss.Target", enemy)
	  		enemy:AddNewModifier(caster, self, "modifier_tiny_toss_bh", {Duration = duration})
	  		break
	  	end
	end 
	
	if target == nil then
		local direction = CalculateDirection(self:GetCursorPosition(), caster:GetAbsOrigin())
		if caster:HasTalent("special_bonus_unique_tiny_toss_bh_1") then
			caster:AddNewModifier(caster, self, "modifier_tiny_toss_bh_rock", {Duration = duration})
		else
			local dummy = caster:CreateDummy(caster:GetAbsOrigin(), duration)
			ParticleManager:FireParticle("particles/units/heroes/hero_nyx_assassin/nyx_assassin_impale_burrow_soil.vpcf", PATTACH_POINT, dummy, {})
			dummy:SetForwardVector(direction)
			dummy:AddNewModifier(caster, self, "modifier_tiny_toss_bh_rock", {Duration = duration})
		end
	end
end

modifier_tiny_toss_bh = class({})
function modifier_tiny_toss_bh:OnCreated()
	if IsServer() then
		local parent = self:GetParent()
		parent:Stop()
		self.endPos = self:GetAbility():GetCursorPosition()
		self.distance = CalculateDistance( self.endPos, parent )
		self.direction = CalculateDirection( self.endPos, parent )
		self.speed = self.distance / self:GetTalentSpecialValueFor("duration") * FrameTime()
		self.initHeight = GetGroundHeight(parent:GetAbsOrigin(), parent)
		self.height = self.initHeight
		self.maxHeight = 650
		self:StartMotionController()
	end
end


function modifier_tiny_toss_bh:OnRemoved()
	if IsServer() then
		EmitSoundOn("Ability.TossImpact", self:GetParent())
		local parent = self:GetParent()
		local parentPos = parent:GetAbsOrigin()
		local radius = self:GetTalentSpecialValueFor("radius")
		GridNav:DestroyTreesAroundPoint(parentPos, radius, false)
		FindClearSpaceForUnit(parent, parentPos, true)
		local ability = self:GetAbility()
		local damage = self:GetTalentSpecialValueFor("damage")
		local radius = self:GetTalentSpecialValueFor("radius")
		local enemies = self:GetCaster():FindEnemyUnitsInRadius(parentPos, radius)
		for _,enemy in pairs(enemies) do
			if self:GetCaster():HasScepter() then
				self:GetAbility():Stun(enemy, 1, false)
			end
			ability:DealDamage(self:GetCaster(), enemy, damage, {}, 0)
		end
		self:StopMotionController()
	end
end

function modifier_tiny_toss_bh:DoControlledMotion()
	if IsServer() then
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

function modifier_tiny_toss_bh:GetEffectName()
	return "particles/units/heroes/hero_tiny/tiny_toss_blur.vpcf"
end

function modifier_tiny_toss_bh:CheckState()
	return {[MODIFIER_STATE_STUNNED] = true,
			[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
			[MODIFIER_STATE_SILENCED] = true,}
end

function modifier_tiny_toss_bh:DeclareFunctions()
	return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION}
end

function modifier_tiny_toss_bh:GetOverrideAnimation()
	return ACT_DOTA_FLAIL
end

function modifier_tiny_toss_bh:IsHidden()
	return true
end

modifier_tiny_toss_bh_rock = class({})
function modifier_tiny_toss_bh_rock:OnCreated()
	if IsServer() then
		local parent = self:GetParent()
		parent:Stop()
		self.endPos = self:GetAbility():GetCursorPosition()
		self.distance = CalculateDistance( self.endPos, parent )
		self.direction = CalculateDirection( self.endPos, parent )
		self.speed = self.distance / self:GetTalentSpecialValueFor("duration") * FrameTime()
		self.initHeight = GetGroundHeight(parent:GetAbsOrigin(), parent)
		self.height = self.initHeight
		self.maxHeight = 650
		self:StartMotionController()

		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_tiny/tiny_toss_boulder.vpcf", PATTACH_POINT_FOLLOW, parent)
					ParticleManager:SetParticleControlEnt(nfx, 0, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
					ParticleManager:SetParticleControlForward(nfx, 0, parent:GetForwardVector())
					ParticleManager:SetParticleControl(nfx, 2, parent:GetAbsOrigin())
					ParticleManager:SetParticleControl(nfx, 3, parent:GetAbsOrigin())
					ParticleManager:SetParticleControl(nfx, 4, parent:GetAbsOrigin())
					ParticleManager:SetParticleControl(nfx, 6, parent:GetAbsOrigin())
					ParticleManager:SetParticleControl(nfx, 7, parent:GetAbsOrigin())
					ParticleManager:SetParticleControl(nfx, 8, parent:GetAbsOrigin())
		self:AttachEffect(nfx)
	end
end


function modifier_tiny_toss_bh_rock:OnRemoved()
	if IsServer() then
		EmitSoundOn("Ability.TossImpact", self:GetParent())
		local parent = self:GetParent()
		local parentPos = parent:GetAbsOrigin()
		local radius = self:GetTalentSpecialValueFor("radius")
		GridNav:DestroyTreesAroundPoint(parentPos, radius, false)
		FindClearSpaceForUnit(parent, parentPos, true)
		local ability = self:GetAbility()
		local damage = self:GetTalentSpecialValueFor("damage")
		local radius = self:GetTalentSpecialValueFor("radius")
		local enemies = self:GetCaster():FindEnemyUnitsInRadius(parentPos, radius)
		for _,enemy in pairs(enemies) do
			if self:GetCaster():HasScepter() then
				enemy:ApplyKnockBack(parentPos, 0.25, 0.25, radius, 350, self:GetCaster(), self:GetAbility())
			end
			ability:DealDamage(self:GetCaster(), enemy, damage, {}, 0)
		end
		
		self:StopMotionController()
	end
end

function modifier_tiny_toss_bh_rock:DoControlledMotion()
	if IsServer() then
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

function modifier_tiny_toss_bh_rock:CheckState()
	return {[MODIFIER_STATE_STUNNED] = true,
			[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
			[MODIFIER_STATE_SILENCED] = true,}
end

function modifier_tiny_toss_bh_rock:IsHidden()
	return true
end

modifier_tiny_toss_bh_charge_handle = class({})

if IsServer() then
    function modifier_tiny_toss_bh_charge_handle:Update()
		self.kv.replenish_time = self:GetAbility():GetTrueCooldown()
		self.kv.max_count = self:GetCaster():FindTalentValue("special_bonus_unique_tiny_toss_bh_2")
		if self:GetStackCount() == self.kv.max_count then
			self:SetDuration(-1, true)
		elseif self:GetStackCount() > self.kv.max_count then
			self:SetDuration(-1, true)
			self:SetStackCount(self.kv.max_count)
		elseif self:GetStackCount() < self.kv.max_count then
			local duration = self.kv.replenish_time
            self:SetDuration(duration, true)
            self:StartIntervalThink(duration)
		end

        if self:GetStackCount() == 0 and not self:IsHidden() then
            self:GetAbility():StartCooldown(self:GetRemainingTime())
        end
    end

    function modifier_tiny_toss_bh_charge_handle:OnCreated()
		kv = {
			max_count = self:GetCaster():FindTalentValue("special_bonus_unique_tiny_toss_bh_2"),
			replenish_time = self:GetAbility():GetTrueCooldown()
		}
        self:SetStackCount(kv.start_count or kv.max_count)
        self.kv = kv

        if kv.start_count and kv.start_count ~= kv.max_count then
            self:Update()
        end
        self:StartIntervalThink(0.25)
    end
	
	function modifier_tiny_toss_bh_charge_handle:OnRefresh()
		self.kv.max_count = self:GetCaster():FindTalentValue("special_bonus_unique_tiny_toss_bh_2")
		self.kv.replenish_time = self:GetAbility():GetTrueCooldown()
        if self:GetStackCount() ~= kv.max_count then
            self:Update()
        end
    end
	
    function modifier_tiny_toss_bh_charge_handle:DeclareFunctions()
        local funcs = {
            MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
        }

        return funcs
    end

    function modifier_tiny_toss_bh_charge_handle:OnAbilityFullyCast(params)
        if params.unit == self:GetParent() then
			self.kv.replenish_time = self:GetAbility():GetTrueCooldown()
			self.kv.max_count = self:GetCaster():FindTalentValue("special_bonus_unique_tiny_toss_bh_2")
			
            local ability = params.ability
            if ability == self:GetAbility() and not self:IsHidden() then
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

    function modifier_tiny_toss_bh_charge_handle:OnIntervalThink()
        local stacks = self:GetStackCount()
		local caster = self:GetCaster()
		local octarine = caster:GetCooldownReduction()
		
		self.kv.replenish_time = self:GetAbility():GetTrueCooldown()
		self.kv.max_count = self:GetCaster():FindTalentValue("special_bonus_unique_tiny_toss_bh_2")
		
        if stacks < self.kv.max_count then
            self:IncrementStackCount()
			self:Update()
        end
    end
end

function modifier_tiny_toss_bh_charge_handle:DestroyOnExpire()
    return false
end

function modifier_tiny_toss_bh_charge_handle:IsPurgable()
    return false
end

function modifier_tiny_toss_bh_charge_handle:RemoveOnDeath()
    return false
end

function modifier_tiny_toss_bh_charge_handle:IsHidden()
	if self:GetCaster():HasTalent("special_bonus_unique_tiny_toss_bh_2") then
    	return false
    else
    	return true
    end
end