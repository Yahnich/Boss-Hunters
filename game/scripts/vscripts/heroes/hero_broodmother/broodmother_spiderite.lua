broodmother_spiderite = class({})
LinkLuaModifier("modifier_broodmother_spiderite", "heroes/hero_broodmother/broodmother_spiderite", LUA_MODIFIER_MOTION_NONE)

function broodmother_spiderite:OnSpellStart()
	local caster = self:GetCaster()
	
	local egg = caster:CreateSummon("npc_dota_spider_sack", caster:GetAbsOrigin(), self:GetTalentSpecialValueFor("duration"))
    FindClearSpaceForUnit(egg, caster:GetAbsOrigin(), false)
    egg:AddNewModifier(caster, self, "modifier_broodmother_spiderite", {Duration = self:GetTalentSpecialValueFor("duration")})
end

modifier_broodmother_spiderite = class({})
function modifier_broodmother_spiderite:OnCreated(table)
    if IsServer() then self:StartIntervalThink(0.1) end
end

function modifier_broodmother_spiderite:OnIntervalThink()
    local enemies = self:GetCaster():FindEnemyUnitsInRadius(self:GetParent():GetAbsOrigin(), self:GetTalentSpecialValueFor("squish_radius"))
    if #enemies > 0 then self:Destroy() end
end

function modifier_broodmother_spiderite:CheckState()
    return {[MODIFIER_STATE_NO_HEALTH_BAR] = true,
            [MODIFIER_STATE_NO_TEAM_SELECT] = true,
            [MODIFIER_STATE_UNSELECTABLE] = true,
            [MODIFIER_STATE_NOT_ON_MINIMAP_FOR_ENEMIES] = true,
            [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
            [MODIFIER_STATE_ROOTED] = true,
            [MODIFIER_STATE_INVULNERABLE] = true,
        }
end

function modifier_broodmother_spiderite:OnRemoved()
    if IsServer() then
    	local caster = self:GetCaster()
        EmitSoundOn("Hero_Broodmother.SpawnSpiderlings", self:GetParent())
    	ParticleManager:FireParticle("particles/units/heroes/hero_bristleback/bristleback_loadout.vpcf", PATTACH_POINT, caster, {[0]=self:GetParent():GetAbsOrigin(), [1]=self:GetParent():GetAbsOrigin()})
    	local count = self:GetTalentSpecialValueFor("count") - self:GetRemainingTime()
        if count < 1 then count = 0 end
        math.floor(count)
        for i=1,count do
    		local position = self:GetParent():GetAbsOrigin() + ActualRandomVector(200, 100)
    		local spider = caster:CreateSummon("npc_dota_broodmother_spiderite", position, self:GetTalentSpecialValueFor("spider_duration"))
    		FindClearSpaceForUnit(spider, position, false)
            local percentD = self:GetTalentSpecialValueFor("spider_damage")/100
            local percentH = self:GetTalentSpecialValueFor("spider_health")/100
    		spider:SetBaseDamageMin(caster:GetBaseDamageMin() * percentD)
    		spider:SetBaseDamageMax(caster:GetBaseDamageMax() * percentD)
    		spider:SetBaseAttackTime(caster:GetSecondsPerAttack())
			local hp = caster:GetMaxHealth() * percentH
			spider:SetBaseMaxHealth(hp)
    		spider:SetMaxHealth(hp)
    		spider:SetHealth(hp)
    		spider:SetBaseMoveSpeed(caster:GetBaseMoveSpeed())

            spider:AddAbility("broodmother_bite"):SetLevel(1)
    	end
        self:GetParent():AddNoDraw()
    end
end