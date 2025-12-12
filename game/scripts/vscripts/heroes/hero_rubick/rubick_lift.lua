rubick_lift = class({})
LinkLuaModifier("modifier_rubick_lift", "heroes/hero_rubick/rubick_lift", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_rubick_lift_ally", "heroes/hero_rubick/rubick_lift", LUA_MODIFIER_MOTION_NONE)

function rubick_lift:IsStealable()
    return false
end

function rubick_lift:IsHiddenWhenStolen()
    return false
end

function rubick_lift:CastFilterResultTarget(hTarget)
	if hTarget and hTarget:GetTeamNumber() == self:GetCaster():GetTeamNumber() then 
	    if self:GetCaster():HasTalent("special_bonus_unique_rubick_lift_1") then
	    	return UF_SUCCESS
	    else
	    	return UF_FAIL_FRIENDLY
	    end
	else
    	return UF_SUCCESS
    end
end

function rubick_lift:GetCooldown(iLvl)
    local cooldown = self.BaseClass.GetCooldown(self, iLvl)
    local caster = self:GetCaster()
    local talent = "special_bonus_unique_rubick_lift_1"
    if caster:HasTalent( talent ) then cooldown = cooldown + caster:FindTalentValue( talent ) end
    return cooldown
end

function rubick_lift:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	local lift_duration = self:GetSpecialValueFor("lift_duration")
	
	EmitSoundOn("Hero_Rubick.Telekinesis.Cast", caster)
	EmitSoundOn("Hero_Rubick.Telekinesis.Target", target)
	if target:TriggerSpellAbsorb( self ) then return end
	target:AddNewModifier(caster, self, "modifier_rubick_lift", {Duration = lift_duration})

	if target:GetTeam() == caster:GetTeam() then
		target:AddNewModifier(caster, self, "modifier_invulnerable", {Duration = lift_duration})
	end

	self:StartDelayedCooldown(lift_duration + self:GetSpecialValueFor("stun_duration"))
end

modifier_rubick_lift = class({})
function modifier_rubick_lift:OnCreated(table)
	if IsServer() then
		local caster = self:GetCaster()
		local parent = self:GetParent()

		self:SetDuration(self:GetSpecialValueFor("lift_duration"), true)

		self.nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_rubick/rubick_telekinesis.vpcf", PATTACH_POINT, caster)
					ParticleManager:SetParticleControlEnt(self.nfx, 0, parent, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
					ParticleManager:SetParticleControlEnt(self.nfx, 1, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
					ParticleManager:SetParticleControl(self.nfx, 2, Vector(self:GetDuration(), 0, 0))
		self:AttachEffect(self.nfx)

		self.stun_duration = self:GetSpecialValueFor("stun_duration")
		self.z_height = 0
		self.maxHeight = 200
		self.duration = self:GetDuration()
		self.lift_animation = self:GetSpecialValueFor("lift_duration")/2
		self.fall_animation = 0.1
		self.current_time = 0

		self:StartIntervalThink(FrameTime())
	end
end

function modifier_rubick_lift:OnRefresh(table)
	self.stun_duration = self:GetSpecialValueFor("stun_duration")
end

function modifier_rubick_lift:OnIntervalThink()
	local parent = self:GetParent()
	self.current_time = self.current_time + FrameTime()

	self.duration = self:GetDuration()
	ParticleManager:SetParticleControl(self.nfx, 2, Vector(self.duration, 0, 0))

	if self.current_time <= self.lift_animation  then
		self.z_height = self.z_height + ((FrameTime() / self.lift_animation) * self.maxHeight)
		parent:SetAbsOrigin(GetGroundPosition(parent:GetAbsOrigin(), parent) + Vector(0,0,self.z_height))
	elseif self.current_time > (self.duration - self.fall_animation) then
		self.z_height = self.z_height - ((FrameTime() / self.fall_animation) * self.maxHeight)
		if self.z_height < 0 then self.z_height = 0 end
		parent:SetAbsOrigin(GetGroundPosition(parent:GetAbsOrigin(), parent) + Vector(0,0,self.z_height))
	else
		self.maxHeight = self.z_height
	end
end

function modifier_rubick_lift:DeclareFunctions()
	local funcs = { MODIFIER_PROPERTY_OVERRIDE_ANIMATION}
	return funcs
end

function modifier_rubick_lift:GetOverrideAnimation()
	return ACT_DOTA_FLAIL
end

function modifier_rubick_lift:OnRemoved()
	if IsServer() then
		local caster = self:GetCaster()
		local point = self:GetParent():GetAbsOrigin()
		local damage = 0

		local radius = self:GetSpecialValueFor("radius")

		EmitSoundOn("Hero_Rubick.Telekinesis.Target.Land", self:GetParent())

		ParticleManager:FireParticle("particles/units/heroes/hero_rubick/rubick_telekinesis_land.vpcf", PATTACH_POINT, caster, {[0]=point})

		GridNav:DestroyTreesAroundPoint(point, radius, false)

		if caster:HasTalent("special_bonus_unique_rubick_lift_2") then
			damage = caster:GetIntellect( false)
		end

		local enemies = caster:FindEnemyUnitsInRadius(point, radius)
		for _,enemy in pairs(enemies) do
			EmitSoundOn("Hero_Rubick.Telekinesis.Stun", self:GetParent())
			self:GetAbility():Stun(enemy, self.stun_duration, false)
			self:GetAbility():DealDamage(caster, enemy, damage, {damage_type = DAMAGE_TYPE_MAGICAL}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
		end
	end
end

function modifier_rubick_lift:CheckState()
	return {[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
			[MODIFIER_STATE_STUNNED] = true}
end

function modifier_rubick_lift:IsDebuff()
	return true
end

function modifier_rubick_lift:IsPurgable()
	return true
end