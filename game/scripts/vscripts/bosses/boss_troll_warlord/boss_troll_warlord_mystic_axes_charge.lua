boss_troll_warlord_mystic_axes_charge = class({})
LinkLuaModifier( "modifier_boss_troll_warlord_mystic_axes_charge", "bosses/boss_troll_warlord/boss_troll_warlord_mystic_axes_charge.lua" ,LUA_MODIFIER_MOTION_NONE )

function boss_troll_warlord_mystic_axes_charge:OnAbilityPhaseStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local start = caster:GetAbsOrigin()
	local distance = self:GetTalentSpecialValueFor("range")
	self.direction = CalculateDirection(target, caster)

	EmitSoundOn("Ability.AssassinateLoad", self:GetCaster())
	ParticleManager:FireLinearWarningParticle(start, start + self.direction * distance, self:GetTalentSpecialValueFor("radius"))
	return true
end

function boss_troll_warlord_mystic_axes_charge:OnSpellStart()
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_boss_troll_warlord_mystic_axes_charge", {})
end

modifier_boss_troll_warlord_mystic_axes_charge = class({})
function modifier_boss_troll_warlord_mystic_axes_charge:OnCreated(table)
	if IsServer() then
		local parent = self:GetParent()
		local start = parent:GetAbsOrigin()
		self.distance = self:GetSpecialValueFor("range")
		local endPoint = start + parent:GetForwardVector() * self.distance
		self.dir = self:GetAbility().direction

		self:StartMotionController()
	end
end

function modifier_boss_troll_warlord_mystic_axes_charge:DoControlledMotion()
	local parent = self:GetParent()
	local speed = self:GetSpecialValueFor("speed")*FrameTime()
	if self.distance > 0 then
		self.distance = self.distance - speed
		GridNav:DestroyTreesAroundPoint(parent:GetAbsOrigin(), self:GetTalentSpecialValueFor("radius"), true)
		parent:SetAbsOrigin(GetGroundPosition(parent:GetAbsOrigin(), parent) + self.dir*speed)
	else
		FindClearSpaceForUnit(parent, parent:GetAbsOrigin(), false)
		self:StopMotionController(true)
	end
end

function modifier_boss_troll_warlord_mystic_axes_charge:CheckState()
	local state = { [MODIFIER_STATE_STUNNED] = true}
	return state
end