sand_sandstorm = class({})
LinkLuaModifier("modifier_sandstorm", "heroes/hero_sand/sand_sandstorm.lua", 0)
LinkLuaModifier("modifier_sandstorm_enemy_tornado", "heroes/hero_sand/sand_sandstorm.lua", 0)

function sand_sandstorm:IsStealable()
    return false
end

function sand_sandstorm:IsHiddenWhenStolen()
    return false
end

function sand_sandstorm:GetChannelAnimation()
    return ACT_DOTA_OVERRIDE_ABILITY_2
end

function sand_sandstorm:GetPlaybackRateOverride()
    return 0.5
end

function sand_sandstorm:OnSpellStart()
    local caster = self:GetCaster()

    if caster:HasTalent("special_bonus_unique_sand_sandstorm_2") then
        caster:AddNewModifier(caster, self, "modifier_invisible", {})
    end
    EmitSoundOn("Ability.SandKing_SandStorm.start", caster)
	CreateModifierThinker(caster, self, "modifier_sandstorm", {duration = self:GetTalentSpecialValueFor("sandstorm_duration")}, caster:GetAbsOrigin(), caster:GetTeamNumber(), false)
end

function sand_sandstorm:CreateTornado(position)
    local caster = self:GetCaster()
    local radius = self:GetTalentSpecialValueFor("tornado_search_radius")

    local randoVect = Vector(RandomInt(-radius,radius), RandomInt(-radius,radius), 0)
    pointRando = position + randoVect

    local vDir = CalculateDirection(position, pointRando) * Vector(1,1,0)
    local orbDuration = self:GetTalentSpecialValueFor("tornado_lifetime")
    local orbSpeed = self:GetTalentSpecialValueFor("tornado_speed")
    local orbRadius = self:GetTalentSpecialValueFor("tornado_radius")
	
    local vVelocity = vDir * orbSpeed * FrameTime() * 0.8

    local ProjectileThink = function(self, ... )
        local caster = self:GetCaster()
        local position = self:GetPosition()
        local orbRadius = self:GetRadius()
        local orbSpeed = self:GetSpeed()
        local orbVelocity = self:GetVelocity()
        local HOMING_FACTOR = FrameTime()
        
        local homeEnemies = caster:FindEnemyUnitsInRadius(position, orbRadius * 0.7, {order = FIND_CLOSEST})
        for _, enemy in ipairs(homeEnemies) do
            orbVelocity = orbVelocity + CalculateDirection(enemy:GetAbsOrigin(), position) * orbSpeed * HOMING_FACTOR * FrameTime()
            if orbVelocity:Length2D() > orbSpeed * FrameTime() then orbVelocity = orbVelocity:Normalized() * orbSpeed * FrameTime() end
            if orbVelocity:Length2D() > CalculateDistance(position, enemy:GetAbsOrigin()) then orbVelocity = orbVelocity:Normalized() * CalculateDistance(position, enemy:GetAbsOrigin()) * FrameTime() end
            break
        end

        if #homeEnemies == 0 then
            orbVelocity = orbVelocity + CalculateDirection(pointRando, position) * orbSpeed * HOMING_FACTOR * FrameTime()
            if orbVelocity:Length2D() > orbSpeed * FrameTime() then orbVelocity = orbVelocity:Normalized() * orbSpeed * FrameTime() end
            if orbVelocity:Length2D() > CalculateDistance(position, pointRando) then orbVelocity = orbVelocity:Normalized() * CalculateDistance(position, pointRando) * FrameTime() end
        end

        self:SetVelocity( orbVelocity )
        self:SetPosition( GetGroundPosition(position, nil) + orbVelocity )
        
        homeEnemies = nil
    end
    local ProjectileHit = function(self, target, position)
        if target and target:GetTeam() ~= self:GetCaster():GetTeam() then
            local caster = self:GetCaster()
            local ability = self
            target:AddNewModifier(caster, ability, "modifier_sandstorm_enemy_tornado", {duration = ability:GetTalentSpecialValueFor("tornado_think")})
        end
        return true
    end
    ProjectileHandler:CreateProjectile(ProjectileThink, ProjectileHit, {  FX = "particles/units/heroes/hero_brewmaster/brewmaster_cyclone.vpcf",
                                                                          position = position,
                                                                          caster = caster,
                                                                          ability = self,
                                                                          speed = orbSpeed,
                                                                          radius = orbRadius,
                                                                          velocity = vVelocity,
                                                                          duration = orbDuration})
end

modifier_sandstorm = class({})
if IsServer() then
	function modifier_sandstorm:OnCreated()
		self.storm = ParticleManager:CreateParticle("particles/units/heroes/hero_sandking/sand_sandstorm.vpcf", PATTACH_POINT, self:GetParent())
		ParticleManager:SetParticleControl(self.storm, 0, self:GetParent():GetAbsOrigin())
		self.tornadoTimer = 0
		self.tornadoRate = self:GetTalentSpecialValueFor("tornado_rate")
		self.gracePeriod = self:GetTalentSpecialValueFor("grace_period")
		self.tick = self:GetTalentSpecialValueFor("sandstorm_think")
		self.radius = self:GetTalentSpecialValueFor("sandstorm_base_radius")
		
		EmitSoundOn("Ability.SandKing_SandStorm.loop", self:GetParent())
		
		
		self:StartIntervalThink(self.tick)
	end

	function modifier_sandstorm:OnIntervalThink()
		local caster = self:GetCaster()
		local parent = self:GetParent()
		local parentPos = parent:GetAbsOrigin()
		ParticleManager:SetParticleControl(self.storm, 1, Vector(self.radius,self.radius,self.radius))

		local enemies = caster:FindEnemyUnitsInRadius(parentPos, self.radius, {})
		for _,enemy in pairs(enemies) do
			self:GetAbility():DealDamage(caster, enemy, self:GetTalentSpecialValueFor("sandstorm_damage"), {}, 0)
		end
		self.tornadoTimer = self.tornadoTimer + self.tick
		if self.tornadoTimer >= self.tornadoRate then
			self:GetAbility():CreateTornado(parentPos)
			self.tornadoTimer = 0
		end
		self.radius = self.radius + self:GetTalentSpecialValueFor("sandstorm_radius_grow")
		
		if CalculateDistance( caster, parent ) > self.radius and not self.graceTimer then
			self.graceTimer = Timers:CreateTimer(self.gracePeriod, function()
				if not self or self:IsNull() then return end
				if CalculateDistance( caster, parent ) > self.radius then
					self:Destroy()
				end
				self.graceTimer = nil
			end)
		end
	end

	function modifier_sandstorm:OnRemoved()
		ParticleManager:DestroyParticle(self.storm, false)
		StopSoundOn("Ability.SandKing_SandStorm.loop", self:GetParent())
		self:GetParent():ForceKill(false)
		UTIL_Remove(self:GetParent())
	end
end

function modifier_sandstorm:IsHidden()
    return true
end

modifier_sandstorm_enemy_tornado = class({})
function modifier_sandstorm_enemy_tornado:OnCreated()
    if IsServer() then
        self:StartIntervalThink(self:GetTalentSpecialValueFor("tornado_think"))
    end
end

function modifier_sandstorm_enemy_tornado:OnIntervalThink()
    self:GetAbility():DealDamage(self:GetCaster(), self:GetParent(), self:GetTalentSpecialValueFor("tornado_damage"), {}, 0)
end

function modifier_sandstorm_enemy_tornado:GetEffectName()
    return "particles/econ/courier/courier_roshan_desert_sands/baby_roshan_desert_sands_ambient.vpcf"
end

function modifier_sandstorm_enemy_tornado:DeclareFunctions()
    return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
            MODIFIER_PROPERTY_MISS_PERCENTAGE
            }
end

function modifier_sandstorm_enemy_tornado:GetModifierMoveSpeedBonus_Percentage()
    return -self:GetTalentSpecialValueFor("slow_blind")
end

function modifier_sandstorm_enemy_tornado:GetModifierMiss_Percentage()
    return self:GetTalentSpecialValueFor("slow_blind")
end