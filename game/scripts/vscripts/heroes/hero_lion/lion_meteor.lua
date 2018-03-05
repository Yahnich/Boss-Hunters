lion_meteor = class({})
LinkLuaModifier( "modifier_lion_meteor", "heroes/hero_lion/lion_meteor.lua",LUA_MODIFIER_MOTION_NONE )

function lion_meteor:IsStealable()
    return true
end

function lion_meteor:IsHiddenWhenStolen()
    return false
end

function lion_meteor:GetAOERadius()
    return self:GetTalentSpecialValueFor("radius")
end

function lion_meteor:OnSpellStart()
    local caster = self:GetCaster()

    local radius = self:GetSpecialValueFor("radius")
    local point = self:GetCursorPosition()
	
    if self:GetCursorTarget() then
        point = self:GetCursorTarget():GetAbsOrigin()
    end
	
	self.meteorTable = self.meteorTable or {}

    EmitSoundOn("Hero_Invoker.ChaosMeteor.Cast", caster)

    ParticleManager:FireParticle("particles/units/heroes/hero_invoker/invoker_chaos_meteor_fly.vpcf", PATTACH_POINT, caster, {[0]=point+Vector(0,0,1000),[1]=point,[2]=Vector(1.3,0,0)}) --1.3 is the particle land time
    
    local newRadi = caster:FindTalentValue("special_bonus_unique_lion_meteor_2")
    local randoVect = Vector(RandomInt(-newRadi,newRadi), RandomInt(-newRadi,newRadi), 0)
    pointRando = point + randoVect

    if caster:HasTalent("special_bonus_unique_lion_meteor_2") then
        ParticleManager:FireParticle("particles/units/heroes/hero_invoker/invoker_chaos_meteor_fly.vpcf", PATTACH_POINT, caster, {[0]=pointRando+Vector(0,0,1000),[1]=pointRando,[2]=Vector(1.3,0,0)}) --1.3 is the particle land time
    end

    Timers:CreateTimer(1.3, function()
        EmitSoundOnLocationWithCaster(point, "Hero_Invoker.ChaosMeteor.Impact", caster)

        if caster:HasTalent("special_bonus_unique_lion_meteor_2") then
            EmitSoundOnLocationWithCaster(pointRando, "Hero_Invoker.ChaosMeteor.Impact", caster)

            ParticleManager:FireParticle("particles/units/heroes/hero_invoker/invoker_sun_strike.vpcf", PATTACH_POINT, caster, {[0]=pointRando, [1]=Vector(radius,radius,radius)}) --1.3 is the particle land time
            local enemies = caster:FindEnemyUnitsInRadius(pointRando, radius, {flag = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES})
            for _,enemy in pairs(enemies) do
                enemy:AddNewModifier(caster, self, "modifier_lion_meteor", {Duration = self:GetSpecialValueFor("burn_duration")})
                self:DealDamage(caster, enemy, self:GetTalentSpecialValueFor("damage"), {}, 0)
            end
			local distance = self:GetTalentSpecialValueFor("distance")
			local direction = CalculateDirection(caster:GetAbsOrigin(), pointRando)
			local projID = self:FireLinearProjectile("particles/units/heroes/hero_invoker/invoker_chaos_meteor.vpcf", direction*self:GetSpecialValueFor("speed"), distance, self:GetSpecialValueFor("radius"), {origin = pointRando}, false, true, self:GetSpecialValueFor("vision_distance"))
			self.meteorTable[projID] = GameRules:GetGameTime() + 0.51
		end

        ParticleManager:FireParticle("particles/units/heroes/hero_invoker/invoker_sun_strike.vpcf", PATTACH_POINT, caster, {[0]=point, [1]=Vector(radius,radius,radius)}) --1.3 is the particle land time
        local enemies = caster:FindEnemyUnitsInRadius(point, radius, {flag = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES})
        for _,enemy in pairs(enemies) do
            enemy:AddNewModifier(caster, self, "modifier_lion_meteor", {Duration = self:GetSpecialValueFor("burn_duration")})
            self:DealDamage(caster, enemy, self:GetTalentSpecialValueFor("damage"), {}, 0)

            if caster:HasTalent("special_bonus_unique_lion_meteor_1") then
                self:Stun(enemy, caster:FindTalentValue("special_bonus_unique_lion_meteor_1"), false)
            end
        end

        local distance = self:GetTalentSpecialValueFor("distance")
        local direction = CalculateDirection(caster:GetAbsOrigin(), point)
		
        local projID = self:FireLinearProjectile("particles/units/heroes/hero_invoker/invoker_chaos_meteor.vpcf", direction*self:GetSpecialValueFor("speed"), distance, self:GetSpecialValueFor("radius"), {origin = point}, false, true, self:GetSpecialValueFor("vision_distance"))
		self.meteorTable[projID] = GameRules:GetGameTime() + 0.51
		end)
end

function lion_meteor:OnProjectileThinkHandle(projID)
    local caster = self:GetCaster()
	
	local position = ProjectileManager:GetLinearProjectileLocation( projID )
	local radius = ProjectileManager:GetLinearProjectileRadius( projID )
	if self.meteorTable[projID] and GameRules:GetGameTime() > self.meteorTable[projID] + 0.5 then
		for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( position, radius ) ) do
			if enemy ~= nil then
				enemy:AddNewModifier(caster, self, "modifier_lion_meteor", {Duration = self:GetSpecialValueFor("burn_duration")})
			end
		end
		self.meteorTable[projID] = GameRules:GetGameTime()
	end
end

function lion_meteor:OnProjectileHitHandle(target, position, projID)
    if not target then
		self.meteorTable[projID] = false
	end
end

modifier_lion_meteor = class({})
if IsServer() then
	function modifier_lion_meteor:OnCreated(kv)
		self:SetStackCount(1)
		self:StartIntervalThink(self:GetSpecialValueFor("tick_rate"))
	end
	
	function modifier_lion_meteor:OnRefresh(kv)
		self:IncrementStackCount()
	end
end

function modifier_lion_meteor:OnIntervalThink()
    self:GetAbility():DealDamage(self:GetCaster(), self:GetParent(), self:GetTalentSpecialValueFor("burn_damage") * self:GetStackCount(), {}, 0)
end

function modifier_lion_meteor:GetEffectName()
    return "particles/units/heroes/hero_invoker/invoker_chaos_meteor_burn_debuff.vpcf"
end