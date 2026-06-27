spectre_echo_step = class({})

function spectre_echo_step:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	
	local duration = self:GetSpecialValueFor("duration")
	local bonus_damage = self:GetSpecialValueFor("bonus_damage")
	
	local echo = caster:CreateEcho( caster:GetAbsOrigin(), {target = target, duration = duration, bonus_damage_dealt = bonus_damage} )
	echo:AddNewModifier( caster, self, "modifier_spectre_echo_step_chase", {duration = duration} )
end

modifier_spectre_echo_step_chase = class({})
LinkLuaModifier("modifier_spectre_echo_step_chase", "heroes/hero_spectre/spectre_echo_step", LUA_MODIFIER_MOTION_NONE)

function modifier_spectre_echo_step_chase:OnCreated()
	self.bonus_move_speed_illusion_pct = -self:GetSpecialValueFor("bonus_move_speed_illusion_pct")
	self.shadow_path_walk = -self:GetSpecialValueFor("shadow_path_walk") == 1
	
	if IsServer() and self.shadow_path_walk then
		self:StartIntervalThink(0.15)
		local pathFX = ParticleManager:CreateParticle("particles/units/heroes/hero_spectre/spectre_shadow_path.vpcf", PATTACH_POINT_FOLLOW, self:GetParent() )
		ParticleManager:SetParticleControlEnt(pathFX, 3, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		ParticleManager:SetParticleControl( pathFX, 5, Vector(self.duration, 0, 0) )
		self:AddEffect(pathFX)
	end
end

function modifier_spectre_echo_step_chase:OnIntervalThink()
	local caster = self:GetCaster()
	caster:CreateShadowPath( self:GetParent():GetAbsOrigin(), {ability = self:GetAbility()} )
end

function modifier_spectre_echo_step_chase:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_spectre_echo_step_chase:GetModifierMoveSpeedBonus_Percentage()    
	return self.bonus_move_speed_illusion_pct
end