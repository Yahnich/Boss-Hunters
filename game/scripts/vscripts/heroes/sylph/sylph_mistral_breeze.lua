sylph_mistral_breeze = sylph_mistral_breeze or class({})

function sylph_mistral_breeze:OnSpellStart()
	local direction = (self:GetCursorPosition() - self:GetCaster():GetAbsOrigin()):Normalized() * Vector(1,1,0)
	EmitSoundOn("Hero_Windrunner.Powershot.FalconBow", self:GetCaster())
	local projectileTable = {
        Ability = self,
        EffectName = "particles/heroes/sylph/sylph_mistral_breeze.vpcf",
        vSpawnOrigin = self:GetCaster():GetAbsOrigin(),
        fDistance = self:GetSpecialValueFor("projectile_distance"),
        fStartRadius = self:GetSpecialValueFor("projectile_radius"),
        fEndRadius = self:GetSpecialValueFor("projectile_radius"),
        Source = self:GetCaster(),
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        bDeleteOnHit = false,
        vVelocity = direction * self:GetSpecialValueFor("projectile_speed"),
		ExtraData = {originPointx = self:GetCaster():GetAbsOrigin().x, originPointy = self:GetCaster():GetAbsOrigin().y}
    }
    ProjectileManager:CreateLinearProjectile( projectileTable )
end

function sylph_mistral_breeze:OnProjectileHit_ExtraData( hTarget, vLocation, extraData )
	if hTarget ~= nil and ( not hTarget:IsMagicImmune() ) and ( not hTarget:IsInvulnerable() ) then
		local caster = self:GetCaster()
		local damage = {
			victim = hTarget,
			attacker = caster,
			damage = self:GetSpecialValueFor("projectile_damage") +  caster:GetIdealSpeed() * self:GetSpecialValueFor("ms_damage") / 100,
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self}
		ApplyDamage( damage )
		EmitSoundOn("Hero_Windrunner.PowershotDamage", hTarget)
		local originPoint = Vector(extraData.originPointx, extraData.originPointy)
		local directionVector = vLocation - originPoint -- Original vectors
		local rotateVector = Vector(directionVector.y, -directionVector.x, 0) -- Normal vector
		local compareVector = hTarget:GetAbsOrigin() - originPoint -- Comparative vector
		local sideResult = rotateVector:Dot(compareVector)
		local pushDir = (hTarget:GetAbsOrigin() - caster:GetAbsOrigin())
		local distanceCap = (self:GetSpecialValueFor("projectile_distance") - directionVector:Length2D()) / self:GetSpecialValueFor("projectile_distance")
		if (hTarget:GetAbsOrigin() - caster:GetAbsOrigin()):Length2D() > 450 or sideResult ~= 0 then
			if sideResult > 0 then
				pushDir = Vector(directionVector.y, -directionVector.x, 0)
			else
				pushDir = Vector(-directionVector.y, directionVector.x, 0)
			end
		else
			distanceCap = distanceCap * 1.5
		end
		pushDir = pushDir:Normalized()
			
		hTarget:AddNewModifier(caster, self, "modifier_sylph_mistral_breeze_knockback", {pushMod = distanceCap, pushDirx = pushDir.x, pushDiry = pushDir.y})
		hTarget:AddNewModifier(caster, self, "modifier_sylph_mistral_breeze_blind", {duration = self:GetSpecialValueFor("blind_duration")})
		if caster:HasTalent("sylph_mistral_breeze_talent_1") then
			caster:AddNewModifier(caster, self, "modifier_sylph_mistral_breeze_talent_buff", {duration = caster:FindSpecificTalentValue("sylph_immaterialize_talent_1", "duration")})
		end
	end
	return false
end

LinkLuaModifier( "modifier_sylph_mistral_breeze_knockback", "heroes/sylph/sylph_mistral_breeze.lua", LUA_MODIFIER_MOTION_NONE )
modifier_sylph_mistral_breeze_knockback = modifier_sylph_mistral_breeze_knockback or class({})

function modifier_sylph_mistral_breeze_knockback:OnCreated(kv)
	if IsServer() then
		self.parent = self:GetParent()
		EmitSoundOn("Hero_Tiny.Toss.Target", self:GetParent())
		self.max_distance = self:GetAbility():GetSpecialValueFor("max_push")
		self.distance_to_travel = self.max_distance * kv.pushMod
		self.pushDir = Vector(tonumber(kv.pushDirx), tonumber(kv.pushDiry), 0)
		if self.distance_to_travel < self:GetAbility():GetSpecialValueFor("min_push") then self.distance_to_travel = self:GetAbility():GetSpecialValueFor("min_push") end
		self.distance = 0
		self.speed = self:GetAbility():GetSpecialValueFor("knockback_speed")
		if self.parent:HasMovementCapability() then
			self:StartMotionController()
		end
	end
end

function modifier_sylph_mistral_breeze_knockback:OnRefresh(kv)
	if IsServer() then
		EmitSoundOn("Hero_Tiny.Toss.Target", self:GetParent())
		self.max_distance = self:GetAbility():GetSpecialValueFor("max_push")
		self.distance_to_travel = self.max_distance * kv.pushMod
		self.pushDir = Vector(tonumber(kv.pushDirx), tonumber(kv.pushDiry), 0)
		if self.distance_to_travel < self:GetAbility():GetSpecialValueFor("min_push") then self.distance_to_travel = self:GetAbility():GetSpecialValueFor("min_push") end
		self.distance = 0
		self.speed = self:GetAbility():GetSpecialValueFor("knockback_speed")
	end
end

function modifier_sylph_mistral_breeze_knockback:DoControlledMotion()
	local parent = self.parent
	if self.distance < self.distance_to_travel and self:GetParent():IsAlive() and not self:GetParent():IsNull() then
		parent:SetAbsOrigin(parent:GetAbsOrigin() + self.pushDir * self.speed*FrameTime())
		self.distance = self.distance + self.speed*FrameTime()
	else
		FindClearSpaceForUnit(parent, parent:GetAbsOrigin(), true)
		self:Destroy()
		return nil
	end       
end

function modifier_sylph_mistral_breeze_knockback:IsHidden()
	return true
end

function modifier_sylph_mistral_breeze_knockback:GetEffectName()
	return "particles/econ/items/windrunner/windrunner_cape_sparrowhawk/windrunner_windrun_sparrowhawk.vpcf"
end

function modifier_sylph_mistral_breeze_knockback:CheckState()
	local state = {[MODIFIER_STATE_STUNNED] = true}
	return state
end

function modifier_sylph_mistral_breeze_knockback:IsPurgable()
	return false
end

LinkLuaModifier( "modifier_sylph_mistral_breeze_blind", "heroes/sylph/sylph_mistral_breeze.lua", LUA_MODIFIER_MOTION_NONE )
modifier_sylph_mistral_breeze_blind = modifier_sylph_mistral_breeze_blind or class({})

function modifier_sylph_mistral_breeze_blind:OnCreated()
	self.blind = self:GetAbility():GetSpecialValueFor("blind_pct")
end

function modifier_sylph_mistral_breeze_blind:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MISS_PERCENTAGE,
	}
	return funcs
end

function modifier_sylph_mistral_breeze_blind:GetModifierMiss_Percentage()
	return self.blind
end

function modifier_sylph_mistral_breeze_blind:GetEffectName()
	return "particles/units/heroes/hero_keeper_of_the_light/keeper_of_the_light_blinding_light_debuff.vpcf"
end

LinkLuaModifier( "modifier_sylph_mistral_breeze_talent_buff", "heroes/sylph/sylph_mistral_breeze.lua", LUA_MODIFIER_MOTION_NONE )
modifier_sylph_mistral_breeze_talent_buff = class({})

function modifier_sylph_mistral_breeze_talent_buff:OnCreated()
	self.speed = self:GetCaster():FindTalentValue("sylph_mistral_breeze_talent_1")
	print(self.speed)
end

function modifier_sylph_mistral_breeze_talent_buff:OnRefresh()
	self:IncrementStackCount()
end

function modifier_sylph_mistral_breeze_talent_buff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
	return funcs
end

function modifier_sylph_mistral_breeze_talent_buff:GetModifierMoveSpeedBonus_Percentage()
	return self.speed * self:GetStackCount()
end

function modifier_sylph_mistral_breeze_talent_buff:GetEffectName()
	return "particles/econ/items/windrunner/windrunner_cape_sparrowhawk/windrunner_windrun_sparrowhawk.vpcf"
end

LinkLuaModifier( "modifier_sylph_mistral_breeze_talent_1", "heroes/sylph/sylph_mistral_breeze.lua", LUA_MODIFIER_MOTION_NONE )
modifier_sylph_mistral_breeze_talent_1 = modifier_sylph_mistral_breeze_talent_1 or class({})

function modifier_sylph_mistral_breeze_talent_1:IsHidden()
	return true
end

function modifier_sylph_mistral_breeze_talent_1:RemoveOnDeath()
	return false
end