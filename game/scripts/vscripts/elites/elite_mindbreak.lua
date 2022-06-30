elite_mindbreak = class({})

function elite_mindbreak:GetIntrinsicModifierName()
	return "modifier_elite_mindbreak"
end

function elite_mindbreak:OnSpellStart()
	local caster = self:GetCaster()
	
	caster:AddNewModifier(caster, self, "modifier_elite_mindbreak_buff", {duration = self:GetSpecialValueFor("duration")})
end

modifier_elite_mindbreak = class(relicBaseClass)
LinkLuaModifier("modifier_elite_mindbreak", "elites/elite_mindbreak", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
	function modifier_elite_mindbreak:OnCreated()
		self.duration = self:GetSpecialValueFor("duration")
		self:StartIntervalThink(0.2)
		self:AddEffect( ParticleManager:CreateParticle( "particles/units/elite_warning_defense_overhead.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent() ) )
	end
	
	function modifier_elite_mindbreak:OnIntervalThink()
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		if not ability:IsFullyCastable() or caster:IsStunned() or caster:IsSilenced() or caster:GetCurrentActiveAbility() or caster:IsHexed() then return end
		if #caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), 800 ) <= 0 then return end
		
		ability:CastSpell()
	end
end

function modifier_elite_mindbreak:IsHidden()
	return true
end

modifier_elite_mindbreak_buff = class({})
LinkLuaModifier("modifier_elite_mindbreak_buff", "elites/elite_mindbreak", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
	function modifier_elite_mindbreak_buff:OnCreated()
		self:OnRefresh()
	end
	
	function modifier_elite_mindbreak_buff:OnRefresh()
		self.duration = self:GetSpecialValueFor("silence_duration")
	end
end

function modifier_elite_mindbreak_buff:DeclareFunctions()
	return { MODIFIER_PROPERTY_ABSORB_SPELL }
end

function modifier_elite_mindbreak_buff:GetAbsorbSpell(params)
	if not params.ability then return end
	if params.ability:GetCaster():GetTeam() ~= self:GetParent():GetTeam() then
		ParticleManager:FireParticle( "particles/items3_fx/lotus_orb_reflect.vpcf", PATTACH_POINT_FOLLOW, self:GetParent() )
		params.ability:GetCaster():Silence(self:GetAbility(), self:GetParent(), self.duration)
	end
end

function modifier_elite_mindbreak_buff:GetEffectName()
	return "particles/items3_fx/lotus_orb_shield.vpcf"
end