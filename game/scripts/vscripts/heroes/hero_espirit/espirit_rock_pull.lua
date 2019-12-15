espirit_rock_pull = class({})
LinkLuaModifier( "modifier_rock_pull", "heroes/hero_espirit/espirit_rock_pull.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_rock_pull_enemy", "heroes/hero_espirit/espirit_rock_pull.lua" ,LUA_MODIFIER_MOTION_NONE )

function espirit_rock_pull:IsStealable()
	return true
end

function espirit_rock_pull:IsHiddenWhenStolen()
	return false
end

function espirit_rock_pull:GetAOERadius()
	return self:GetTalentSpecialValueFor("radius")
end

function espirit_rock_pull:CastFilterResultTarget( target )
	if target:GetName() == "npc_dota_earth_spirit_stone" then
		return UF_SUCCESS
	else
		return UnitFilter( target, TernaryOperator( DOTA_UNIT_TARGET_TEAM_BOTH ,self:GetCaster():HasTalent("special_bonus_unique_espirit_rock_pull_1"), DOTA_UNIT_TARGET_TEAM_ENEMY ), DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0,self:GetCaster():GetTeam() )
	end
end

function espirit_rock_pull:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()

    EmitSoundOn("Hero_EarthSpirit.GeomagneticGrip.Cast", caster)

    local maxTargets = 1
    local curTargets = 0
    if caster:HasTalent("special_bonus_unique_espirit_rock_pull_2") then
    	maxTargets = maxTargets + caster:FindTalentValue("special_bonus_unique_espirit_rock_pull_2")
    end
	if target:GetName() == "npc_dota_earth_spirit_stone" or self:GetCaster():HasTalent("special_bonus_unique_espirit_rock_pull_1") and target:IsSameTeam(caster) then
		target:AddNewModifier(caster, self, "modifier_rock_pull", {})
	elseif not target:IsSameTeam(caster) then
		target:AddNewModifier(caster, self, "modifier_rock_pull_enemy", {duration = 0.5})
	end
	EmitSoundOn("Hero_EarthSpirit.GeomagneticGrip.Target", target)
end

modifier_rock_pull = class({})

function modifier_rock_pull:OnCreated(table)
	if IsServer() then
		caster = self:GetCaster()
		target = self:GetParent()
		self.buffer = target:GetHullRadius() + target:GetCollisionPadding() + caster:GetHullRadius() + caster:GetCollisionPadding()
		self.silence = self:GetTalentSpecialValueFor("duration")
		self:StartIntervalThink(FrameTime())
	end
end

function modifier_rock_pull:OnIntervalThink()
	caster = self:GetCaster()
	target = self:GetParent()
	ability = self:GetAbility()

	local direction = CalculateDirection(target, caster)
	local distance = CalculateDistance(target, caster)

	local enemies = caster:FindEnemyUnitsInRadius(target:GetAbsOrigin(), self:GetSpecialValueFor("radius"))
	for _,enemy in pairs(enemies) do
		if not enemy:HasModifier("modifier_rock_pull_enemy") then
			EmitSoundOn("Hero_EarthSpirit.BoulderSmash.Silence", enemy)
			enemy:Silence(ability, caster, self.silence)
			enemy:AddNewModifier(caster, ability, "modifier_rock_pull_enemy", {Duration = 0.5})
		end
	end

	if distance > self.buffer then
		target:SetAbsOrigin(target:GetAbsOrigin() - direction * 20)
	else
		FindClearSpaceForUnit(target, target:GetAbsOrigin(), true)
		self:Destroy()
	end

end

function modifier_rock_pull:GetEffectName()
	return "particles/units/heroes/hero_earth_spirit/espirit_geomagentic_target_sphere.vpcf"
end

modifier_rock_pull_enemy = class({})

function modifier_rock_pull_enemy:OnCreated(table)
	if IsServer() then
		EmitSoundOn("Hero_EarthSpirit.GeomagneticGrip.Damage", self:GetParent())
		if not self:GetParent():TriggerSpellAbsorb( self:GetAbility() ) then self:GetAbility():DealDamage(self:GetCaster(), self:GetParent(), self:GetSpecialValueFor("damage"), {}, 0) end
	end
end

function modifier_rock_pull_enemy:IsHidden()
	return true
end

function modifier_rock_pull_enemy:GetEffectName()
	return "particles/units/heroes/hero_earth_spirit/espirit_geomagentic_target_sphere.vpcf"
end