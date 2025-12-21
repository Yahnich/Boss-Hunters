kunkka_mark_the_spot = class({})

function kunkka_mark_the_spot:IsStealable()
    return false
end

function kunkka_mark_the_spot:IsHiddenWhenStolen()
    return false
end

function kunkka_mark_the_spot:GetVectorTargetRange()
	return self:GetSpecialValueFor("ally_max_range")
end

function kunkka_mark_the_spot:GetAOERadius()
	return self:GetSpecialValueFor("aoe_enemy_radius")
end

function kunkka_mark_the_spot:GetBehavior()
	local behavior = DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_VECTOR_TARGETING + DOTA_ABILITY_BEHAVIOR_DONT_RESUME_MOVEMENT
	if self:GetAOERadius() > 0 then
		behavior = behavior + DOTA_ABILITY_BEHAVIOR_AOE + DOTA_ABILITY_BEHAVIOR_AUTOCAST
	end
	return behavior
end

function kunkka_mark_the_spot:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
	
	local delay = self:GetSpecialValueFor("mark_delay")
	target:AddNewModifier( caster, self, "modifier_kunkka_mark_the_spot", {duration = delay} )
	local radius = self:GetAOERadius()
	
	if radius > 0 and not target:IsSameTeam( caster ) and self:GetAutoCastState() then
		for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( target:GetAbsOrigin(), radius ) ) do
			if enemy ~= target then
				enemy:AddNewModifier( caster, self, "modifier_kunkka_mark_the_spot", {duration = delay} )
			end
		end
	end
end

function kunkka_mark_the_spot:OnProjectileHit( target, position )
	if target then
		local caster = self:GetCaster()
		self:DealDamage( caster, target, self:GetSpecialValueFor("wave_damage"), {damage_type = DAMAGE_TYPE_MAGICAL} )
	end
end

modifier_kunkka_mark_the_spot = class({})
LinkLuaModifier("modifier_kunkka_mark_the_spot", "heroes/hero_kunkka/kunkka_mark_the_spot", LUA_MODIFIER_MOTION_NONE)

function modifier_kunkka_mark_the_spot:OnCreated(table)
    if not IsServer() then return end
	self.evasion_duration = self:GetSpecialValueFor("evasion_duration")
	self.wave_width = self:GetSpecialValueFor("wave_width")
	self.wave_speed = self:GetSpecialValueFor("wave_speed")
	self.wave_distance = self:GetSpecialValueFor("wave_distance")
	
	local parent = self:GetParent()
	local caster = self:GetCaster()
	EmitSoundOn("Ability.XMark.Target_Movement", parent)
	local ability = self:GetAbility()
	local vectorPosition = ability:GetVector2Position()
	if parent ~= ability:GetCursorTarget() then vectorPosition = vectorPosition + ActualRandomVector( 128 ) end -- handle extra targets
	local clampedPosition = parent:GetAbsOrigin() + CalculateDirection( vectorPosition, parent ) * math.min( CalculateDistance( vectorPosition, parent ), TernaryOperator( self:GetSpecialValueFor("ally_max_range"), parent:IsSameTeam( caster ), self:GetSpecialValueFor("enemy_max_range") ) )
	self.startPos = GetGroundPosition(clampedPosition, parent)
	
	self._particleDummy = caster:CreateDummy( self.startPos, self:GetRemainingTime() )
	local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_kunkka/kunkka_spell_x_spot.vpcf", PATTACH_ABSORIGIN_FOLLOW, self._particleDummy )
	ParticleManager:SetParticleControlEnt(nfx, 0, self._particleDummy, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self._particleDummy:GetAbsOrigin(), true )
	self:AttachEffect(nfx)
	
	self:StartIntervalThink( 0 )
	
	if self.evasion_duration > 0 and parent:IsSameTeam( caster ) then
		parent:AddNewModifier( caster, ability, "modifier_kunkka_mark_the_spot_admiral", {duration = self.evasion_duration} )
	end
	ability:TriggerSpellEffect( parent )
end

function modifier_kunkka_mark_the_spot:OnIntervalThink()
	if not IsEntitySafe( self._particleDummy ) then return end
	local parent = self:GetParent()
	local newPos = self._particleDummy:GetAbsOrigin() + CalculateDirection( parent, self._particleDummy ) * CalculateDistance( parent, self._particleDummy ) * FrameTime() / self:GetRemainingTime()
	self._particleDummy:SetAbsOrigin( newPos )
	AddFOWViewer( self:GetCaster():GetTeam(), newPos, 256, self:GetRemainingTime(), false )
end

function modifier_kunkka_mark_the_spot:OnRemoved()
    if not IsServer() then return end
	local parent = self:GetParent()
	StopSoundOn("Ability.XMark.Target_Movement", parent)
	EmitSoundOn("Ability.XMarksTheSpot.Return", parent)
	
	FindClearSpaceForUnit(parent, self.startPos, true)
	ability:TriggerSpellEffect( parent )
	if self.wave_speed > 0 then
		local ability = self:GetAbility()
		local caster = self:GetCaster()
		local baseDirection = RotateVector2D( Vector( 0, 1, 0 ), ToRadians( 45 ) )
		for i = 1, 4 do
			local waveVelocity = RotateVector2D(  baseDirection, ToRadians( 90 * i ) )  * self.wave_speed
			ability:FireLinearProjectile("particles/units/heroes/hero_kunkka/kunkka_shard_tidal_wave.vpcf", waveVelocity, self.wave_distance, self.wave_width, {origin = parent:GetAbsOrigin()})
		end
	end
end

function modifier_kunkka_mark_the_spot:GetEffectName()
	return "particles/units/heroes/hero_kunkka/kunkka_mark_the_spot_overhead.vpcf"
end

function modifier_kunkka_mark_the_spot:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW 
end

modifier_kunkka_mark_the_spot_client = class(toggleModifierBaseClass)
LinkLuaModifier("modifier_kunkka_mark_the_spot_client", "heroes/hero_kunkka/kunkka_mark_the_spot", LUA_MODIFIER_MOTION_NONE)

function modifier_kunkka_mark_the_spot_client:IsHidden()
	return true
end

modifier_kunkka_mark_the_spot_admiral = class({})
LinkLuaModifier("modifier_kunkka_mark_the_spot_admiral", "heroes/hero_kunkka/kunkka_mark_the_spot", LUA_MODIFIER_MOTION_NONE)

function modifier_kunkka_mark_the_spot_admiral:OnCreated()
	self:OnRefresh()
end

function modifier_kunkka_mark_the_spot_admiral:OnRefresh()
	self.evasion_bonus = self:GetSpecialValueFor("evasion_bonus")
end

function modifier_kunkka_mark_the_spot_admiral:DeclareFunctions()
	return {MODIFIER_PROPERTY_EVASION_CONSTANT}
end

function modifier_kunkka_mark_the_spot_admiral:GetModifierEvasion_Constant()
	return self.evasion_bonus
end