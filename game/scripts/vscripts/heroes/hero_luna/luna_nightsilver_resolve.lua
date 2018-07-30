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