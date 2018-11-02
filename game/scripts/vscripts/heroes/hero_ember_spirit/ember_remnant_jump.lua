ember_remnant_jump = class({})
LinkLuaModifier("modifier_ember_remnant_jump", "heroes/hero_ember_spirit/ember_remnant_jump", LUA_MODIFIER_MOTION_NONE)

function ember_remnant_jump:IsStealable()
	return false
end

function ember_remnant_jump:IsHiddenWhenStolen()
	return false
end

function ember_remnant_jump:GetCooldown(iLvl)
    local cooldown = self.BaseClass.GetCooldown(self, iLvl)
    local caster = self:GetCaster()
    local talent = "special_bonus_unique_ember_remnant_jump_1"
    local value = caster:FindTalentValue("special_bonus_unique_ember_remnant_jump_1")
    if caster:HasTalent( talent ) then cooldown = cooldown + value end
    return cooldown
end

function ember_remnant_jump:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
	
	self.totesRems = {}

	local remnants = caster:FindFriendlyUnitsInRadius(point, FIND_UNITS_EVERYWHERE, {flag = DOTA_UNIT_TARGET_FLAG_INVULNERABLE, order = FIND_FARTHEST})
	for _,remnant in pairs(remnants) do
		if remnant:HasModifier("modifier_ember_remnant") then
			table.insert(self.totesRems, remnant)
		end
	end

	ProjectileManager:ProjectileDodge(caster)
	caster:AddNewModifier(caster, self, "modifier_ember_remnant_jump", {})
end

modifier_ember_remnant_jump = class({})

function modifier_ember_remnant_jump:OnCreated(table)
	if IsServer() then
		local caster = self:GetCaster()
		local ability = self:GetAbility()

		EmitSoundOn("Hero_EmberSpirit.FireRemnant.Activate", caster)

		self.radius = self:GetTalentSpecialValueFor("radius")
		self.damage = self:GetTalentSpecialValueFor("damage")

		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_ember_spirit/ember_spirit_remnant_dash.vpcf", PATTACH_POINT_FOLLOW, caster)
					ParticleManager:SetParticleControlEnt(nfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
					ParticleManager:SetParticleControlEnt(nfx, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
		self:AttachEffect(nfx)

		for _,remnant in ipairs(ability.totesRems) do
			if remnant and remnant:HasModifier("modifier_ember_remnant") then
				caster:FaceTowards(remnant:GetAbsOrigin())
				self.distance = CalculateDistance(remnant, caster)
				self.direction = CalculateDirection(remnant, caster)
				break
			end
		end

		self:StartMotionController()
	end
end

function modifier_ember_remnant_jump:OnRemoved()
	if IsServer() then
		local caster = self:GetCaster()
		local ability = self:GetAbility()

		StopSoundOn("Hero_EmberSpirit.FireRemnant.Activate", caster)
		EmitSoundOn("Hero_EmberSpirit.FireRemnant.Stop", caster)

		if #ability.totesRems > 0 then
			caster:AddNewModifier(caster, ability, "modifier_ember_remnant_jump", {})
		end
	end
end

function modifier_ember_remnant_jump:DoControlledMotion()
	local parent = self:GetParent()
	local ability = self:GetAbility()
	local speed = parent:GetIdealSpeedNoSlows() * 10 * FrameTime()

	if self.distance > 0 then
		self.distance = self.distance - speed
		parent:SetAbsOrigin(GetGroundPosition(parent:GetAbsOrigin(), parent) + self.direction*speed)

	else
		FindClearSpaceForUnit(parent, parent:GetAbsOrigin(), true)
		
		for _,remnant in ipairs(ability.totesRems) do
			table.remove(ability.totesRems, _)
			if remnant then
				EmitSoundOn("Hero_EmberSpirit.FireRemnant.Explode", remnant)
				if not parent:HasTalent("special_bonus_unique_ember_remnant_jump_1") then
					remnant:ForceKill(false)
				end
			end
			break
		end

		local enemies = parent:FindEnemyUnitsInRadius(parent:GetAbsOrigin(), self.radius)
		for _,enemy in pairs(enemies) do
			ability:DealDamage(parent, enemy, self.damage, {}, 0)
		end

		self:StopMotionController(true)
	end
end

function modifier_ember_remnant_jump:CheckState()
	local state = { [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
					[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
					[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
					[MODIFIER_STATE_UNSELECTABLE] = true,
					[MODIFIER_STATE_UNTARGETABLE] = true,
					[MODIFIER_STATE_NO_HEALTH_BAR] = true,
					[MODIFIER_STATE_ROOTED] = true,
					[MODIFIER_STATE_INVULNERABLE] = true}
	return state
end