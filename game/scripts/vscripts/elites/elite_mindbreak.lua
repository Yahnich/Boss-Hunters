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
	end
	
	function modifier_elite_mindbreak:OnIntervalThink()
		local caster = self:GetCaster()
		if caster:PassivesDisabled() or not caster:IsAlive() or caster:HasActiveAbility() then return end
		local ability = self:GetAbility()
		if not ability:IsFullyCastable() then return end
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
		self.duration = self:GetSpecialValueFor("silence_duration")
	end
	
	function modifier_elite_mindbreak_buff:OnDestroy()
		self.duration = self:GetSpecialValueFor("silence_duration")
	end
end

function modifier_elite_barrier:DeclareFunctions()
	return { MODIFIER_PROPERTY_ABSORB_SPELL }
end

function modifier_elite_barrier:GetAbsorbSpell(params)
	if not params.ability then return end
	if params.ability:GetCaster():GetTeam() ~= self:GetParent():GetTeam() then
		ParticleManager:FireParticle( "particles/items3_fx/lotus_orb_reflect.vpcf", PATTACH_POINT_FOLLOW, self:GetParent() )
		params.ability:GetCaster():Silence(self:GetAbility(), self:GetParent(), self.duration)
	end
end

function modifier_item_protection_sphere_block:OnAttackLanded(params)
	if params.target == self:GetParent() then
		params.ability:GetCaster():Silence(self:GetAbility(), params.target, self.duration)
	end
end

function modifier_elite_mindbreak_buff:GetEffectName()
	return "particles/items3_fx/lotus_orb_shield.vpcf"
end