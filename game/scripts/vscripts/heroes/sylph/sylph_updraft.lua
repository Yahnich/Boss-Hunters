sylph_updraft = sylph_updraft or class({})

function sylph_updraft:GetAOERadius()
	return self:GetSpecialValueFor("grab_radius")
end

function sylph_updraft:OnSpellStart()
	local caster = self:GetCaster()
	self.targetPosition = self:GetCursorPosition()
	local enemies = FindUnitsInRadius(caster:GetTeam(), self.targetPosition, nil, self:GetSpecialValueFor("grab_radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, FIND_ANY_ORDER, false)
	for _, enemy in pairs(enemies) do
		enemy:AddNewModifier(caster, self, "modifier_sylph_updraft_lift", {duration = self:GetSpecialValueFor("lift_duration")})
	end
	if #enemies > 0 then EmitSoundOn("DOTA_Item.Cyclone.Activate", caster) end
end

LinkLuaModifier( "modifier_sylph_updraft_lift", "heroes/sylph/sylph_updraft.lua", LUA_MODIFIER_MOTION_NONE )
modifier_sylph_updraft_lift = modifier_sylph_updraft_lift or class({})

if IsServer() then
	function modifier_sylph_updraft_lift:OnRemoved()
		self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_sylph_updraft_smash", {duration = self:GetAbility():GetSpecialValueFor("fall_duration")})
		self:GetParent():SetAngularVelocity(0, 0, 0)
	end

	function modifier_sylph_updraft_lift:OnCreated()
		self:GetParent():SetAngularVelocity(90,90, 90)
	end
end

function modifier_sylph_updraft_lift:GetEffectName()
	return "particles/econ/events/fall_major_2016/cyclone_fm06.vpcf"
end

function modifier_sylph_updraft_lift:GetEffectAttachType()
	return PATTACH_ABSORIGIN
end



function modifier_sylph_updraft_lift:CheckState()
	local state = { [MODIFIER_STATE_STUNNED] = true,
					[MODIFIER_STATE_FLYING] = true}
	return state
end

function modifier_sylph_updraft_lift:IsPurgable()
	return false
end


LinkLuaModifier( "modifier_sylph_updraft_smash", "heroes/sylph/sylph_updraft.lua", LUA_MODIFIER_MOTION_NONE )
modifier_sylph_updraft_smash = modifier_sylph_updraft_smash or class({})

function modifier_sylph_updraft_smash:OnCreated(kv)
	if IsServer() then
		self.parent = self:GetParent()
		self.targetPosition = self:GetAbility().targetPosition
		self.direction = (self.targetPosition- self.parent:GetAbsOrigin()):Normalized()
		self.fall_distance = (self.parent:GetAbsOrigin() - self.targetPosition):Length2D()
		self.fall_duration = self:GetAbility():GetSpecialValueFor("fall_duration")
		self.fall_speed = self.fall_distance / self.fall_duration
		self:StartMotionController()
	end
end

function modifier_sylph_updraft_smash:OnRefresh(kv)
	if IsServer() then
		self.parent = self:GetParent()
		self.targetPosition = self:GetAbility().targetPosition
		self.direction = (self.targetPosition- self.parent:GetAbsOrigin()):Normalized()
		self.fall_distance = (self.parent:GetAbsOrigin() - self.targetPosition):Length2D()
		self.fall_duration = self:GetAbility():GetSpecialValueFor("fall_duration")
	end
end

function modifier_sylph_updraft_smash:OnDestroy()
	if IsServer() then
		local damage = {
			victim = self.parent,
			attacker = self:GetCaster(),
			damage = self:GetAbility():GetSpecialValueFor("smash_damage"),
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self:GetAbility()}
		ApplyDamage( damage )
		EmitSoundOn("Hero_Rubick.Telekinesis.Target.Land", self:GetParent())
		if self:GetCaster():HasTalent("sylph_updraft_talent_1") then
			self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_stunned_generic", {duration = self:GetAbility():GetSpecialValueFor("talent_stun_duration")})
		end
	end
end

function modifier_sylph_updraft_smash:DoControlledMotion()
	local parent = self.parent
	if (self.parent:GetAbsOrigin() - self.targetPosition):Length2D() > 1 and self:GetParent():IsAlive() and not self:GetParent():IsNull() then
		parent:SetAbsOrigin(parent:GetAbsOrigin() + self.direction * self.fall_speed*FrameTime())
	else
		FindClearSpaceForUnit(parent, parent:GetAbsOrigin(), true)
		self:Destroy()
		return nil
	end       
end

function modifier_sylph_updraft_smash:IsHidden()
	return true
end

function modifier_sylph_updraft_smash:GetEffectName()
	return "particles/units/heroes/hero_tiny/tiny_toss_blur.vpcf"
end

function modifier_sylph_updraft_smash:CheckState()
	local state = {[MODIFIER_STATE_STUNNED] = true}
	return state
end

function modifier_sylph_updraft_smash:IsPurgable()
	return false
end


LinkLuaModifier( "modifier_sylph_updraft_talent_1", "heroes/sylph/sylph_updraft.lua", LUA_MODIFIER_MOTION_NONE )
modifier_sylph_updraft_talent_1 = modifier_sylph_updraft_talent_1 or class({})

function modifier_sylph_updraft_talent_1:IsHidden()
	return true
end

function modifier_sylph_updraft_talent_1:RemoveOnDeath()
	return false
end