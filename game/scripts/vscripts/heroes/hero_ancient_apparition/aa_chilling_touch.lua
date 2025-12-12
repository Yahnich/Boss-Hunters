aa_chilling_touch = class({})

function aa_chilling_touch:GetIntrinsicModifierName()
	return "modifier_aa_chilling_touch_passive"
end

function aa_chilling_touch:OnSpellStart()
	local caster = self:GetCaster()
	ParticleManager:FireParticle("particles/units/heroes/hero_ancient_apparition/ancient_apparition_chilling_touch.vpcf", PATTACH_POINT, caster, {[0]=caster:GetAbsOrigin(),[1]=Vector(radius,radius,radius)})
	EmitSoundOn("Hero_Ancient_Apparition.ChillingTouchCast", caster)

	caster:AddNewModifier(caster, self, "modifier_aa_chilling_touch", {})
	if caster:HasTalent("special_bonus_unique_aa_chilling_touch_2") then
		caster:AddNewModifier( caster, self, "modifier_aa_chilling_touch_talent", {duration = caster:FindTalentValue("special_bonus_unique_aa_chilling_touch_2", "duration")} )
	end
end

function aa_chilling_touch:OnProjectileHit( target, position )
	local caster = self:GetCaster()
	local damage = self:GetSpecialValueFor("bonus_damage")
	if caster:HasTalent("special_bonus_unique_aa_chilling_touch_1") and target:IsFrozenGeneric() then
		damage = damage * caster:FindTalentValue("special_bonus_unique_aa_chilling_touch_1")
	end
	self:DealDamage(caster, target, damage, {damage_type=DAMAGE_TYPE_MAGICAL, damage_flags=DOTA_DAMAGE_FLAG_PROPERTY_FIRE}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
	local chill = self:GetSpecialValueFor("chill")
	target:AddChill(self, caster, self:GetSpecialValueFor("chill_duration"), chill )
end

modifier_aa_chilling_touch_passive = class({})
LinkLuaModifier("modifier_aa_chilling_touch_passive", "heroes/hero_ancient_apparition/aa_chilling_touch", LUA_MODIFIER_MOTION_NONE)

function modifier_aa_chilling_touch_passive:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK}
end

function modifier_aa_chilling_touch_passive:OnAttack(params)
    if IsServer() and params.attacker == self:GetParent() and self:GetAbility():IsFullyCastable() and self:GetAbility():GetAutoCastState() then
    	self:GetAbility():CastSpell()
    end
	if params.attacker:HasModifier("modifier_aa_chilling_touch") then
		params.attacker:RemoveModifierByName("modifier_aa_chilling_touch")
		self:GetAbility():FireTrackingProjectile("particles/units/heroes/hero_ancient_apparition/ancient_apparition_chilling_touch_projectile.vpcf", params.target, params.attacker:GetProjectileSpeed(), nil, DOTA_PROJECTILE_ATTACHMENT_ATTACK_1 )
	end
end

function modifier_aa_chilling_touch_passive:IsHidden()
	return true
end

modifier_aa_chilling_touch_talent = class({})
LinkLuaModifier("modifier_aa_chilling_touch_talent", "heroes/hero_ancient_apparition/aa_chilling_touch", LUA_MODIFIER_MOTION_NONE)
function modifier_aa_chilling_touch_talent:OnCreated(table)
	self:OnRefresh()
end

function modifier_aa_chilling_touch_talent:OnRefresh(table)
	self.as = self:GetCaster():FindTalentValue("special_bonus_unique_aa_chilling_touch_2")
end

function modifier_aa_chilling_touch_talent:DeclareFunctions()
    local funcs = {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
    }
    return funcs
end

function modifier_aa_chilling_touch_talent:GetModifierAttackSpeedBonus_Constant()
    return self.as
end

function modifier_aa_chilling_touch_talent:GetEffectName()
	return "particles/units/heroes/hero_ancient_apparition/ancient_apparition_chilling_touch_buff.vpcf"
end

modifier_aa_chilling_touch = class({})
LinkLuaModifier("modifier_aa_chilling_touch", "heroes/hero_ancient_apparition/aa_chilling_touch", LUA_MODIFIER_MOTION_NONE)

function modifier_aa_chilling_touch:IsHidden()
	return true
end