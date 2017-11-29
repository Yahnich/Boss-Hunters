venomancer_venomous_gale_ebf = class({})

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
			if caster:HasTalent("special_bonus_unique_venomancer_5") then
				local ward = caster:FindAbilityByName("venomancer_plague_ward")
				for i = 1, 2 do
					caster:SetCursorPosition( hTarget:GetAbsOrigin() + RandomVector(250) )
					ward:OnSpellStart()
				end
			end
		end
		return false
	end
end

LinkLuaModifier( "modifier_venomancer_venomous_gale_cancer", "lua_abilities/heroes/venomancer.lua" ,LUA_MODIFIER_MOTION_NONE )
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

venomancer_poison_sting_ebf = class({})

function venomancer_poison_sting_ebf:GetIntrinsicModifierName()
	return "modifier_venomancer_poison_sting_handler"
end

LinkLuaModifier( "modifier_venomancer_poison_sting_handler", "lua_abilities/heroes/venomancer.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_venomancer_poison_sting_handler = class({})

function modifier_venomancer_poison_sting_handler:OnCreated()
	self.duration = self:GetAbility():GetSpecialValueFor("duration")
	self.initial = self:GetAbility():GetSpecialValueFor("initial_stacks")
end

function modifier_venomancer_poison_sting_handler:OnRefresh()
	self.duration = self:GetAbility():GetSpecialValueFor("duration")
	self.initial = self:GetAbility():GetSpecialValueFor("initial_stacks")
end

function modifier_venomancer_poison_sting_handler:IsHidden()
	return true
end

function modifier_venomancer_poison_sting_handler:DeclareFunctions()
	funcs = {
				MODIFIER_EVENT_ON_ATTACK_LANDED
			}
	return funcs
end

function modifier_venomancer_poison_sting_handler:OnAttackLanded(params)
	if IsServer() then
		if params.attacker == self:GetParent() then
			if params.target:HasModifier("modifier_venomancer_poison_sting_cancer") then
				local modifier = params.target:FindModifierByName("modifier_venomancer_poison_sting_cancer")
				modifier:IncrementStackCount()
				modifier:SetDuration(self.duration, true)
			elseif params.target:IsAlive() then
				local caster = self:GetParent()
				if not caster:IsHero() then caster = caster:GetOwnerEntity() end
				local modifier = params.target:AddNewModifier(caster, caster:FindAbilityByName("venomancer_poison_sting_ebf"), "modifier_venomancer_poison_sting_cancer", {duration = self.duration})
				modifier:SetStackCount(self.initial)
			end
		end
	end
end

LinkLuaModifier( "modifier_venomancer_poison_sting_cancer", "lua_abilities/heroes/venomancer.lua", LUA_MODIFIER_MOTION_NONE)
modifier_venomancer_poison_sting_cancer = class({})

function modifier_venomancer_poison_sting_cancer:OnCreated()
	self.damage = self:GetAbility():GetSpecialValueFor("damage_stack")
	self.slow = self:GetAbility():GetSpecialValueFor("ms_stack")
	self.mr = self:GetAbility():GetSpecialValueFor("mr_stack")
	if IsServer() then
		self:StartIntervalThink(1)
	end
end

function modifier_venomancer_poison_sting_cancer:OnIntervalThink()
	if IsServer() then
		ApplyDamage({victim = self:GetParent(), attacker = self:GetCaster(), damage = self.damage * self:GetStackCount(), damage_type = self:GetAbility():GetAbilityDamageType(), ability = self:GetAbility()})
	end
end

function modifier_venomancer_poison_sting_cancer:DeclareFunctions()
	funcs = {
				MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
				MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS
			}
	return funcs
end

function modifier_venomancer_poison_sting_cancer:GetModifierMoveSpeedBonus_Percentage()
	return self.slow * self:GetStackCount()
end

function modifier_venomancer_poison_sting_cancer:GetModifierMagicalResistanceBonus()
	return self.mr * self:GetStackCount()
end

venomancer_poison_nova_ebf = class({})

if IsServer() then
	function venomancer_poison_nova_ebf:OnSpellStart()
		local caster = self:GetCaster()
		
		local radius = self:GetTalentSpecialValueFor("start_radius")
		local maxRadius = self:GetTalentSpecialValueFor("radius")
		local radiusGrowth = self:GetTalentSpecialValueFor("speed") * 0.1
		local duration = self:GetTalentSpecialValueFor("duration")
		if caster:HasScepter() then duration = self:GetTalentSpecialValueFor("duration_scepter") end
		local enemies = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, maxRadius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 0, 0, false)
		for _,enemy in pairs(enemies) do
			enemy:AddNewModifier(caster, self, "modifier_venomancer_poison_nova_cancer", {duration = duration})
			EmitSoundOn( "Hero_Venomancer.PoisonNovaImpact", self:GetCaster() )
		end
		EmitSoundOn( "Hero_Venomancer.PoisonNova", self:GetCaster() )
		
		
		local novaCast = ParticleManager:CreateParticle( "particles/units/heroes/hero_venomancer/venomancer_poison_nova_cast.vpcf", PATTACH_POINT_FOLLOW, caster )
		ParticleManager:ReleaseParticleIndex( novaCast )
		
		local novaCloud = ParticleManager:CreateParticle( "particles/units/heroes/hero_venomancer/venomancer_poison_nova.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster )
			ParticleManager:SetParticleControlEnt(novaCloud, 0, caster, PATTACH_POINT_FOLLOW, "attach_origin", caster:GetAbsOrigin(), true)
			ParticleManager:SetParticleControl(novaCloud, 1, Vector(maxRadius,1,maxRadius) )
			ParticleManager:SetParticleControl(novaCloud, 2, caster:GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex(novaCloud)
	end
end

LinkLuaModifier( "modifier_venomancer_poison_nova_cancer", "lua_abilities/heroes/venomancer.lua", LUA_MODIFIER_MOTION_NONE)
modifier_venomancer_poison_nova_cancer = class({})

function modifier_venomancer_poison_nova_cancer:OnCreated()
	self.damage = self:GetAbility():GetSpecialValueFor("damage")
	if self:GetCaster():HasScepter() then self.damage = self:GetAbility():GetSpecialValueFor("damage_scepter") end
	if IsServer() then
		self:StartIntervalThink(1)
	end
end

function modifier_venomancer_poison_nova_cancer:OnIntervalThink()
	if IsServer() then
		ApplyDamage({victim = self:GetParent(), attacker = self:GetCaster(), damage = self.damage, damage_type = self:GetAbility():GetAbilityDamageType(), ability = self:GetAbility()})
	end
end

function modifier_venomancer_poison_nova_cancer:GetEffectName()
	return "particles/units/heroes/hero_venomancer/venomancer_poison_debuff_nova.vpcf"
end

function modifier_venomancer_poison_nova_cancer:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end