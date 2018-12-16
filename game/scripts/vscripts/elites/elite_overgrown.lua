elite_overgrown = class({})

function elite_overgrown:GetIntrinsicModifierName()
	return "modifier_elite_overgrown"
end

modifier_elite_overgrown = class(relicBaseClass)
LinkLuaModifier("modifier_elite_overgrown", "elites/elite_overgrown", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
	function modifier_elite_overgrown:OnCreated()
		self.lifetime = self:GetSpecialValueFor("bramble_lifetime")
		self.delay = self:GetSpecialValueFor("bramble_rate")
		self:StartIntervalThink( 1 )
	end
	
	function modifier_elite_overgrown:OnRefresh()
		self.lifetime = self:GetSpecialValueFor("bramble_lifetime")
		self.delay = self:GetSpecialValueFor("bramble_rate")
	end
	
	function modifier_elite_overgrown:OnIntervalThink()
		local caster = self:GetCaster()
		if caster:PassivesDisabled() or not caster:IsAlive() then return end
		local ability = self:GetAbility()
		if not ability:IsFullyCastable() then return end
		if #caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), 800 ) <= 0 then return end
		
		self.lifetime = self:GetSpecialValueFor("bramble_lifetime")
		self.delay = self:GetSpecialValueFor("bramble_rate")
		
		EmitSoundOn("n_black_dragon.Fireball.Target", caster)
		self:StartIntervalThink( self.delay )
		CreateModifierThinker(caster, ability, "modifier_elite_overgrown_dummy", {Duration = self.lifetime}, caster:GetAbsOrigin() + ActualRandomVector(750, 150), caster:GetTeam(), false)
	end
end

modifier_elite_overgrown_dummy = class({})
LinkLuaModifier("modifier_elite_overgrown_dummy", "elites/elite_overgrown", LUA_MODIFIER_MOTION_NONE)

function modifier_elite_overgrown_dummy:OnCreated()
	if IsServer() then
		local  bramble = ParticleManager:CreateParticle("particles/units/heroes/hero_dark_willow/dark_willow_bramble.vpcf", PATTACH_ABSORIGIN, self:GetParent())
		self:AddEffect( bramble )
		self:StartIntervalThink(1)
	end
end

function modifier_elite_overgrown_dummy:OnIntervalThink()
	if not self.root or not self.radius then
		self.radius = self:GetSpecialValueFor("root_radius")
		self.root = self:GetSpecialValueFor("root_duration")
		self:StartIntervalThink(0.25)
	end
	local caster = self:GetCaster()
	local parent = self:GetParent()
	local ability = self:GetAbility()
	if not caster or caster:IsNull() then
		self:Destroy()
		return
	end
	for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( parent:GetAbsOrigin(), self.radius ) ) do
		enemy:AddNewModifier( caster, ability, "modifier_elite_overgrown_root", {duration = self.root} )
		self:Destroy()
		break
	end
end

function modifier_elite_overgrown_dummy:OnDestroy()
	if IsServer() then
		self:GetParent():ForceKill(false)
	end
end

modifier_elite_overgrown_root = class({})
LinkLuaModifier("modifier_elite_overgrown_root", "elites/elite_overgrown", LUA_MODIFIER_MOTION_NONE)

function modifier_elite_overgrown_root:CheckState()
	return {[MODIFIER_STATE_ROOTED] = true,
			[MODIFIER_STATE_DISARMED] = true,}
end

function modifier_elite_overgrown_root:GetEffectName()
	return "particles/units/heroes/hero_dark_willow/dark_willow_bramble.vpcf"
end
