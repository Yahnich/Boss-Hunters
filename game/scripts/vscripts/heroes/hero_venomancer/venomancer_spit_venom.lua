venomancer_spit_venom = class({})

function venomancer_spit_venom:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget() or self:GetCursorPosition()
	local speed = self:GetSpecialValueFor( "speed" )
	local width = self:GetSpecialValueFor( "radius" )
	local distance = self:GetTrueCastRange()

	EmitSoundOn( "Hero_Venomancer.VenomousGale", self:GetCaster() )

	local direction = CalculateDirection( target, caster )
	self:FireLinearProjectile( "particles/units/heroes/hero_venomancer/venomancer_venomous_gale.vpcf", direction * speed, distance, width )
end

--------------------------------------------------------------------------------

function venomancer_spit_venom:OnProjectileHit( target, position )
	if target then
		local caster = self:GetCaster()
		target:RemoveModifierByName("modifier_venomancer_spit_venom_cancer")
		target:AddNewModifier(self:GetCaster(), self, "modifier_venomancer_spit_venom_cancer", {duration = self:GetSpecialValueFor("duration")})
		target:AddPoison(caster, self:GetSpecialValueFor("tick_damage") )
		EmitSoundOn( "Hero_Venomancer.VenomousGaleImpact", target )
		
		local damage = self:GetSpecialValueFor("strike_damage")
		local bonusPoisonDamage = self:GetSpecialValueFor("bonus_poison_strike_damage")
		print( caster:IsRealHero( ), self:GetSpecialValueFor("wards_to_create"), target:IsConsideredHero() )
		if caster:IsRealHero( ) and self:GetSpecialValueFor("wards_to_create") > 0 and target:IsConsideredHero() then
			print( "first check ok" )
			local ward = caster:FindAbilityByName("venomancer_living_growth")
			if ward and ward:IsTrained() then
				print( "found ward" )
				for i = 1, self:GetSpecialValueFor("wards_to_create") do
					local position  = target:GetAbsOrigin() + RandomVector(250)
					caster:SetCursorPosition( position )
					ward:OnSpellStart( )
				end
			end
		end
		
		local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_venomancer/venomancer_venomous_gale_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, target )
		ParticleManager:SetParticleControlForward( nFXIndex, 1, CalculateDirection( target, position ) )
		ParticleManager:ReleaseParticleIndex( nFXIndex )
		
		self:DealDamage( caster, target, damage + bonusPoisonDamage * target:GetPoison(), {damage_type = DAMAGE_TYPE_MAGICAL} )
	end
	return false
end

LinkLuaModifier( "modifier_venomancer_spit_venom_cancer", "heroes/hero_venomancer/venomancer_spit_venom", LUA_MODIFIER_MOTION_NONE )
modifier_venomancer_spit_venom_cancer = class({})

function modifier_venomancer_spit_venom_cancer:OnCreated()
	self:OnRefresh()
	self:StartIntervalThink( self.tick )
end

function modifier_venomancer_spit_venom_cancer:OnRefresh()
	self.movespeed = -self:GetSpecialValueFor("movement_slow")
	self.tick = 0.5
	self.msReduction = self.tick * self.movespeed / self:GetRemainingTime()
end

function modifier_venomancer_spit_venom_cancer:OnDestroy()
	if IsServer() then
		local caster = self:GetCaster()
		local parent = self:GetParent()
		local ability = self:GetAbility()
		local damage = self:GetSpecialValueFor("explosion_damage") / 100
		if damage > 0 then
			ability:DealDamage( caster, parent, parent:GetPoisonDamage() * damage, {damage_type = DAMAGE_TYPE_MAGICAL}, OVERHEAD_ALERT_BONUS_POISON_DAMAGE )
			ability:Stun( parent, self:GetSpecialValueFor("explosion_stun_duration") )
		end
	end
end

function modifier_venomancer_spit_venom_cancer:OnIntervalThink()
	self.movespeed = math.min( self.movespeed - self.msReduction, 0 )
end

function modifier_venomancer_spit_venom_cancer:DeclareFunctions()
	funcs = {
				MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
			}
	return funcs
end

function modifier_venomancer_spit_venom_cancer:GetModifierMoveSpeedBonus_Percentage()
	return self.movespeed
end

function modifier_venomancer_spit_venom_cancer:GetEffectName()
	return "particles/units/heroes/hero_venomancer/venomancer_gale_poison_debuff.vpcf"
end