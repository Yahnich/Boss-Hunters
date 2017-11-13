luna_lunar_blessing_ebf = class({})

function luna_lunar_blessing_ebf:GetIntrinsicModifierName()
	return "modifier_luna_lunar_blessing_passive"
end

LinkLuaModifier( "modifier_luna_lunar_blessing_passive", "lua_abilities/heroes/luna.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_luna_lunar_blessing_passive = class({})

function modifier_luna_lunar_blessing_passive:OnCreated()
	self.aura_radius = self:GetAbility():GetSpecialValueFor("radius")
	self.lucent = self:GetAbility():GetSpecialValueFor("bonus_lucent_targets")
end

function modifier_luna_lunar_blessing_passive:OnRefresh()
	self.aura_radius = self:GetAbility():GetSpecialValueFor("radius")
	self.lucent = self:GetAbility():GetSpecialValueFor("bonus_lucent_targets")
end

function modifier_luna_lunar_blessing_passive:IsHidden()
	return true
end

--------------------------------------------------------------------------------

function modifier_luna_lunar_blessing_passive:IsAura()
	return true
end

--------------------------------------------------------------------------------

function modifier_luna_lunar_blessing_passive:GetModifierAura()
	return "modifier_luna_lunar_blessing_aura"
end

--------------------------------------------------------------------------------

function modifier_luna_lunar_blessing_passive:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

--------------------------------------------------------------------------------

function modifier_luna_lunar_blessing_passive:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO
end

--------------------------------------------------------------------------------

function modifier_luna_lunar_blessing_passive:GetAuraRadius()
	return self.aura_radius
end

--------------------------------------------------------------------------------
function modifier_luna_lunar_blessing_passive:IsPurgable()
    return false
end

function modifier_luna_lunar_blessing_passive:DeclareFunctions()
	funcs = {
				MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
			}
	return funcs
end

function modifier_luna_lunar_blessing_passive:OnAbilityFullyCast(params)
    if IsServer() then
		if params.unit == self:GetParent() and params.ability:GetName() == "luna_lucent_beam" then
			local units = FindUnitsInRadius(params.unit:GetTeam(), params.target:GetAbsOrigin(), nil, self:GetAbility():GetSpecialValueFor("bonus_beam_radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 0, 0, false)
			local beams = self.lucent
			print(beams)
			for _,unit in pairs(units) do
				if unit ~= params.target then
					params.unit:SetCursorCastTarget(unit)
					params.ability:OnSpellStart()
					beams = beams - 1
					if beams == 0 then break end
				end
			end
		end
	end
end

LinkLuaModifier( "modifier_luna_lunar_blessing_aura", "lua_abilities/heroes/luna.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_luna_lunar_blessing_aura = class({})

function modifier_luna_lunar_blessing_aura:OnCreated()
    self.damage = self:GetAbility():GetSpecialValueFor("bonus_damage")
	self.dmg_pct = self:GetAbility():GetSpecialValueFor("bonus_damage_pct")
end

function modifier_luna_lunar_blessing_aura:OnRefresh()
    self.damage = self:GetAbility():GetSpecialValueFor("bonus_damage")
	self.dmg_pct = self:GetAbility():GetSpecialValueFor("bonus_damage_pct")
end

function modifier_luna_lunar_blessing_aura:DeclareFunctions()
	funcs = {
				MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
				MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE
			}
	return funcs
end

function modifier_luna_lunar_blessing_aura:GetModifierPreAttack_BonusDamage()
    return self.damage
end

function modifier_luna_lunar_blessing_aura:GetModifierBaseDamageOutgoing_Percentage()
    return self.dmg_pct
end


luna_nightsilver_resolve = class({})

if IsServer() then
	function luna_nightsilver_resolve:OnSpellStart()
		self.spear_speed = self:GetSpecialValueFor( "spear_speed" )
		self.spear_width = self:GetSpecialValueFor( "spear_width" )
		self.spear_distance = self:GetSpecialValueFor( "spear_distance" )
		self.spear_damage = self:GetSpecialValueFor( "spear_damage" ) 

		EmitSoundOn( "Hero_Luna.Eclipse.Cast", self:GetCaster() )
		EmitSoundOn( "Hero_Luna.Eclipse.NoTarget", self:GetCaster() )

		local vPos = nil
		if self:GetCursorTarget() then
			vPos = self:GetCursorTarget():GetOrigin()
		else
			vPos = self:GetCursorPosition()
		end

		local vDirection = vPos - self:GetCaster():GetOrigin()
		vDirection.z = 0.0
		vDirection = vDirection:Normalized()

		self.spear_speed = self.spear_speed

		local info = {
			EffectName = "particles/luna_nightsilver_resolve.vpcf",
			Ability = self,
			vSpawnOrigin = self:GetCaster():GetOrigin(), 
			fStartRadius = self.spear_width,
			fEndRadius = self.spear_width,
			vVelocity = vDirection * self.spear_speed,
			fDistance = self.spear_distance,
			Source = self:GetCaster(),
			iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
			iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		}

		ProjectileManager:CreateLinearProjectile( info )
	end

	--------------------------------------------------------------------------------

	function luna_nightsilver_resolve:OnProjectileHit( hTarget, vLocation )
		if hTarget ~= nil and ( not hTarget:IsMagicImmune() ) and ( not hTarget:IsInvulnerable() ) then
			local damage = {
				victim = hTarget,
				attacker = self:GetCaster(),
				damage = self.spear_damage,
				damage_type = DAMAGE_TYPE_MAGICAL,
				ability = self
			}

			ApplyDamage( damage )
			hTarget:AddNewModifier(self:GetCaster(), self, "modifier_luna_nightsilver_resolve_weaken", {duration = self:GetSpecialValueFor("weaken_duration")})

			local vDirection = vLocation - self:GetCaster():GetOrigin()
			vDirection.z = 0.0
			vDirection = vDirection:Normalized()
			
			local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_lina/lina_spell_dragon_slave_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, hTarget )
			ParticleManager:SetParticleControlForward( nFXIndex, 1, vDirection )
			ParticleManager:ReleaseParticleIndex( nFXIndex )
		end

		return false
	end
end

LinkLuaModifier( "modifier_luna_nightsilver_resolve_weaken", "lua_abilities/heroes/luna.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_luna_nightsilver_resolve_weaken = class({})

function modifier_luna_nightsilver_resolve_weaken:OnCreated()
	self.weaken = self:GetAbility():GetSpecialValueFor("spear_weaken")
end

function modifier_luna_nightsilver_resolve_weaken:DeclareFunctions()
	funcs = {
				MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
			}
	return funcs
end

function modifier_luna_nightsilver_resolve_weaken:GetModifierBaseDamageOutgoing_Percentage()
	return self.weaken
end