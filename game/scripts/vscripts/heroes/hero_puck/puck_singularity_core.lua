puck_singularity_core = class({})

function puck_singularity_core:GetBehavior()
    if self:GetSpecialValueFor("no_target") ~= 0 then
        return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_AOE
    else
        return self.BaseClass.GetBehavior(self)
    end
end

function puck_singularity_core:GetAOERadius()
    return self:GetSpecialValueFor("coil_radius")
end

function puck_singularity_core:OnSpellStart()
    local caster = self:GetCaster()
    local position
    if self:GetSpecialValueFor("no_target") == 0 then
        position = self:GetCursorPosition()
    else
        position = caster:GetAbsOrigin()
    end
    self:CreateCore(position)
end

function puck_singularity_core:CreateCore(position)
    local caster = self:GetCaster()
    local vPos = GetGroundPosition(position, caster)

	EmitSoundOnLocationWithCaster(vPos, "Hero_Puck.Dream_Coil", caster)
	CreateModifierThinker(caster, self, "modifier_puck_singularity_core_thinker", {duration = self:GetSpecialValueFor("coil_duration")}, vPos, caster:GetTeam(), false)
end


modifier_puck_singularity_core_thinker = class({})
LinkLuaModifier("modifier_puck_singularity_core_thinker", "heroes/hero_puck/puck_singularity_core", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
    function modifier_puck_singularity_core_thinker:OnCreated()
        local parent = self:GetParent()
        local caster = self:GetCaster()
        self.radius = self:GetSpecialValueFor("coil_radius")
        self.duration = self:GetSpecialValueFor("coil_duration")
        self.init_damage = self:GetSpecialValueFor("coil_init_damage_tooltip")
        self.break_damage = self:GetSpecialValueFor("coil_break_damage")

        if self:GetSpecialValueFor("auto_attack") ~= 0 then
            self.attackRate = caster:GetSecondsPerAttack(false)
        end

        local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_puck/puck_dreamcoil.vpcf", PATTACH_POINT, caster)
                    ParticleManager:SetParticleControl(nfx, 0, parent:GetAbsOrigin())
        self:AttachEffect(nfx)

        for _, enemy in ipairs(caster:FindEnemyUnitsInRadius(parent:GetAbsOrigin(), self.radius)) do
            if not enemy:TriggerSpellAbsorb(self) then
                enemy:AddNewModifier(caster, self:GetAbility(), "modifier_puck_singularity_core_leash", {duration = self.duration, entindex = parent:entindex()})
            end
        end

        self:StartIntervalThink(0)
    end

    function modifier_puck_singularity_core_thinker:OnIntervalThink()
        local ability = self:GetAbility()
        local parent = self:GetParent()
        local caster = self:GetCaster()
        local break_distance = self:GetSpecialValueFor("coil_break_radius")
        local coil_stun_duration = self:GetSpecialValueFor("coil_stun_duration")

        local auto_attack = self:GetSpecialValueFor("auto_attack")
        local rapid_break = self:GetSpecialValueFor("rapid_break")

        for _, enemy in ipairs(caster:FindEnemyUnitsInRadius(parent:GetAbsOrigin(), -1)) do
            if auto_attack ~= 0 then
                if enemy:HasModifier("modifier_puck_singularity_core_leash") or enemy:HasModifier("modifier_puck_singularity_core_break") then
                    self.attackRate = self.attackRate - FrameTime()
                    if self.attackRate <= 0 then
                        self.attackRate = caster:GetSecondsPerAttack(false)
                        caster:PerformGenericAttack(enemy, true)
		            end
                end
            end

            if rapid_break == 0 then
                if enemy:HasModifier("modifier_puck_singularity_core_leash") and CalculateDistance(enemy, parent) > break_distance then
                    EmitSoundOn("Hero_Puck.Dream_Coil_Snap", enemy)
                    enemy:RemoveModifierByName("modifier_puck_singularity_core_leash")
                    enemy:AddNewModifier(caster, ability, "modifier_puck_singularity_core_break", {duration = coil_stun_duration})
                    ability:Stun(enemy, coil_stun_duration)
                    ability:DealDamage(caster, enemy, self.break_damage)
                else
                    if not enemy:HasModifier("modifier_puck_singularity_core_leash") and CalculateDistance(enemy, parent) < break_distance then
                        enemy:AddNewModifier(caster, ability, "modifier_puck_singularity_core_leash", {duration = self.duration, entindex = parent:entindex()})
                        break
                    end
                end
            else
                if enemy:HasModifier("modifier_puck_singularity_core_leash") and not enemy:HasModifier("modifier_puck_singularity_core_break") then
                    EmitSoundOn("Hero_Puck.Dream_Coil_Snap", enemy)
                    enemy:RemoveModifierByName("modifier_puck_singularity_core_leash")
                    enemy:AddNewModifier(caster, self, "modifier_puck_singularity_core_break", {duration = coil_stun_duration})
                    ability:Stun(enemy, coil_stun_duration)
                    ability:DealDamage(caster, enemy, self.break_damage)
                else
                    if not enemy:HasModifier("modifier_puck_singularity_core_leash") and CalculateDistance(enemy, parent) < break_distance then
                        enemy:AddNewModifier(caster, ability, "modifier_puck_singularity_core_leash", {duration = self.duration, entindex = parent:entindex()})
                        break
                    end
                end
            end
        end
    end

    function modifier_puck_singularity_core_thinker:OnDestroy()
        local ability = self:GetAbility()
        local parent = self:GetParent()
        local caster = self:GetCaster()
        local int_multiplier =  self:GetSpecialValueFor("int_multiplier") / 100
        local explosion_damage = caster:GetIntellect(true) * int_multiplier

        for _, enemy in ipairs(caster:FindEnemyUnitsInRadius(parent:GetAbsOrigin(), -1)) do
            if enemy:HasModifier("modifier_puck_singularity_core_leash") then
                EmitSoundOn("Hero_Puck.Dream_Coil_Snap", enemy)
				enemy:RemoveModifierByName("modifier_puck_singularity_core_leash")
				ability:Stun(enemy, self:GetSpecialValueFor("coil_stun_duration"))
				ability:DealDamage(caster, enemy, self.break_damage)
            end
        end

        if self:GetSpecialValueFor("explodes") ~= 0 then
            local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_techies/techies_blast_off.vpcf", PATTACH_ABSORIGIN, caster)
                        ParticleManager:SetParticleControl(nfx, 0, parent:GetAbsOrigin())
            EmitSoundOn("Hero_Techies.Suicide", parent)
            for _, enemy in ipairs(caster:FindEnemyUnitsInRadius(parent:GetAbsOrigin(), self:GetSpecialValueFor("coil_radius"))) do
                ability:DealDamage(caster, enemy, self.break_damage + explosion_damage)
            end
        end
    end
end

modifier_puck_singularity_core_leash = class({})
LinkLuaModifier("modifier_puck_singularity_core_leash", "heroes/hero_puck/puck_singularity_core", LUA_MODIFIER_MOTION_NONE)

function modifier_puck_singularity_core_leash:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_puck_singularity_core_leash:OnCreated(kv)
    self.dmg_reduction = self:GetSpecialValueFor("dmg_reduction")
	if IsServer() then

		local caster = EntIndexToHScript(tonumber(kv.entindex))
		local parent = self:GetParent()
		local ability = self:GetAbility()
		
		ability:Stun(parent, self:GetSpecialValueFor("coil_init_stun_duration"))
		ability:DealDamage(caster, parent, self:GetSpecialValueFor("coil_break_damage"))
		
		local FX = ParticleManager:CreateParticle("particles/units/heroes/hero_puck/puck_dreamcoil_tether.vpcf", PATTACH_POINT_FOLLOW, caster)
		ParticleManager:SetParticleControlEnt(FX, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(FX, 1, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
		self:AddEffect(FX)
	end
end

function modifier_puck_singularity_core_leash:DeclareFunctions()
    return {MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE}
end

function modifier_puck_singularity_core_leash:GetModifierDamageOutgoing_Percentage()
    return -self.dmg_reduction
end



modifier_puck_singularity_core_break = class({})
LinkLuaModifier("modifier_puck_singularity_core_break", "heroes/hero_puck/puck_singularity_core", LUA_MODIFIER_MOTION_NONE)

function modifier_puck_singularity_core_break:IsDebuff()
    return true
end

function modifier_puck_singularity_core_break:IsPurgable()
    return true
end