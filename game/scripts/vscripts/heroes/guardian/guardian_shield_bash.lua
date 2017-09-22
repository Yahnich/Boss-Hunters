guardian_shield_bash = class({})

function guardian_shield_bash:OnSpellStart()
	local caster = self:GetCaster()
	
	local startPoint = caster:GetAbsOrigin()
	local direction = CalculateDirection(self:GetCursorPosition(), startPoint) * Vector(1,1,0)
	local endPoint = caster:GetAbsOrigin() + direction * 250
	local targets = FindUnitsInLine( caster:GetTeam(), caster:GetAbsOrigin(), endPoint, nil, 200, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 0 ) 
	
	local orthDir = Vector(direction.y, -direction.x, 0)
	EmitSoundOn("Hero_DragonKnight.DragonTail.Target", caster)
	ParticleManager:FireParticle("particles/heroes/guardian/guardian_shield_smash.vpcf", PATTACH_POINT_FOLLOW, caster, {[2] = startPoint - orthDir * 100 + Vector(0,0,250),
																												  [3] = direction,
																												  [4] = startPoint + orthDir * 100  + Vector(0,0,250)})
	
	local distance = self:GetTalentSpecialValueFor("knockback")
	local damage = self:GetTalentSpecialValueFor("damage")
	
	for _, target in ipairs(targets) do
		if caster:HasTalent("guardian_shield_bash_talent_1") then
			target:AddNewModifier(caster, self, "modifier_guardian_shield_bash_talent", {duration = caster:FindTalentValue("guardian_shield_bash_talent_1")})
		end
		target.isInKnockbackState = true
		local distance_traveled = 0
		local distAdded = (distance/0.2)*FrameTime()
		self:DealDamage(caster, target, damage)
		StartAnimation(target, {activity = ACT_DOTA_FLAIL, rate = 1, duration = 0.2})
		target:AddNewModifier(caster, self, "modifier_stunned_generic", {duration = 0.2})
		Timers:CreateTimer(function ()
			if distance_traveled < distance and target:IsAlive() and not target:IsNull() and self:GetParent():HasMovementCapability() then
				target:SetAbsOrigin(target:GetAbsOrigin() + direction * distAdded)
				distance_traveled = distance_traveled + distAdded
				return FrameTime()
			else
				target:AddNewModifier(caster, self, "modifier_stunned_generic", {duration = self:GetTalentSpecialValueFor("stun_duration")})
				FindClearSpaceForUnit(target, target:GetAbsOrigin(), true)
				target.isInKnockbackState = false
				return nil
			end 
		end)
	end
end

modifier_guardian_shield_bash_talent = class({})
LinkLuaModifier("modifier_guardian_shield_bash_talent", "heroes/guardian/guardian_shield_bash.lua", 0)

function modifier_guardian_shield_bash_talent:OnCreated()
	self.reduction = self:GetAbility():GetTalentSpecialValueFor("talent_damage_reduction")
end

function modifier_guardian_shield_bash_talent:OnRefresh()
	self.reduction = self:GetAbility():GetTalentSpecialValueFor("talent_damage_reduction")
end

function modifier_guardian_shield_bash_talent:DeclareFunctions()
	return {MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE }
end

function modifier_guardian_shield_bash_talent:GetModifierBaseDamageOutgoing_Percentage()
	return self.reduction
end