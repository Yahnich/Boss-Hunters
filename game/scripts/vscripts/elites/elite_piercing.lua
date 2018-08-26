elite_piercing = class({})

function elite_piercing:GetIntrinsicModifierName()
	return "modifier_elite_piercing"
end

function elite_piercing:OnSpellStart()
	local caster = self:GetCaster()
	
	caster:AddNewModifier(caster, self, "modifier_elite_piercing_buff", {})
end

modifier_elite_piercing = class(relicBaseClass)
LinkLuaModifier("modifier_elite_piercing", "elites/elite_piercing", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
	function modifier_elite_piercing:OnCreated()
		self:StartIntervalThink(0.2)
	end
	
	function modifier_elite_piercing:OnIntervalThink()
		local caster = self:GetCaster()
		if caster:PassivesDisabled() or not caster:IsAlive() or not caster:IsAttacking() then return end
		local ability = self:GetAbility()
		if not ability:IsFullyCastable() then return end
		
		ability:CastSpell()
	end
end


modifier_elite_piercing_buff = class({})
LinkLuaModifier("modifier_elite_piercing_buff", "elites/elite_piercing", LUA_MODIFIER_MOTION_NONE)

function modifier_elite_piercing_buff:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_elite_piercing_buff:OnAttackLanded(params)
	if params.attacker == self:GetParent() then
		local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_phantom_assassin/phantom_assassin_crit_impact.vpcf", PATTACH_CUSTOMORIGIN, params.attacker )
                    ParticleManager:SetParticleControlEnt( nFXIndex, 0, params.target, PATTACH_POINT_FOLLOW, "attach_hitloc", params.target:GetOrigin(), true )
                    ParticleManager:SetParticleControl( nFXIndex, 1, params.target:GetOrigin() )
                    ParticleManager:SetParticleControlForward( nFXIndex, 1, params.attacker:GetForwardVector() )
                    ParticleManager:SetParticleControlEnt( nFXIndex, 10, params.target, PATTACH_ABSORIGIN_FOLLOW, nil, params.target:GetOrigin(), true )
                    ParticleManager:ReleaseParticleIndex( nFXIndex )
		self:GetAbility():DealDamage(params.attacker, params.target, params.damage, {damage_type = DAMAGE_TYPE_PURE, damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION})
		self:Destroy()
	end
end