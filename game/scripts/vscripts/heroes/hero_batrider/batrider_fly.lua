batrider_fly = class({})
LinkLuaModifier("modifier_batrider_fly", "heroes/hero_batrider/batrider_fly", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_batrider_fly_fire", "heroes/hero_batrider/batrider_fly", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_batrider_fly_fire_damage", "heroes/hero_batrider/batrider_fly", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_batrider_fly_movement", "heroes/hero_batrider/batrider_fly", LUA_MODIFIER_MOTION_NONE)

function batrider_fly:IsStealable()
    return true
end

function batrider_fly:IsHiddenWhenStolen()
    return false
end

function batrider_fly:OnSpellStart()
	local caster = self:GetCaster()

	EmitSoundOn("Hero_Batrider.Firefly.Cast", caster)

	caster:StartGesture(ACT_DOTA_CAST_ABILITY_3)

	if caster:HasTalent("special_bonus_unique_batrider_fly_2") then
		caster:AddNewModifier(caster, self, "modifier_batrider_fly_movement", {Duration = self:GetSpecialValueFor("duration")})
	end

	caster:AddNewModifier(caster, self, "modifier_batrider_fly", {Duration = self:GetSpecialValueFor("duration")})
end

modifier_batrider_fly = class({})
function modifier_batrider_fly:OnCreated(table)
	if self:GetCaster():HasTalent("special_bonus_unique_batrider_fly_1") then
		self.ms = self:GetCaster():FindTalentValue("special_bonus_unique_batrider_fly_1")
		self.evasion = self:GetCaster():FindTalentValue("special_bonus_unique_batrider_fly_1", "value2")
	end

	if IsServer() then
		local caster = self:GetCaster()
		local parent = self:GetParent()

		EmitSoundOn("Hero_Batrider.Firefly.loop", parent)

		self.pits = {}

		self.point = parent:GetAbsOrigin()
		self.radius = self:GetSpecialValueFor("radius")

		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_batrider/batrider_firefly.vpcf", PATTACH_POINT, caster)
					ParticleManager:SetParticleControlEnt(nfx, 0, parent, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
					ParticleManager:SetParticleControlEnt(nfx, 3, parent, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
					ParticleManager:SetParticleControl(nfx, 11, Vector(1, 0, 0))

		self:AttachEffect(nfx)

		self.tick = 0

		self:StartIntervalThink(0.5)
	end
end

function modifier_batrider_fly:OnIntervalThink()
	local caster = self:GetCaster()
	local parent = self:GetParent()

	if caster:HasScepter() then
		if self.tick >= 2 + 0.05 then
			local ability = caster:FindAbilityByName("batrider_flamebreak_bh")
			if ability and ability:IsTrained() then
				local pointRando = parent:GetAbsOrigin() + ActualRandomVector(ability:GetTrueCastRange(), caster:GetModelRadius() * 2)
				ability:TossCocktail(pointRando)
				self.tick = 0
			end
		else
			self.tick = self.tick + 0.05
		end
	end

	if CalculateDistance(self.point, parent:GetAbsOrigin()) >= self.radius*1.5 then
		GridNav:DestroyTreesAroundPoint(parent:GetAbsOrigin(), self.radius, false)

		local pit = CreateModifierThinker(caster, self:GetAbility(), "modifier_batrider_fly_fire", {Duration = self:GetSpecialValueFor("duration")}, parent:GetAbsOrigin(), parent:GetTeam(), false)
		table.insert(self.pits, pit)

		self.point = parent:GetAbsOrigin()
	end

	self:StartIntervalThink(0.05)
end

function modifier_batrider_fly:OnRemoved()
	if IsServer() then
		for _,pit in pairs(self.pits) do
			UTIL_Remove(pit)
		end

		StopSoundOn("Hero_Batrider.Firefly.loop", self:GetParent())

		self:GetParent():RemoveModifierByName("modifier_batrider_fly_movement")
	end
end

function modifier_batrider_fly:CheckState()
	return {[MODIFIER_STATE_FLYING] = true}
end

function modifier_batrider_fly:DeclareFunctions()
    return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
			MODIFIER_PROPERTY_EVASION_CONSTANT}
end

function modifier_batrider_fly:GetModifierMoveSpeedBonus_Percentage()
	return self.ms
end

function modifier_batrider_fly:GetModifierEvasion_Constant()
	return self.evasion
end

function modifier_batrider_fly:GetEffectName()
	return "particles/units/heroes/hero_batrider/batrider_firefly_ember.vpcf"
end

function modifier_batrider_fly:IsDebuff()
	return false
end

function modifier_batrider_fly:RemoveOnDeath()
    return false
end

function modifier_batrider_fly:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

modifier_batrider_fly_fire = class({})
function modifier_batrider_fly_fire:OnCreated(table)
    self.radius = self:GetSpecialValueFor("radius")

    --Debug stuff--
    --[[if IsServer() then
    	local parent = self:GetParent()
    	local point = parent:GetAbsOrigin()
    	local radius = self:GetSpecialValueFor("radius")
    	
    	local nfx = ParticleManager:CreateParticle("particles/econ/generic/generic_progress_meter/generic_progress_circle.vpcf", PATTACH_POINT, parent)
    				ParticleManager:SetParticleControl(nfx, 0, point)
    				ParticleManager:SetParticleControl(nfx, 1, Vector(radius, radius, radius))

    	self:AttachEffect(nfx)
    end]]
end

function modifier_batrider_fly_fire:IsAura()
    return true
end

function modifier_batrider_fly_fire:GetAuraDuration()
    return 0.5
end

function modifier_batrider_fly_fire:GetAuraRadius()
    return self.radius
end

function modifier_batrider_fly_fire:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_batrider_fly_fire:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_batrider_fly_fire:GetAuraSearchType()
    return DOTA_UNIT_TARGET_ALL
end

function modifier_batrider_fly_fire:GetModifierAura()
    return "modifier_batrider_fly_fire_damage"
end

function modifier_batrider_fly_fire:IsAuraActiveOnDeath()
    return false
end

function modifier_batrider_fly_fire:IsHidden()
    return true
end

modifier_batrider_fly_fire_damage = class({})
function modifier_batrider_fly_fire_damage:OnCreated(table)
	if IsServer() then
    	self.damage = self:GetSpecialValueFor("damage") * 0.5
    	self:StartIntervalThink(0.5)
    end
end

function modifier_batrider_fly_fire_damage:OnIntervalThink()
	ParticleManager:FireParticle("particles/units/heroes/hero_batrider/batrider_firefly_debuff.vpcf", PATTACH_POINT, self:GetParent(), {})
	self:GetAbility():DealDamage(self:GetCaster(), self:GetParent(), self.damage, {}, OVERHEAD_ALERT_DAMAGE)
end

function modifier_batrider_fly_fire_damage:IsHidden()
    return true
end

modifier_batrider_fly_movement = class({})
function modifier_batrider_fly_movement:OnCreated(table)
	if IsServer() then
    	self:StartIntervalThink(FrameTime())
    end
end

function modifier_batrider_fly_movement:OnIntervalThink()
	local parent = self:GetParent()

	local newpoint = GetGroundPosition(parent:GetAbsOrigin(), parent) + parent:GetForwardVector() * parent:GetIdealSpeedNoSlows() * FrameTime()
	parent:SetAbsOrigin(newpoint)
end

function modifier_batrider_fly_movement:CheckState()
	return {[MODIFIER_STATE_ROOTED] = true}
end

function modifier_batrider_fly_movement:DeclareFunctions()
    return {MODIFIER_PROPERTY_TURN_RATE_PERCENTAGE}
end

function modifier_batrider_fly_movement:GetModifierTurnRate_Percentage()
    return -50
end

function modifier_batrider_fly_movement:IsHidden()
    return true
end