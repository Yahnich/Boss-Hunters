elite_parrying = class({})

function elite_parrying:GetIntrinsicModifierName()
	return "modifier_elite_parrying"
end

function elite_parrying:OnSpellStart()
	local caster = self:GetCaster()
	
	ParticleManager:FireWarningParticle( caster:GetAbsOrigin(), 150 )
	local cd = self:GetCooldownTimeRemaining()
	caster:EmitSound("DOTA_Item.BladeMail.Activate")
	Timers:CreateTimer(1.5, function()
		self:EndCooldown()
		self:SetCooldown(cd)
		caster:AddNewModifier(caster, self, "modifier_elite_parrying_buff", {duration = self:GetSpecialValueFor("duration")})
	end)
end

modifier_elite_parrying = class(relicBaseClass)
LinkLuaModifier("modifier_elite_parrying", "elites/elite_parrying", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
	function modifier_elite_parrying:OnCreated()
		self:StartIntervalThink( 1 )
	end
	
	function modifier_elite_parrying:OnIntervalThink()
		local caster = self:GetCaster()
		if caster:PassivesDisabled() or not caster:IsAlive() or caster:HasActiveAbility() then return end
		local ability = self:GetAbility()
		if not ability:IsFullyCastable() then return end
		if #caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), 800 ) <= 0 then return end
		ability:CastSpell()
	end
end


modifier_elite_parrying_buff = class({})
LinkLuaModifier("modifier_elite_parrying_buff", "elites/elite_parrying", LUA_MODIFIER_MOTION_NONE)

function modifier_elite_parrying:OnDestroy() 
	if IsServer() then self:GetCaster():EmitSound("DOTA_Item.BladeMail.Deactivate") end
end

function modifier_elite_parrying_buff:DeclareFunctions()
	return {MODIFIER_EVENT_ON_TAKEDAMAGE}
end

function modifier_elite_parrying_buff:OnTakeDamage(params)
	local hero = self:GetParent()
	if params.unit ~= hero then return end
    local dmg = params.original_damage
	local dmgtype = params.damage_type
	local attacker = params.attacker
	if attacker:GetTeamNumber()  ~= hero:GetTeamNumber() and not ( HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) or HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) ) then
		self:GetAbility():DealDamage( hero, attacker, dmg, {damage_type = dmgtype, damage_flags = DOTA_DAMAGE_FLAG_REFLECTION + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION} )
	end
end

function modifier_elite_parrying_buff:GetEffectName()
	return "particles/items_fx/blademail.vpcf"
end