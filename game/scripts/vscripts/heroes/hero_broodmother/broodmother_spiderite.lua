broodmother_spiderite = class({})
LinkLuaModifier("modifier_broodmother_spiderite", "heroes/hero_broodmother/broodmother_spiderite", LUA_MODIFIER_MOTION_NONE)

function broodmother_spiderite:OnSpellStart()
	local caster = self:GetCaster()
	
	local egg = caster:CreateSummon("npc_dota_spider_sack", caster:GetAbsOrigin(), self:GetSpecialValueFor("duration") + 0.1)
    FindClearSpaceForUnit(egg, caster:GetAbsOrigin(), false)
    egg:AddNewModifier(caster, self, "modifier_broodmother_spiderite", {Duration = self:GetSpecialValueFor("duration") + 0.1})
end

modifier_broodmother_spiderite = class({})
function modifier_broodmother_spiderite:OnCreated(table)
	self.hatch_delay = 0
    if IsServer() then self:StartIntervalThink(0.1) end
end

function modifier_broodmother_spiderite:OnIntervalThink()
    local enemies = self:GetCaster():FindEnemyUnitsInRadius(self:GetParent():GetAbsOrigin(), self:GetSpecialValueFor("squish_radius"))
    if #enemies > 0 then
		self:Destroy() 
		return
	end
	self.hatch_delay = self.hatch_delay - 0.1
	if self.hatch_delay <= 0 then
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		self.hatch_delay = 1
		
		local position = self:GetParent():GetAbsOrigin() + ActualRandomVector(200, 100)
		local spider = caster:CreateSummon("npc_dota_broodmother_spiderite", position, self:GetSpecialValueFor("spider_duration"))
		FindClearSpaceForUnit(spider, position, false)
		spider:SetAverageBaseDamage( self:GetSpecialValueFor("spider_damage") )
		spider:SetBaseAttackTime( 1 )
		spider:SetCoreHealth( self:GetSpecialValueFor("spider_health") )
		spider:SetBaseMagicalResistanceValue( self:GetSpecialValueFor("spider_mr") )
		spider:AddNewModifier( caster, ability, "modifier_broodmother_spiderite_evasion", {})

		spider:AddAbility("broodmother_bite"):SetLevel(1)
		
        EmitSoundOn("Hero_Broodmother.SpawnSpiderlings", self:GetParent())
	end
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
		local ability = self:GetAbility()
        EmitSoundOn("Hero_Broodmother.SpawnSpiderlings", self:GetParent())
    	ParticleManager:FireParticle("particles/units/heroes/hero_bristleback/bristleback_loadout.vpcf", PATTACH_POINT, caster, {[0]=self:GetParent():GetAbsOrigin(), [1]=self:GetParent():GetAbsOrigin()})
    	local count = math.floor( math.max( 0, ( self:GetRemainingTime() ) / 2 ) )
		if count > 0 then
			for i=1,count do
				local position = self:GetParent():GetAbsOrigin() + ActualRandomVector(200, 100)
				local spider = caster:CreateSummon("npc_dota_broodmother_spiderite", position, self:GetSpecialValueFor("spider_duration"))
				FindClearSpaceForUnit(spider, position, false)
				spider:SetAverageBaseDamage( self:GetSpecialValueFor("spider_damage") )
				spider:SetBaseAttackTime( 1 )
				spider:SetCoreHealth( self:GetSpecialValueFor("spider_health") )
				spider:SetBaseMagicalResistanceValue( self:GetSpecialValueFor("spider_mr") )
				spider:AddNewModifier( caster, ability, "modifier_broodmother_spiderite_evasion", {})
				
				spider:AddAbility("broodmother_bite"):SetLevel(1)
			end
		end
        self:GetParent():AddNoDraw()
    end
end

modifier_broodmother_spiderite_evasion = class({})
LinkLuaModifier("modifier_broodmother_spiderite_evasion", "heroes/hero_broodmother/broodmother_spiderite", LUA_MODIFIER_MOTION_NONE)

function modifier_broodmother_spiderite_evasion:OnCreated()
	self.evasion = self:GetSpecialValueFor("spider_evasion")
	self.talent = self:GetCaster():HasTalent("special_bonus_unique_broodmother_spiderite_2")
	self.prng = self:GetCaster():FindTalentValue("special_bonus_unique_broodmother_spiderite_2")
end

function modifier_broodmother_spiderite_evasion:DeclareFunctions()
	return {MODIFIER_PROPERTY_EVASION_CONSTANT,
			MODIFIER_EVENT_ON_ATTACK_LANDED }
end

function modifier_broodmother_spiderite_evasion:OnAttackLanded(params)
	if self.talent and params.attacker == self:GetParent() and not params.attacker:HasModifier("modifier_broodmother_spiderite_talent") and self:RollPRNG( self.prng ) then
		params.attacker:AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_broodmother_spiderite_talent", {} )
		params.attacker:SetParent(params.target, nil)
		params.attacker:FollowEntity(params.target, false)
		params.attacker:SetOrigin( params.target:GetOrigin() + RandomVector( params.target:GetHullRadius() ) + Vector( 0,0, RandomInt(32,128) ) )
		params.attacker:SetAngles( RandomFloat(-90, 90), RandomFloat(-90, 90), RandomFloat(-90, 90) )
	end
end

function modifier_broodmother_spiderite_evasion:GetModifierEvasion_Constant()
	return self.evasion
end

modifier_broodmother_spiderite_talent = class({})
LinkLuaModifier("modifier_broodmother_spiderite_talent", "heroes/hero_broodmother/broodmother_spiderite", LUA_MODIFIER_MOTION_NONE)

function modifier_broodmother_spiderite_talent:CheckState()
	return {[MODIFIER_STATE_ROOTED] = true,
			[MODIFIER_STATE_INVULNERABLE] = true,
			[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
			[MODIFIER_STATE_NO_HEALTH_BAR] = true,
			[MODIFIER_STATE_NO_UNIT_COLLISION] = true,}
end
function modifier_broodmother_spiderite_talent:IsHidden()
	return true
end