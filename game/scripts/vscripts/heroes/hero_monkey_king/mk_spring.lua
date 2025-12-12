mk_spring = class({})
LinkLuaModifier("modifier_mk_spring_slow", "heroes/hero_monkey_king/mk_spring", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mk_spring", "heroes/hero_monkey_king/mk_spring", LUA_MODIFIER_MOTION_NONE)

function mk_spring:IsStealable()
	return true
end

function mk_spring:IsHiddenWhenStolen()
	return false
end

function mk_spring:GetCooldown(iLvl)
    local cooldown = self.BaseClass.GetCooldown(self, iLvl)
    local caster = self:GetCaster()
    local talent = "special_bonus_unique_mk_spring_2"
    local value = caster:FindTalentValue( talent )
    if caster:HasTalent( talent ) then cooldown = cooldown + value end
    return cooldown
end

function mk_spring:GetCastRange(vLocation, hTarget)
	if self:GetCaster():HasModifier("modifier_mk_tree_perch") or self:GetCaster():HasTalent("special_bonus_unique_mk_spring_1") then
		return self:GetSpecialValueFor("max_distance")
	end
	return 375
end

function mk_spring:GetBehavior()
	if self:GetCaster():HasModifier("modifier_mk_tree_perch") or self:GetCaster():HasTalent("special_bonus_unique_mk_spring_1") then
		return DOTA_ABILITY_BEHAVIOR_POINT
	end
	return DOTA_ABILITY_BEHAVIOR_NO_TARGET
end

function mk_spring:GetCastAnimation()
	if self:GetCaster():HasModifier("modifier_mk_tree_perch") or self:GetCaster():HasTalent("special_bonus_unique_mk_spring_1") then
		return ACT_DOTA_CAST_ABILITY_2
	end
	return ACT_DOTA_MK_SPRING_END
end

function mk_spring:OnSpellStart()
	local caster = self:GetCaster()

	EmitSoundOn("Hero_MonkeyKing.Spring.Channel", caster)

	if caster:HasTalent("special_bonus_unique_mk_spring_1") then
		local point = self:GetCursorPosition()

		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_monkey_king/mk_spring_blone.vpcf", PATTACH_POINT, caster)
					ParticleManager:SetParticleControl(nfx, 0, point)

		Timers:CreateTimer(0.4, function()
			GridNav:DestroyTreesAroundPoint(point, self:GetSpecialValueFor("radius"), false)
			self:DoSpring(point)
			ParticleManager:ClearParticle(nfx)
		end)
	else
		if caster:HasModifier("modifier_mk_tree_perch") then
			caster:RemoveModifierByName("modifier_mk_tree_perch")
			caster:AddNewModifier(caster, self, "modifier_mk_spring", {Duration = 2})
		else
			local point = caster:GetAbsOrigin()
			self:DoSpring(point)
		end
	end
end

function mk_spring:DoSpring(vLocation)
	local caster = self:GetCaster()
	local point = vLocation

	local duration = self:GetSpecialValueFor("duration")
	local radius = self:GetSpecialValueFor("radius")
	local damage = self:GetSpecialValueFor("damage")

	EmitSoundOnLocationWithCaster(vLocation, "Hero_MonkeyKing.Spring.Impact", caster)

	local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_monkey_king/monkey_king_spring.vpcf", PATTACH_POINT, caster)
				ParticleManager:SetParticleControl(nfx, 0, point)
				ParticleManager:SetParticleControl(nfx, 1, Vector(radius, radius, radius))
				ParticleManager:ReleaseParticleIndex(nfx)

	if caster:HasTalent("special_bonus_unique_mk_spring_2") then
		local ability = caster:FindAbilityByName("mk_mastery")
		for i=1,2 do
			caster:AddNewModifier(caster, ability, "modifier_mk_mastery_hits", {Duration = ability:GetSpecialValueFor("max_duration")}):IncrementStackCount()
		end
	end

	local enemies = caster:FindEnemyUnitsInRadius(point, radius)
	for _,enemy in pairs(enemies) do
		if not enemy:TriggerSpellAbsorb(self) then
			EmitSoundOn("Hero_MonkeyKing.Spring.Target", enemy)
			enemy:AddNewModifier(caster, self, "modifier_mk_spring_slow", {Duration = duration})
			self:DealDamage(caster, enemy, damage, {}, 0)
		end
	end
end

modifier_mk_spring_slow = class({})
function modifier_mk_spring_slow:OnCreated(table)
	self.ms = self:GetSpecialValueFor("slow_ms")
end

function modifier_mk_spring_slow:OnRefresh(table)
	self.ms = self:GetSpecialValueFor("slow_ms")
end

function modifier_mk_spring_slow:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_mk_spring_slow:GetModifierMoveSpeedBonus_Percentage()
	return self.ms
end

function modifier_mk_spring_slow:GetEffectName()
	return "particles/units/heroes/hero_monkey_king/monkey_king_spring_slow.vpcf"
end

function modifier_mk_spring_slow:IsDebuff()
	return true
end


modifier_mk_spring = class({})

function modifier_mk_spring:OnCreated(table)
	if IsServer() then
		local caster = self:GetCaster()
		local ability = self:GetAbility()

		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_monkey_king/monkey_king_jump_trail.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
					ParticleManager:SetParticleControlEnt(nfx, 0, caster, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
		self:AttachEffect(nfx)

		self.speed = self:GetSpecialValueFor("leap_speed") * FrameTime()

		self.distance = CalculateDistance(ability:GetCursorPosition(), caster:GetAbsOrigin())
		self.direction = CalculateDirection(ability:GetCursorPosition(), caster:GetAbsOrigin())
		self.maxHeight = 192

		self.distanceTraveled = 0

		self:StartMotionController()
	end
end

function modifier_mk_spring:OnRefresh(table)
	if IsServer() then
		self.speed = self:GetSpecialValueFor("leap_speed") * FrameTime()
	end
end

function modifier_mk_spring:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION
    }

    return funcs
end

function modifier_mk_spring:GetOverrideAnimation()
	return ACT_DOTA_MK_SPRING_SOAR
end

function modifier_mk_spring:DoControlledMotion()
	if IsServer() then
		local parent = self:GetParent()
		local ability = self:GetAbility()

		if self.distanceTraveled < (self.distance - self.speed) then
			local newPos = GetGroundPosition(parent:GetAbsOrigin(), parent) + self.direction * self.speed
			local height = GetGroundHeight(parent:GetAbsOrigin(), parent)
			newPos.z = height + self.maxHeight * math.sin( (self.distanceTraveled/self.distance) * math.pi )
			parent:SetAbsOrigin( newPos )
			
			self.distanceTraveled = self.distanceTraveled + self.speed
		else
			self:GetAbility():DoSpring( self:GetParent():GetAbsOrigin() )

			self:Destroy()
			self:StopMotionController()
		end  
	end
end

function modifier_mk_spring:CheckState()
	return {[MODIFIER_STATE_STUNNED] = true}
end

function modifier_mk_spring:IsHidden()
	return false
end