juggernaut_mirror_blades = class({})

function juggernaut_mirror_blades:OnToggle()
	local caster = self:GetCaster()
	if self:GetToggleState() then
		caster:AddNewModifier(caster, self, "modifier_juggernaut_mirror_blades", {})
	else
		caster:RemoveModifierByName("modifier_juggernaut_mirror_blades")
	end
end

function juggernaut_mirror_blades:ShouldUseResources()
	return true
end

modifier_juggernaut_mirror_blades = class({})
LinkLuaModifier("modifier_juggernaut_mirror_blades", "heroes/hero_juggernaut/juggernaut_mirror_blades", LUA_MODIFIER_MOTION_NONE)

function modifier_juggernaut_mirror_blades:OnCreated()
	local caster = self:GetCaster()
	self.damage = self:GetTalentSpecialValueFor("damage")
	self.radius = self:GetTalentSpecialValueFor("radius")
	self.tick = self:GetTalentSpecialValueFor("damage_tick")
	self.cycleDur = self:GetTalentSpecialValueFor("cycle_duration")
	self.cost = self:GetTalentSpecialValueFor("active_momentum_cost")
	
	self.disarmed = not caster:HasTalent("special_bonus_unique_juggernaut_mirror_blades_2")

	self:MirrorBladeCycle()
	self:StartIntervalThink(self.tick)
	if IsServer() then
		caster:StartGesture(ACT_DOTA_OVERRIDE_ABILITY_1)
		self:MirrorBladeDamage(self.radius, self.damage)
		EmitSoundOn("Hero_Juggernaut.BladeFuryStart" , self:GetParent() )
		local spinFX = ParticleManager:CreateParticle("particles/units/heroes/hero_juggernaut/juggernaut_blade_fury.vpcf", PATTACH_POINT_FOLLOW, caster)
		ParticleManager:SetParticleControl(spinFX, 5, Vector(self.radius, 1, 1))
		self:AddEffect(spinFX)
	end
end

function modifier_juggernaut_mirror_blades:OnDestroy()
	if IsServer() then
		self:GetParent():RemoveGesture(ACT_DOTA_OVERRIDE_ABILITY_1)
		StopSoundOn("Hero_Juggernaut.BladeFuryStart" , self:GetParent() )
		EmitSoundOn("Hero_Juggernaut.BladeFuryStop" , self:GetParent() )
	end
end

function modifier_juggernaut_mirror_blades:OnIntervalThink()
	self.cycleDur = self.cycleDur - self.tick
	if self.cycleDur <= 0 then
		self.cycleDur = self:GetTalentSpecialValueFor("cycle_duration")
		self:MirrorBladeCycle()
	end
	if IsServer() then
		self:MirrorBladeDamage(self.radius, self.damage)
	end
end

function modifier_juggernaut_mirror_blades:MirrorBladeCycle()
	local caster = self:GetCaster()
	self:SetDuration( self.cycleDur + 0.1, true )
	self.momentumUsed = caster:AttemptDecrementMomentum( self.cost )
end

function modifier_juggernaut_mirror_blades:MirrorBladeDamage(radius, damage)
	local caster = self:GetCaster()
	for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), self.radius ) ) do
		self:GetAbility():DealDamage( caster, enemy, self.damage * self.tick )
		ParticleManager:FireParticle("particles/units/heroes/hero_juggernaut/juggernaut_blade_fury_tgt.vpcf", PATTACH_POINT_FOLLOW, enemy)
		EmitSoundOn("Hero_Juggernaut.BladeFury.Impact", enemy )
	end
	caster:SpendMana( self:GetAbility():GetManaCost(-1) * self.tick, self:GetAbility() )
end

function modifier_juggernaut_mirror_blades:DeclareFunctions()
	return {MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT}
end

function modifier_juggernaut_mirror_blades:GetModifierBaseAttackTimeConstant()
	if not self.disarmed then
		return 3
	end
end

function modifier_juggernaut_mirror_blades:CheckState()
	local state = {	[MODIFIER_STATE_DISARMED] = self.disarmed,
					[MODIFIER_STATE_MAGIC_IMMUNE] = self.momentumUsed}
	return state
end