function viper_nethertoxin(keys)
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability
    local missing_health = target:GetMaxHealth() - target:GetHealth()
    local damage = math.floor(ability:GetTalentSpecialValueFor("percent") * missing_health * 0.01) + 1
    local damageTable = {
        victim = target,
        attacker = caster,
        damage = damage,
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = keys.ability,
    }

    ApplyDamage( damageTable )
    if caster.show_popup ~= true then
                    caster.show_popup = true
                    caster:ShowPopup( {
                    PreSymbol = 1,
                    PostSymbol = 5,
                    Color = Vector( 50, 255, 100 ),
                    Duration = 1.5,
                    Number = damage,
                    pfx = "damage",
                    Player = true
                } )
                Timers:CreateTimer(3.0,function()
                    caster.show_popup = false
                end)
    end
end

viper_viper_strike_ebf = class({})

function viper_viper_strike_ebf:GetCastRange(pos, handle)
	local castrange = 500
	if self:GetCaster():HasScepter() then castrange = self:GetSpecialValueFor("cast_range_scepter") end
	return castrange
end

function viper_viper_strike_ebf:GetCooldown(nLevel)
	local cooldown = self.BaseClass.GetCooldown( self, nLevel )
	if self:GetCaster():HasScepter(	) then cooldown = self:GetSpecialValueFor("cooldown_scepter") end
	return cooldown
end

if IsServer() then
	function viper_viper_strike_ebf:OnAbilityPhaseStart()
		self.warmUp = ParticleManager:CreateParticle("particles/units/heroes/hero_viper/viper_viper_strike_warmup.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster())
			ParticleManager:SetParticleControlEnt(self.warmUp, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetCaster():GetAbsOrigin(), true)
			ParticleManager:SetParticleControlEnt(self.warmUp, 2, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack2", self:GetCaster():GetAbsOrigin(), true)
			ParticleManager:SetParticleControlEnt(self.warmUp, 3, self:GetCursorTarget(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCursorTarget():GetAbsOrigin(), true)
			ParticleManager:SetParticleControlEnt(self.warmUp, 4, self:GetCursorTarget(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCursorTarget():GetAbsOrigin(), true)
		return true
	end
	function viper_viper_strike_ebf:OnAbilityPhaseInterrupted()
		ParticleManager:DestroyParticle(self.warmUp ,false)
		ParticleManager:ReleaseParticleIndex(self.warmUp)
	end
	function viper_viper_strike_ebf:OnSpellStart()
		ParticleManager:DestroyParticle(self.warmUp ,false)
		ParticleManager:ReleaseParticleIndex(self.warmUp)
		if self:GetCaster():HasScepter() then
			local enemies = FindUnitsInRadius(self:GetCaster():GetTeam(), self:GetCursorTarget():GetAbsOrigin(), nil, self:GetSpecialValueFor("radius_scepter"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false)
			for _,enemy in pairs(enemies) do
				local projectile = {
					Target = enemy,
					Source = self:GetCaster(),
					Ability = self,
					EffectName = "particles/viper_viper_strike_ebf.vpcf",
					bDodgable = true,
					bProvidesVision = false,
					iMoveSpeed = self:GetTalentSpecialValueFor("projectile_speed"),
					iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
				}
				ProjectileManager:CreateTrackingProjectile(projectile)
			end
		else
			local projectile = {
				Target = self:GetCursorTarget(),
				Source = self:GetCaster(),
				Ability = self,
				EffectName = "particles/viper_viper_strike_ebf.vpcf",
				bDodgable = true,
				bProvidesVision = false,
				iMoveSpeed = self:GetTalentSpecialValueFor("projectile_speed"),
				iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
			}
			ProjectileManager:CreateTrackingProjectile(projectile)
		end
		EmitSoundOn("Hero_Viper.viperStrike", self:GetCaster())
	end

	function viper_viper_strike_ebf:OnProjectileHit(target, position)
		if not target then return end
		EmitSoundOn("Hero_Viper.viperStrikeImpact", target)
		target:AddNewModifier(self:GetCaster(), self, "modifier_viper_viper_strike_cancer", {duration = self:GetSpecialValueFor("duration")})
	end
end

LinkLuaModifier( "modifier_viper_viper_strike_cancer", "lua_abilities/heroes/viper.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_viper_viper_strike_cancer = class({})

function modifier_viper_viper_strike_cancer:OnCreated()
	self.movespeed = self:GetAbility():GetSpecialValueFor("bonus_movement_speed")
	self.attackspeed = self:GetAbility():GetSpecialValueFor("bonus_attack_speed")
	self:StartIntervalThink(1)
end

function modifier_viper_viper_strike_cancer:OnIntervalThink()
	self.movespeed = self.movespeed - self:GetAbility():GetSpecialValueFor("bonus_movement_speed") / self:GetAbility():GetSpecialValueFor("duration")
	self.attackspeed = self.attackspeed - self:GetAbility():GetSpecialValueFor("bonus_attack_speed") / self:GetAbility():GetSpecialValueFor("duration")
	self:StartIntervalThink(1)
	if IsServer() then
		local damage = self:GetAbility():GetTalentSpecialValueFor("damage")
		ApplyDamage({victim = self:GetParent(), attacker = self:GetCaster(), damage = damage, damage_type = self:GetAbility():GetAbilityDamageType(), ability = self:GetAbility()})
	end
end

function modifier_viper_viper_strike_cancer:GetStatusEffectName()
	return "particles/status_fx/status_effect_poison_viper.vpcf"
end

function modifier_viper_viper_strike_cancer:GetEffectName()
	return "particles/units/heroes/hero_viper/viper_viper_strike_debuff.vpcf"
end

function modifier_viper_viper_strike_cancer:DeclareFunctions()
	funcs = {
				MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
				MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
			}
	return funcs
end

function modifier_viper_viper_strike_cancer:GetModifierMoveSpeedBonus_Percentage()
	return self.movespeed
end

function modifier_viper_viper_strike_cancer:GetModifierAttackSpeedBonus_Constant()
	return self.attackspeed
end

function modifier_viper_viper_strike_cancer:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end