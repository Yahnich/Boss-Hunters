elite_temporal = class({})

function elite_temporal:GetIntrinsicModifierName()
	return "modifier_elite_temporal"
end

function elite_temporal:OnSpellStart()
	local caster = self:GetCaster()
	local position = self:GetCursorPosition()
	CreateModifierThinker(caster, self, "modifier_elite_temporal_dummy", {duration = self:GetSpecialValueFor("bubble_duration")}, position, caster:GetTeam(), false)
end

modifier_elite_temporal = class(relicBaseClass)
LinkLuaModifier("modifier_elite_temporal", "elites/elite_temporal", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
	function modifier_elite_temporal:OnCreated()
		self.duration = self:GetSpecialValueFor("duration")
		self:StartIntervalThink(0.2)
	end
	
	function modifier_elite_temporal:OnIntervalThink()
		local caster = self:GetCaster()
		if caster:PassivesDisabled() or not caster:IsAlive() or caster:HasActiveAbility() then return end
		local ability = self:GetAbility()
		if not ability:IsFullyCastable() or #caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), 800 ) <= 0 then return end
		local position = caster:GetAbsOrigin() + ActualRandomVector(600, 150)
		ParticleManager:FireWarningParticle( position, self:GetSpecialValueFor("bubble_radius") )
		ability:CastSpell(position)
	end
end

function modifier_elite_temporal:GetEffectName()
	return "particles/units/elite_warning_special_overhead.vpcf"
end

function modifier_elite_temporal:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

modifier_elite_temporal_dummy = class({})
LinkLuaModifier("modifier_elite_temporal_dummy", "elites/elite_temporal", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
	function modifier_elite_temporal_dummy:OnCreated()
		self.radius = self:GetSpecialValueFor("bubble_radius")
		self.cd_per_sec = FrameTime() + self:GetSpecialValueFor("cd_increase_per_sec") * FrameTime()
		if IsServer() then
			self.bubbleFX = ParticleManager:CreateParticle("particles/units/heroes/hero_faceless_void/faceless_void_chronosphere.vpcf", PATTACH_ABSORIGIN, self:GetParent())
				ParticleManager:SetParticleControl(self.bubbleFX, 1, Vector(self.radius,self.radius,self.radius)) --radius
			self:StartIntervalThink(1)
		end
	end
	
	function modifier_elite_temporal_dummy:OnIntervalThink()
		local caster = self:GetCaster()
		local parent = self:GetParent()
		self:StartIntervalThink(0)
		for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( parent:GetAbsOrigin(), self.radius ) ) do
			for i = 0, 12 do
				local checkedAb = enemy:GetAbilityByIndex(i)
				if checkedAb  and not checkedAb:IsPassive() then
					if not checkedAb:IsCooldownReady() then
						local cd = checkedAb:GetCooldownTimeRemaining()
						checkedAb:EndCooldown()
						checkedAb:StartCooldown(cd + self.cd_per_sec)
					else
						checkedAb:StartCooldown(self.cd_per_sec)
					end
				end
			end
		end
	end
	
	function modifier_elite_temporal_dummy:OnDestroy()
		ParticleManager:ClearParticle(self.bubbleFX)
		self:GetParent():ForceKill(false)
	end
end
