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
			iUnitTargetTeam = TernaryOperator( DOTA_UNIT_TARGET_TEAM_BOTH, self:GetCaster():HasTalent("special_bonus_unique_luna_nightsilver_resolve_2"), DOTA_UNIT_TARGET_TEAM_ENEMY),
			iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		}

		ProjectileManager:CreateLinearProjectile( info )
	end

	--------------------------------------------------------------------------------

	function luna_nightsilver_resolve:OnProjectileHit( hTarget, vLocation )
		if hTarget ~= nil and ( not hTarget:IsMagicImmune() ) and ( not hTarget:IsInvulnerable() ) then
			local caster = self:GetCaster()
			if hTarget:IsSameTeam( caster ) then
				hTarget:HealEvent( self.spear_damage, self, caster )
				hTarget:AddNewModifier(caster, self, "modifier_luna_nightsilver_resolve_strengthen", {duration = self:GetSpecialValueFor("weaken_duration")})
			elseif not hTarget:TriggerSpellAbsorb( self ) then
				local damage = {
					victim = hTarget,
					attacker = self:GetCaster(),
					damage = self.spear_damage,
					damage_type = DAMAGE_TYPE_MAGICAL,
					ability = self
				}

				ApplyDamage( damage )
				hTarget:AddNewModifier( caster, self, "modifier_luna_nightsilver_resolve_weaken", {duration = self:GetSpecialValueFor("weaken_duration")})
			end
		end

		return false
	end
end

LinkLuaModifier( "modifier_luna_nightsilver_resolve_strengthen", "heroes/hero_luna/luna_nightsilver_resolve", LUA_MODIFIER_MOTION_NONE )
modifier_luna_nightsilver_resolve_strengthen = class({})

function modifier_luna_nightsilver_resolve_strengthen:OnCreated()
	self.weaken = self:GetAbility():GetSpecialValueFor("spear_weaken") * (-1)
end

function modifier_luna_nightsilver_resolve_strengthen:DeclareFunctions()
	funcs = {
				MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
			}
	return funcs
end

function modifier_luna_nightsilver_resolve_strengthen:GetModifierBaseDamageOutgoing_Percentage()
	return self.weaken
end

LinkLuaModifier( "modifier_luna_nightsilver_resolve_weaken", "heroes/hero_luna/luna_nightsilver_resolve", LUA_MODIFIER_MOTION_NONE )
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