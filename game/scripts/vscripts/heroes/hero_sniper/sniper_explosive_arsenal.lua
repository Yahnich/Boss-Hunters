sniper_explosive_arsenal = class({})

function sniper_explosive_arsenal:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end

function sniper_explosive_arsenal:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorPosition()
	
	local projectileSpeed = self:GetSpecialValueFor("projectile_speed")
	
	self.projectiles = {}
	local projectile = self:FireLinearProjectile( "particles/units/heroes/hero_sniper/sniper_concussive_grenade_linear.vpcf", projectileSpeed * CalculateDirection( target, caster ), CalculateDistance( target, caster ) )
	EmitSoundOn( "Hero_Sniper.ConcussiveGrenade.Cast", caster)
end

function sniper_explosive_arsenal:OnProjectileHitHandle(target, position)
	if not target then
		local caster = self:GetCaster()

		local radius = self:GetSpecialValueFor("radius")
		local damage = self:GetSpecialValueFor("damage")
		local knockbackDistance = self:GetSpecialValueFor("knockback_distance")
		local knockbackHeight = self:GetSpecialValueFor("knockback_height")
		local knockbackDuration = self:GetSpecialValueFor("knockback_duration")
		local debuffDuration = self:GetSpecialValueFor("debuff_duration")
        local blind = self:GetSpecialValueFor("blind")

		for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( position, radius ) ) do
			EmitSoundOn( "Hero_Sniper.ConcussiveGrenade.Target", enemy)
            if not self:GetAutoCastState() then
			    enemy:ApplyKnockBack(position, knockbackDuration, knockbackDuration, knockbackDistance, knockbackHeight, caster, self)
            end
			enemy:AddNewModifier( caster, self, "modifier_sniper_grenade_debuff", {duration = debuffDuration} )
			self:DealDamage( caster, enemy, damage )
            if blind ~= 0 then
                enemy:Blind(blind, self, caster, debuffDuration)
            end
		end
		if CalculateDistance( caster, position ) < radius then
			EmitSoundOn( "Hero_Sniper.ConcussiveGrenade.Target", caster)
            if not self:GetAutoCastState() then
			    caster:ApplyKnockBack(position, 0, knockbackDuration, knockbackDistance, knockbackHeight, caster, self)
            end
		end
	end
end

modifier_sniper_grenade_debuff = class({})
LinkLuaModifier("modifier_sniper_grenade_debuff", "heroes/hero_sniper/sniper_explosive_arsenal", LUA_MODIFIER_MOTION_NONE)

function modifier_sniper_grenade_debuff:IsDebuff()
    return true
end

function modifier_sniper_grenade_debuff:IsPurgable()
    return true
end

function modifier_sniper_grenade_debuff:OnCreated()
    self:OnRefresh()
end

function modifier_sniper_grenade_debuff:OnRefresh()
    self.slow = self:GetSpecialValueFor("slow")
    self.armor_reduc = self:GetSpecialValueFor("armor_reduc")
end

function modifier_sniper_grenade_debuff:DeclareFunctions()
    return
    {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
    }
end

function modifier_sniper_grenade_debuff:GetModifierMoveSpeedBonus_Percentage()
    return -self.slow
end

function modifier_sniper_grenade_debuff:GetModifierPhysicalArmorBonus()
    return -self.armor_reduc
end