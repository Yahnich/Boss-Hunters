elite_massive = class({})

function elite_massive:OnSpellStart()
	local caster = self:GetCaster()
	caster:AddNewModifier( caster, self, "modifier_elite_massive_buff", {duration = self:GetSpecialValueFor("duration")})
end

function elite_massive:GetIntrinsicModifierName()
	return "modifier_elite_massive"
end

modifier_elite_massive = class(relicBaseClass)
LinkLuaModifier("modifier_elite_massive", "elites/elite_massive", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
	function modifier_elite_massive:OnCreated()
		self:StartIntervalThink(1)
		self:AddEffect( ParticleManager:CreateParticle( "particles/units/elite_warning_special_overhead.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent() ) )
	end
	
	function modifier_elite_massive:OnIntervalThink()
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		if not ability:IsFullyCastable() or caster:IsStunned() or caster:IsSilenced() or caster:GetCurrentActiveAbility() or caster:IsHexed() or caster:IsRooted() then return end
		ability:CastSpell()
	end
end

modifier_elite_massive_buff = class({})
LinkLuaModifier("modifier_elite_massive_buff", "elites/elite_massive", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
	function modifier_elite_massive_buff:OnCreated()
		self.pull = self:GetSpecialValueFor("pull_strength") * FrameTime()
		self.radius = self:GetSpecialValueFor("radius")
		self:StartIntervalThink(0)
	end
	
	function modifier_elite_massive_buff:OnIntervalThink()
		local caster = self:GetCaster()
		local pullPosition = caster:GetAbsOrigin()
		for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( pullPosition, self.radius ) ) do
			local enemyPos = enemy:GetAbsOrigin()
			local direction = CalculateDirection( pullPosition, enemyPos )
			enemy:SetAbsOrigin( enemyPos + direction * self.pull )
		end
		
		ResolveNPCPositions(pullPosition, self.radius + 25)
	end
	
	function modifier_elite_massive_buff:OnDestroy()
		ResolveNPCPositions(self:GetCaster():GetAbsOrigin(), self.radius + 25)
	end
end

function modifier_elite_massive_buff:GetEffectName()
	return "particles/units/unit_greevil/greevil_blackhole.vpcf"
end