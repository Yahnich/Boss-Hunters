boss_slark_deep_ones_gift = class({})

function boss_slark_deep_ones_gift:GetIntrinsicModifierName()
	return "modifier_boss_slark_deep_ones_gift"
end

modifier_boss_slark_deep_ones_gift = class({})
LinkLuaModifier("modifier_boss_slark_deep_ones_gift", "bosses/boss_slarks/boss_slark_deep_ones_gift", LUA_MODIFIER_MOTION_NONE)

function modifier_boss_slark_deep_ones_gift:OnCreated()
	self:OnRefresh()
	if IsServer() then
		self:StartIntervalThink( 0.5 )
	end
end

function modifier_boss_slark_deep_ones_gift:OnRefresh()	
	self.delay = self:GetSpecialValueFor("dispel_delay")
end

function modifier_boss_slark_deep_ones_gift:OnIntervalThink()
	local parent = self:GetParent()
	if not parent:HasModifier("modifier_boss_slark_deep_ones_gift_active") and parent:HasPurgableDebuffs() then
		parent:AddNewModifier( parent, self:GetAbility(), "modifier_boss_slark_deep_ones_gift_active", {duration = self.delay} )
	end
end

function modifier_boss_slark_deep_ones_gift:IsHidden()
	return true
end

modifier_boss_slark_deep_ones_gift_active = class({})
LinkLuaModifier("modifier_boss_slark_deep_ones_gift_active", "bosses/boss_slarks/boss_slark_deep_ones_gift", LUA_MODIFIER_MOTION_NONE)


function modifier_boss_slark_deep_ones_gift_active:OnCreated()
	self:OnRefresh()
	if IsServer() then
		EmitSoundOn("Hero_Slark.DarkPact.PreCast", self:GetParent())
		ParticleManager:FireParticle("particles/units/heroes/hero_slark/slark_dark_pact_start.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent(), {[1] = "attach_hitloc"})
	end
end

function modifier_boss_slark_deep_ones_gift_active:OnRefresh()
	self.damage = self:GetSpecialValueFor("damage_multiplier") / 100
	self.hpCost = self:GetSpecialValueFor("hp_loss") / 100
	self.radius = self:GetSpecialValueFor("radius")
end

function modifier_boss_slark_deep_ones_gift_active:OnDestroy()
	if IsServer() then
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		local hpCost = caster:GetMaxHealth() * self.hpCost
		local damage = hpCost * self.damage
		
		local enemies = caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), self.radius )
		for _, enemy in ipairs( enemies ) do
			ability:DealDamage( caster, enemy, damage, {damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION, damage_type = DAMAGE_TYPE_PURE})
		end
		caster:Dispel(caster, true)
		ability:DealDamage( caster, caster, hpCost, {damage_flags = DOTA_DAMAGE_FLAG_NON_LETHAL + DOTA_DAMAGE_FLAG_HPLOSS + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION, damage_type = DAMAGE_TYPE_PURE})
		EmitSoundOn("Hero_Slark.DarkPact.Cast", caster)
		ParticleManager:FireParticle("particles/units/heroes/hero_slark/slark_dark_pact_pulses.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster, {[1] = "attach_hitloc", [2] = Vector(self.radius, self.radius, self.radius)})
	end
end