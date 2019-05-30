mars_innate = class({})
LinkLuaModifier("modifier_mars_innate_check", "heroes/hero_mars/mars_innate", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mars_innate_warrior", "heroes/hero_mars/mars_innate", LUA_MODIFIER_MOTION_NONE)

function mars_innate:IsStealable()
    return false
end

function mars_innate:IsHiddenWhenStolen()
    return false
end

function mars_innate:OnSpellStart()
	local caster = self:GetCaster()

	local startPos = caster:GetAbsOrigin()
	local dir = caster:GetForwardVector()	

	local rightVector = caster:GetRightVector()

	local radius = caster:GetModelRadius()

	local maxUnits = self:GetTalentSpecialValueFor("max_units")

	local forwardDistance = 200

	if maxUnits % 2 ~= 0 then
		self:SpawnSpearGuy(startPos + dir * forwardDistance)
		maxUnits = maxUnits - 1
	end

	EmitSoundOn("Hero_MonkeyKing.FurArmy", caster)

	for i=1,maxUnits/2 do
		local pos = (startPos + rightVector * radius * i) + dir * forwardDistance
		self:SpawnSpearGuy(pos)
	end

	for i=1,maxUnits/2 do
		local pos = (startPos - rightVector * radius * i) + dir * forwardDistance
		self:SpawnSpearGuy(pos)
	end
end

function mars_innate:SpawnSpearGuy(vLocation)
    local caster = self:GetCaster()
    local location = vLocation

    local duration = self:GetTalentSpecialValueFor("duration")
    local damage = self:GetTalentSpecialValueFor("outgoing")/100
	
	local spearGuy = caster:CreateSummon("npc_mars_warrior", location, duration, false)
	spearGuy:AddNewModifier(caster, self, "modifier_mars_innate_warrior", {})
	spearGuy:SetBaseDamageMax(caster:GetAttackDamage() * damage)
	spearGuy:SetBaseDamageMin(caster:GetAttackDamage() * damage)
	spearGuy:SetForwardVector(caster:GetForwardVector())
end

modifier_mars_innate_warrior = class({})
function modifier_mars_innate_warrior:OnCreated(table)
	if IsServer() then
		self:StartIntervalThink(FrameTime())

		self.radius = 200
	end
end

function modifier_mars_innate_warrior:OnIntervalThink()
	local enemies = self:GetCaster():FindEnemyUnitsInRadius(self:GetParent():GetAbsOrigin(), self.radius)
	for _,enemy in pairs(enemies) do
		if CalculateDistance(enemy, self:GetParent()) < self.radius then
			if not enemy:HasModifier("modifier_mars_innate_check") then
				enemy:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_mars_innate_check", {Duration = 0.1})
			end

			if not enemy:HasModifier("modifier_mars_spear_lua_spear") and not enemy:HasModifier("modifier_mars_spear_lua_debuff") then
				enemy:SetAbsOrigin(enemy:GetAbsOrigin() + self:GetParent():GetForwardVector() * self.radius * FrameTime())
			end
		end
	end
end

function modifier_mars_innate_warrior:CheckState()
	return { 	[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
				[MODIFIER_STATE_INVULNERABLE] = true,
				[MODIFIER_STATE_UNSELECTABLE] = true,
				[MODIFIER_STATE_UNTARGETABLE] = true,
				[MODIFIER_STATE_ATTACK_IMMUNE] = true,
				[MODIFIER_STATE_MAGIC_IMMUNE] = true,
				[MODIFIER_STATE_CANNOT_MISS] = true,
				[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
				[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
				[MODIFIER_STATE_NO_HEALTH_BAR] = true}
end

function modifier_mars_innate_warrior:IsPurgable()
	return false
end

function modifier_mars_innate_warrior:IsHidden()
	return true
end

modifier_mars_innate_check = class({})
function modifier_mars_innate_check:IsHidden()
	return true
end

function modifier_mars_innate_check:IsPurgable()
	return false
end