dw_bramble = class({})
LinkLuaModifier("modifier_dw_bramble", "heroes/hero_dark_willow/dw_bramble", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_dw_bramble_damage", "heroes/hero_dark_willow/dw_bramble", LUA_MODIFIER_MOTION_NONE)

function dw_bramble:IsStealable()
    return true
end

function dw_bramble:IsHiddenWhenStolen()
    return false
end

function dw_bramble:GetAOERadius()
    return self:GetTalentSpecialValueFor("radius")
end

function dw_bramble:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
	
	EmitSoundOn("Hero_DarkWillow.Brambles.Cast", caster)
	EmitSoundOnLocationWithCaster(point, "Hero_DarkWillow.Brambles.CastTarget", caster)

	self:GrowMaze(point)
end

function dw_bramble:PlantBush(vLocation)
	local caster = self:GetCaster()

	local point = vLocation

	local duration = self:GetTalentSpecialValueFor("duration")
	local bush = CreateModifierThinker(caster, self, "modifier_dw_bramble", {Duration = duration}, point, caster:GetTeam(), false)

end

function dw_bramble:GrowMaze(vLocation)
	local caster = self:GetCaster()
	local point = vLocation

	local direction = CalculateDirection(point, caster:GetAbsOrigin())
	local radius = self:GetTalentSpecialValueFor("radius")
	local duration = self:GetTalentSpecialValueFor("duration")
	local limit = self:GetTalentSpecialValueFor("max_count")

	local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_dark_willow/dark_willow_bramble_cast.vpcf", PATTACH_POINT, caster)
				ParticleManager:SetParticleControlEnt(nfx, 0, caster, PATTACH_POINT, "attach_attack1", caster:GetAbsOrigin(), true)
				ParticleManager:SetParticleControl(nfx, 1, point)
				ParticleManager:SetParticleControl(nfx, 2, Vector(radius, 0, 0))

	local spawn_point1 = point + direction * radius/2
	local spawn_point2 = point + direction * radius

	self:PlantBush(point)
	for i=1,(limit-1)/2 do
		-- Set QAngles
	    local qAngle = QAngle(0, i * 90, 0)

	    local newSpawn = RotatePosition(point, qAngle, spawn_point1)
	    
	    self:PlantBush(newSpawn)
	end

	for i=1,(limit-1)/2 do
		-- Set QAngles
	    local qAngle = QAngle(0, 45 + i * 90, 0)

	    local newSpawn = RotatePosition(point, qAngle, spawn_point2)
	    
	    self:PlantBush(newSpawn)
	end

	Timers:CreateTimer(duration, function()
		ParticleManager:ClearParticle(nfx)
	end)
end

modifier_dw_bramble = class({})
function modifier_dw_bramble:OnCreated(table)
	if IsServer() then
		local caster = self:GetCaster()
		local point = self:GetParent():GetAbsOrigin()

		EmitSoundOn("Hero_DarkWillow.Bramble.Spawn", self:GetParent())
		EmitSoundOn("Hero_DarkWillow.BrambleLoop", self:GetParent())

		self.radius = self:GetTalentSpecialValueFor("latch_range")
		self.duration = self:GetTalentSpecialValueFor("debuff_duration")

		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_dark_willow/dark_willow_bramble_wraith.vpcf", PATTACH_POINT, caster)
					ParticleManager:SetParticleControl(nfx, 0, point)
					ParticleManager:SetParticleControl(nfx, 1, Vector(self.radius, self.radius, self.radius))

		self:AttachEffect(nfx)

		self:StartIntervalThink(self:GetTalentSpecialValueFor("delay"))
	end
end

function modifier_dw_bramble:OnIntervalThink()
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	local point = self:GetParent():GetAbsOrigin()

	local enemies = caster:FindEnemyUnitsInRadius(point, self.radius)
	for _,enemy in pairs(enemies) do
		EmitSoundOn("Hero_DarkWillow.Bramble.Target.Layer", self:GetParent())
		enemy:AddNewModifier(caster, ability, "modifier_dw_bramble_damage", {Duration = self.duration})
		self:Destroy()
		break
	end

	self:StartIntervalThink(0.1)
end

function modifier_dw_bramble:OnRemoved()
	if IsServer() then
		StopSoundOn("Hero_DarkWillow.BrambleLoop", self:GetParent())
		EmitSoundOn("Hero_DarkWillow.Bramble.Destroy", self:GetParent())
	end
end

modifier_dw_bramble_damage = class({})
function modifier_dw_bramble_damage:OnCreated(table)
	if IsServer() then
		local caster = self:GetCaster()
		local parent = self:GetParent()

		EmitSoundOn("Hero_DarkWillow.Bramble.Target", self:GetParent())

		self.damage = self:GetTalentSpecialValueFor("damage") * 0.5

		local radius = self:GetTalentSpecialValueFor("latch_range")
		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_dark_willow/dark_willow_bramble.vpcf", PATTACH_POINT, caster)
					ParticleManager:SetParticleControlEnt(nfx, 0, parent, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
					ParticleManager:SetParticleControlEnt(nfx, 0, parent, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)

		self:AttachEffect(nfx)

		self:StartIntervalThink(0.5)
	end
end

function modifier_dw_bramble_damage:OnRefresh(table)
	if IsServer() then
		self.damage = self:GetTalentSpecialValueFor("damage") * 0.5
	end
end

function modifier_dw_bramble_damage:OnIntervalThink()
	if IsServer() then
		local caster = self:GetCaster()
		self.damage = self:GetTalentSpecialValueFor("damage") * 0.5
		
		if caster:HasTalent("special_bonus_unique_dw_bramble_1") then
			self:GetCaster():Lifesteal(self:GetAbility(), 30, self.damage, self:GetParent(), self:GetAbility():GetAbilityDamageType(), DOTA_LIFESTEAL_SOURCE_ABILITY, true)
		else
			self:GetAbility():DealDamage(self:GetCaster(), self:GetParent(), self.damage, {}, OVERHEAD_ALERT_BONUS_POISON_DAMAGE)
		end
	end
end

function modifier_dw_bramble_damage:IsDebuff()
	return true
end

function modifier_dw_bramble_damage:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_dw_bramble_damage:CheckState()
	return {[MODIFIER_STATE_ROOTED] = true,
			[MODIFIER_STATE_INVISIBLE] = false}
end