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
		if hTarget ~= nil and ( not hTarget:IsMagicImmune() ) and ( not hTarget:IsInvulnerable() ) and not hTarget:TriggerSpellAbsorb( self ) then
			local caster = self:GetCaster()
			hTarget:AddNewModifier(self:GetCaster(), self, "modifier_venomancer_venomous_gale_cancer", {duration = self:GetSpecialValueFor("duration")})
			EmitSoundOn( "Hero_Venomancer.VenomousGaleImpact", hTarget )
			
			local vDirection = vLocation - self:GetCaster():GetOrigin()
			vDirection.z = 0.0
			vDirection = vDirection:Normalized()
			
			local damage = self:GetTalentSpecialValueFor("strike_damage")
			if not caster:IsRealHero() then
				local owner = caster:GetOwnerEntity()
				if owner:HasTalent("special_bonus_unique_venomancer_plague_ward_2") then
					damage = damage * owner:FindTalentValue("special_bonus_unique_venomancer_plague_ward_2") / 100
				end
			end
			
			local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_venomancer/venomancer_venomous_gale_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, hTarget )
			ParticleManager:SetParticleControlForward( nFXIndex, 1, vDirection )
			ParticleManager:ReleaseParticleIndex( nFXIndex )
			
			self:DealDamage( caster, hTarget, damage )
		end
		return false
	end
end

LinkLuaModifier( "modifier_venomancer_venomous_gale_cancer", "heroes/hero_venomancer/venomancer_venomous_gale_ebf", LUA_MODIFIER_MOTION_NONE )
modifier_venomancer_venomous_gale_cancer = class({})

function modifier_venomancer_venomous_gale_cancer:OnCreated()
	self:OnRefresh()
	self:StartIntervalThink( self.tick )
end

function modifier_venomancer_venomous_gale_cancer:OnRefresh()
	self.tick = self:GetTalentSpecialValueFor("tick_interval")
	self.movespeed = self:GetAbility():GetSpecialValueFor("movement_slow")
	self.msReduction = self.tick * self.movespeed / self:GetRemainingTime()
	self.tick_damage = self:GetAbility():GetSpecialValueFor("tick_damage")
	
	self.talent1 = self:GetCaster():HasTalent("special_bonus_unique_venomancer_venomous_gale_1")
	self.talent1Val = self:GetCaster():FindTalentValue("special_bonus_unique_venomancer_venomous_gale_1")
end

function modifier_venomancer_venomous_gale_cancer:OnDestroy()
	if IsServer() then
		local caster = self:GetCaster()
		local parent = self:GetParent()
		if caster:IsRealHero( ) and caster:HasScepter( ) and not parent:IsMinion() then
			local ward = caster:FindAbilityByName("venomancer_plague_ward_ebf")
			if ward then
				for i = 1, self:GetTalentSpecialValueFor("scepter_wards_spawned") do
					local position  = parent:GetAbsOrigin() + RandomVector(250)
					caster:SetCursorPosition( position )
					ward:OnSpellStart( )
				end
			end
		end
	end
end

function modifier_venomancer_venomous_gale_cancer:OnIntervalThink()
	self.movespeed = math.min( self.movespeed - self.msReduction, 0 )
	if IsServer() then 
		local caster = self:GetCaster()
		local damage = self.tick_damage
		if not caster:IsRealHero() then
			local owner = caster:GetOwnerEntity()
			if owner:HasTalent("special_bonus_unique_venomancer_plague_ward_2") then
				damage = damage * owner:FindTalentValue("special_bonus_unique_venomancer_plague_ward_2", "value2") / 100
			end
		end
		self:GetAbility():DealDamage( caster, self:GetParent(), damage )
	end
end

function modifier_venomancer_venomous_gale_cancer:DeclareFunctions()
	funcs = {
				MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
				MODIFIER_EVENT_ON_TAKEDAMAGE 
			}
	return funcs
end

function modifier_venomancer_venomous_gale_cancer:GetModifierMoveSpeedBonus_Percentage()
	return self.movespeed
end

function modifier_venomancer_venomous_gale_cancer:OnTakeDamage(params)
	if params.unit == self:GetParent() and self.talent1 then
		if params.inflictor == self:GetAbility() then
			local poisonNova = params.unit:FindModifierByName("modifier_venomancer_poison_nova_cancer")
			if poisonNova then
				poisonNova:SetDuration( poisonNova:GetRemainingTime() + self.talent1Val, true )
			end
			local poisonSting = params.unit:FindModifierByName("modifier_venomancer_poison_sting_cancer")
			if poisonSting then
				poisonSting:SetDuration( poisonSting:GetRemainingTime() + self.talent1Val, true )
			end
		elseif params.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK and params.attacker:GetUnitName() == "npc_dota_venomancer_plague_ward_1" then
			local kill = params.attacker:FindModifierByName("modifier_kill")
			if kill then
				kill:SetDuration( kill:GetRemainingTime() + self.talent1Val, true )
			end
			local summon = params.attacker:FindModifierByName("modifier_summon_handler")
			if summon then
				summon:SetDuration( summon:GetRemainingTime() + self.talent1Val, true )
			end
		end
	end
end

function modifier_venomancer_venomous_gale_cancer:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_venomancer_venomous_gale_cancer:GetEffectName()
	return "particles/units/heroes/hero_venomancer/venomancer_gale_poison_debuff.vpcf"
end