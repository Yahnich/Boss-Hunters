venomancer_venomous_gale_ebf = class({})

function venomancer_venomous_gale_ebf:GetCooldown(nLevel)
	local cooldown = self.BaseClass.GetCooldown( self, nLevel ) + self:GetCaster():FindTalentValue("special_bonus_unique_venomancer_venomous_gale_2")
	return cooldown
end

function venomancer_venomous_gale_ebf:GetManaCost(nLvl)
	if self:GetCaster():IsHero() then
		return self.BaseClass.GetManaCost(self, nLvl)
	else
		return 0
	end
end

if IsServer() then
	function venomancer_venomous_gale_ebf:OnSpellStart()
		self.speed = self:GetSpecialValueFor( "speed" )
		self.width = self:GetSpecialValueFor( "radius" )
		self.distance = self:GetTrueCastRange()
		self.strike_damage = self:GetSpecialValueFor( "strike_damage" ) 

		EmitSoundOn( "Hero_Venomancer.VenomousGale", self:GetCaster() )

		local vPos = nil
		if self:GetCursorTarget() then
			vPos = self:GetCursorTarget():GetOrigin()
		else
			vPos = self:GetCursorPosition()
		end

		local vDirection = vPos - self:GetCaster():GetOrigin()
		vDirection.z = 0.0
		vDirection = vDirection:Normalized()
		
		local info = {
			EffectName = "particles/units/heroes/hero_venomancer/venomancer_venomous_gale.vpcf",
			Ability = self,
			vSpawnOrigin = self:GetCaster():GetOrigin(), 
			fStartRadius = self.width,
			fEndRadius = self.width,
			vVelocity = vDirection * self.speed,
			fDistance = self.distance,
			Source = self:GetCaster(),
			iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
			iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		}

		ProjectileManager:CreateLinearProjectile( info )
	end

	--------------------------------------------------------------------------------

	function venomancer_venomous_gale_ebf:OnProjectileHit( hTarget, vLocation )
		if hTarget ~= nil and ( not hTarget:IsMagicImmune() ) and ( not hTarget:IsInvulnerable() ) then
			local caster = self:GetCaster()
			hTarget:AddNewModifier(self:GetCaster(), self, "modifier_venomancer_venomous_gale_cancer", {duration = self:GetSpecialValueFor("duration")})
			EmitSoundOn( "Hero_Venomancer.VenomousGaleImpact", hTarget )
			
			local vDirection = vLocation - self:GetCaster():GetOrigin()
			vDirection.z = 0.0
			vDirection = vDirection:Normalized()
			
			local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_venomancer/venomancer_venomous_gale_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, hTarget )
			ParticleManager:SetParticleControlForward( nFXIndex, 1, vDirection )
			ParticleManager:ReleaseParticleIndex( nFXIndex )
			
			
			
			local damage = {
				victim = hTarget,
				attacker = self:GetCaster(),
				damage = self.strike_damage,
				damage_type = DAMAGE_TYPE_MAGICAL,
				ability = self
			}
			ApplyDamage( damage )
			if caster:HasTalent("special_bonus_unique_venomancer_venomous_gale_1") and hTarget:IsRoundNecessary() then
				local ward = caster:FindAbilityByName("venomancer_plague_ward_ebf")
				for i = 1, 2 do
					local position  = hTarget:GetAbsOrigin() + RandomVector(250)
					ward:CreateWard( position )
				end
			end
		end
		return false
	end
end

LinkLuaModifier( "modifier_venomancer_venomous_gale_cancer", "heroes/hero_venomancer/venomancer_venomous_gale_ebf", LUA_MODIFIER_MOTION_NONE )
modifier_venomancer_venomous_gale_cancer = class({})

function modifier_venomancer_venomous_gale_cancer:OnCreated()
	self.movespeed = self:GetAbility():GetSpecialValueFor("movement_slow")
	self.tick_damage = self:GetAbility():GetSpecialValueFor("tick_damage")
	if IsServer() then
		self:StartIntervalThink(1)
	end
end

function modifier_venomancer_venomous_gale_cancer:OnIntervalThink()
	local damage = {
		victim = self:GetParent(),
		attacker = self:GetCaster(),
		damage = self.tick_damage,
		damage_type = DAMAGE_TYPE_MAGICAL,
		ability = self:GetAbility()
	}
	ApplyDamage( damage )
end

function modifier_venomancer_venomous_gale_cancer:GetEffectName()
	return "particles/units/heroes/hero_venomancer/venomancer_gale_poison_debuff.vpcf"
end

function modifier_venomancer_venomous_gale_cancer:DeclareFunctions()
	funcs = {
				MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
			}
	return funcs
end

function modifier_venomancer_venomous_gale_cancer:GetModifierMoveSpeedBonus_Percentage()
	return self.movespeed
end

function modifier_venomancer_venomous_gale_cancer:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end