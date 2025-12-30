kunkka_clear_wave = class({})

function kunkka_clear_wave:IsStealable()
    return false
end

function kunkka_clear_wave:IsHiddenWhenStolen()
    return false
end

function kunkka_clear_wave:GetIntrinsicModifierName()
    return "modifier_kunkka_clear_wave_handler"
end

function kunkka_clear_wave:OnUpgrade()
	self:GetCaster():RemoveModifierByName("modifier_kunkka_clear_wave_active")
end

modifier_kunkka_clear_wave_handler = class({})
LinkLuaModifier("modifier_kunkka_clear_wave_handler", "heroes/hero_kunkka/kunkka_clear_wave", LUA_MODIFIER_MOTION_NONE)

function modifier_kunkka_clear_wave_handler:IsHidden()
    return true
end

function modifier_kunkka_clear_wave_handler:OnCreated()
	if not IsServer() then return end
    self:StartIntervalThink(0.1)
end

function modifier_kunkka_clear_wave_handler:OnIntervalThink()
	local ability = self:GetAbility()
	if not ability:IsCooldownReady() then return end
	local parent = self:GetParent()
	if parent:IsIllusion() then return end
	if parent:HasModifier("modifier_kunkka_clear_wave_active") then return end
	local caster = self:GetCaster()
	parent:AddNewModifier( caster, ability, "modifier_kunkka_clear_wave_active", {})
end

modifier_kunkka_clear_wave_active = class({})
LinkLuaModifier("modifier_kunkka_clear_wave_active", "heroes/hero_kunkka/kunkka_clear_wave", LUA_MODIFIER_MOTION_NONE)

function modifier_kunkka_clear_wave_active:OnCreated()
	self.damage_bonus = self:GetSpecialValueFor("damage_bonus")
	
	self.cleave_damage = self:GetSpecialValueFor("cleave_damage") / 100
	self.cleave_ending_width = self:GetSpecialValueFor("cleave_ending_width")
	self.cleave_distance = self:GetSpecialValueFor("cleave_distance")
	
	self.mini_stun_duration = self:GetSpecialValueFor("mini_stun_duration")
	self.heal_pct = self:GetSpecialValueFor("heal_pct") / 100
	self.hit_cdr_hero = self:GetSpecialValueFor("hit_cdr_hero")
	self.hit_cdr_creep = self:GetSpecialValueFor("hit_cdr_creep")
	
	self.hit_cdr_creep = self:GetSpecialValueFor("hit_cdr_creep")
	self.armor_reduction_duration = self:GetSpecialValueFor("armor_reduction_duration")
    if IsServer() then
        local caster = self:GetCaster()
        EmitSoundOn("Hero_Kunkaa.Tidebringer", caster)
        --AddAnimationTranslate(caster, "tidebringer")
        local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_kunkka/kunkka_weapon_tidebringer.vpcf", PATTACH_POINT_FOLLOW, caster)
                    ParticleManager:SetParticleControlEnt(nfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_tidebringer", caster:GetAbsOrigin(), true)
                    ParticleManager:SetParticleControlEnt(nfx, 2, caster, PATTACH_POINT_FOLLOW, "attach_sword", caster:GetAbsOrigin(), true)
        self:AttachEffect(nfx)
    end
end

function modifier_kunkka_clear_wave_active:DeclareFunctions()
    return
    {
		MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
end

function modifier_kunkka_clear_wave_active:GetModifierBaseAttack_BonusDamage()
    return self.damage_bonus
end

function modifier_kunkka_clear_wave_active:OnAttackLanded(params)
	if params.no_attack_cooldown then return end
    local caster = self:GetCaster()
	if caster ~= params.attacker then return end
    local ability = self:GetAbility()
	
	EmitSoundOn("Hero_Kunkka.Tidebringer.Attack", caster)
	ParticleManager:FireParticle("particles/units/heroes/hero_kunkka/kunkka_spell_tidebringer_b.vpcf", PATTACH_POINT, self:GetCaster(), {})
	local cdr = 0
	local lifesteal = 0
	local targets
	if self.cleave_distance <= 0 then
		targets = caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), -1 )
	else
		targets = caster:FindEnemyUnitsInCone( CalculateDirection( params.target, params.attacker ), caster:GetAbsOrigin(), self.cleave_ending_width, self.cleave_distance )
	end
	for _, enemy in ipairs( targets ) do
		if enemy ~= params.target then
			EmitSoundOn("Hero_Kunkka.TidebringerDamage", targets)
			local tidebringer_hit_fx = ParticleManager:CreateParticle("particles/units/heroes/hero_kunkka/kunkka_spell_tidebringer.vpcf", PATTACH_CUSTOMORIGIN, caster)
										ParticleManager:SetParticleControlEnt(tidebringer_hit_fx, 0, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true)
										ParticleManager:SetParticleControlEnt(tidebringer_hit_fx, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
										ParticleManager:SetParticleControl(tidebringer_hit_fx, 1, Vector(2,  17, 1))
										ParticleManager:SetParticleControlForward(tidebringer_hit_fx, 1, caster:GetForwardVector())
										ParticleManager:SetParticleControlEnt(tidebringer_hit_fx, 2, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true)
										ParticleManager:ReleaseParticleIndex(tidebringer_hit_fx)
			local damageDealt = ability:DealDamage(caster, enemy, params.original_damage * self.cleave_damage, {damage_type = DAMAGE_TYPE_PHYSICAL, damage_flag = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION})
			if self.mini_stun_duration > 0 then
				ability:Stun(enemy, self.mini_stun_duration)
			end
			if self.armor_reduction_duration > 0 then
				enemy:AddNewModifier( caster, ability, "modifier_kunkka_clear_wave_armor_debuff", {duration = self.armor_reduction_duration} )
			end

			lifesteal = lifesteal + damageDealt * self.heal_pct
			cdr = TernaryOperator( self.hit_cdr_creep, enemy:IsMinion(), self.hit_cdr_hero ) 
		end
	end
	ability:SetCooldown()
	if lifesteal > 0 then
		caster:HealEvent( lifesteal, ability, caster )
	end
	if cdr > 0 then
		ability:ModifyCooldown( -cdr )
	end
	self:Destroy()
end

modifier_kunkka_clear_wave_armor_debuff = class({})
LinkLuaModifier("modifier_kunkka_clear_wave_armor_debuff", "heroes/hero_kunkka/kunkka_clear_wave", LUA_MODIFIER_MOTION_NONE)

function modifier_kunkka_clear_wave_armor_debuff:OnCreated()
	self.armor_reduction = self:GetSpecialValueFor("armor_reduction")
end

function modifier_kunkka_clear_wave_armor_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end

function modifier_kunkka_clear_wave_armor_debuff:DeclareFunctions()
	return self.armor_reduction
end