sd_disruption = class({})
LinkLuaModifier("modifier_sd_disruption", "heroes/hero_shadow_demon/sd_disruption", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_sd_disruption_charges", "heroes/hero_shadow_demon/sd_disruption", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_sd_disruption_charges_handle", "heroes/hero_shadow_demon/sd_disruption", LUA_MODIFIER_MOTION_NONE)

function sd_disruption:IsStealable()
	return true
end

function sd_disruption:IsHiddenWhenStolen()
	return false
end

function sd_disruption:GetIntrinsicModifierName()
	return "modifier_sd_disruption_charges_handle"
end

function sd_disruption:HasCharges()
	return true
end

function sd_disruption:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end

function sd_disruption:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition() + Vector(0,0,128)

	EmitSoundOn("Hero_ShadowDemon.Disruption.Cast", caster)
	EmitSoundOnLocationWithCaster(point, "Hero_ShadowDemon.Disruption", caster)
	
	if caster:HasTalent("special_bonus_unique_sd_disruption_2") then
		self:floatyOrb()
	else
		CreateModifierThinker(caster, self, "modifier_sd_disruption", {Duration = self:GetSpecialValueFor("duration")}, point, caster:GetTeam(), false)
	end
end

function sd_disruption:floatyOrb()
	local caster = self:GetCaster()
	local mousePos = self:GetCursorPosition()
	
	local vDir = CalculateDirection(mousePos, caster) * Vector(1,1,0)
	local orbDuration = self:GetSpecialValueFor("duration")*2
	local orbSpeed = 500
	local orbRadius = self:GetSpecialValueFor("radius")
	
	local position = mousePos
	local vVelocity = Vector(0,0,0)
	
	self.counter = 0

	position = GetGroundPosition(position, nil) + Vector(0,0,128)
	
	local ProjectileThink = function(self, ... )
		local caster = self:GetCaster()
		local position = self:GetPosition()
		local orbRadius = self:GetRadius()
		local orbSpeed = self:GetSpeed()
		local orbVelocity = self:GetVelocity()
		local HOMING_FACTOR = 0.01
		local ability = self:GetAbility()
		
		local homeEnemies = caster:FindEnemyUnitsInRadius(position, orbRadius * 2, {order = FIND_CLOSEST})
		for _, enemy in ipairs(homeEnemies) do
			orbVelocity = orbVelocity + CalculateDirection(enemy, position) * orbSpeed * HOMING_FACTOR * FrameTime()
			if orbVelocity:Length2D() > orbSpeed * FrameTime() then orbVelocity = orbVelocity:Normalized() * orbSpeed * FrameTime() end
			if orbVelocity:Length2D() > CalculateDistance(position, enemy) then orbVelocity = orbVelocity:Normalized() * CalculateDistance(position, enemy) * FrameTime() end
			break
		end
		if #homeEnemies == 0 then
			orbVelocity = orbVelocity + CalculateDirection(mousePos, position) * orbSpeed * HOMING_FACTOR * FrameTime()
			if orbVelocity:Length2D() > orbSpeed * FrameTime() then orbVelocity = orbVelocity:Normalized() * orbSpeed * FrameTime() end
			if orbVelocity:Length2D() > CalculateDistance(position, mousePos) then orbVelocity = orbVelocity:Normalized() * CalculateDistance(position, mousePos) * FrameTime() end
		end

		if ability.counter >= ability:GetSpecialValueFor("tick_rate") + FrameTime() then
			self.hitUnits = {}
			ability.counter = 0
		else
			ability.counter = ability.counter + FrameTime()
		end

		self:SetVelocity( orbVelocity )
		self:SetPosition( GetGroundPosition(position, nil) + Vector(0,0,128) + orbVelocity )
		
		homeEnemies = nil
	end
	local ProjectileHit = function(self, target, position)
		local caster = self:GetCaster()
		local ability = self:GetAbility()	
			
		local enemies = caster:FindEnemyUnitsInRadius(position, ability:GetSpecialValueFor("radius"))
		for _,enemy in pairs(enemies) do
			if not self.hitUnits[enemy:entindex()] then
				local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_dark_seer/dark_seer_ion_shell_damage.vpcf", PATTACH_POINT, caster)
					ParticleManager:SetParticleControl(nfx, 0, position)
					ParticleManager:SetParticleControlEnt(nfx, 1, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true)
					ParticleManager:ReleaseParticleIndex(nfx)

				ability:DealDamage(caster, enemy, ability:GetSpecialValueFor("damage")*ability:GetSpecialValueFor("tick_rate"), {}, 0)
				self.hitUnits[enemy:entindex()] = true
			end
		end
			
		return true
	end
	ProjectileHandler:CreateProjectile(ProjectileThink, ProjectileHit, {  FX = "particles/units/heroes/hero_shadow_demon/shadow_demon_distruption_orb.vpcf",
																		  position = position,
																		  caster = caster,
																		  ability = self,
																		  speed = orbSpeed,
																		  radius = orbRadius,
																		  hitUnits = {},
																		  velocity = vVelocity,
																		  duration = orbDuration})
end

modifier_sd_disruption = class({})
function modifier_sd_disruption:OnCreated(table)
	if IsServer() then
		local caster = self:GetCaster()
		local parent = self:GetParent()

		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_shadow_demon/shadow_demon_disruption.vpcf", PATTACH_POINT, caster)
					ParticleManager:SetParticleControl(nfx, 0, parent:GetAbsOrigin())
		self:AttachEffect(nfx)
		self:StartIntervalThink(self:GetSpecialValueFor("tick_rate"))
	end
end

function modifier_sd_disruption:OnIntervalThink()
	local caster = self:GetCaster()
	local enemies = caster:FindEnemyUnitsInRadius(self:GetParent():GetAbsOrigin(), self:GetSpecialValueFor("radius"))
	for _,enemy in pairs(enemies) do
		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_dark_seer/dark_seer_ion_shell_damage.vpcf", PATTACH_POINT_FOLLOW, caster)
					ParticleManager:SetParticleControlEnt(nfx, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
					ParticleManager:SetParticleControlEnt(nfx, 1, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true)
					ParticleManager:ReleaseParticleIndex(nfx)

		self:GetAbility():DealDamage(caster, enemy, self:GetSpecialValueFor("damage")*self:GetSpecialValueFor("tick_rate"), {}, 0)
	end
end

function modifier_sd_disruption:OnRemoved()
	if IsServer() then
		EmitSoundOn("Hero_ShadowDemon.Disruption.End", self:GetParent())
	end
end

modifier_sd_disruption_charges_handle = class({})

function modifier_sd_disruption_charges_handle:OnCreated()
    if IsServer() then
        self:StartIntervalThink(0.1)
    end
end

function modifier_sd_disruption_charges_handle:OnIntervalThink()
    local caster = self:GetCaster()

    if self:GetCaster():HasTalent("special_bonus_unique_sd_disruption_1") then
        if not caster:HasModifier("modifier_sd_disruption_charges") then
            self:GetAbility():EndCooldown()
            caster:AddNewModifier(caster, self:GetAbility(), "modifier_sd_disruption_charges", {})
        end
    else
    	if caster:HasModifier("modifier_sd_disruption_charges") then
    		caster:RemoveModifierByName("modifier_sd_disruption_charges")
    	end
    end
end

function modifier_sd_disruption_charges_handle:DestroyOnExpire()
    return false
end

function modifier_sd_disruption_charges_handle:IsPurgable()
    return false
end

function modifier_sd_disruption_charges_handle:RemoveOnDeath()
    return false
end

function modifier_sd_disruption_charges_handle:IsHidden()
    return true
end


modifier_sd_disruption_charges = class({})
if IsServer() then
    function modifier_sd_disruption_charges:Update()
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

    function modifier_sd_disruption_charges:OnCreated()
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
	
	function modifier_sd_disruption_charges:OnRefresh()
		self.kv.max_count = self:GetTalentSpecialValueFor("charges")
		self.kv.replenish_time = self:GetAbility():GetTrueCooldown()
        if self:GetStackCount() ~= kv.max_count then
            self:Update()
        end
    end
	
    function modifier_sd_disruption_charges:DeclareFunctions()
        local funcs = {
            MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
        }

        return funcs
    end

    function modifier_sd_disruption_charges:OnAbilityFullyCast(params)
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

    function modifier_sd_disruption_charges:OnIntervalThink()
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

function modifier_sd_disruption_charges:DestroyOnExpire()
    return false
end

function modifier_sd_disruption_charges:IsPurgable()
    return false
end

function modifier_sd_disruption_charges:RemoveOnDeath()
    return false
end

function modifier_sd_disruption_charges:IsHidden()
	if self:GetCaster():HasTalent("special_bonus_unique_sd_disruption_1") then
    	return false
    else
    	return true
    end
end