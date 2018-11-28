--Jacked most of this from imba, cuz i was too lazy to fix it @Sidearms
jakiro_liquid_fire_bh = class({})
LinkLuaModifier("modifier_liquid_fire_caster", "heroes/hero_jakiro/jakiro_liquid_fire_bh", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_liquid_fire_animate", "heroes/hero_jakiro/jakiro_liquid_fire_bh", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_liquid_fire_debuff", "heroes/hero_jakiro/jakiro_liquid_fire_bh", LUA_MODIFIER_MOTION_NONE)

function jakiro_liquid_fire_bh:IsStealable()
	return true
end

function jakiro_liquid_fire_bh:IsHiddenWhenStolen()
	return false
end

function jakiro_liquid_fire_bh:GetIntrinsicModifierName()
	return "modifier_liquid_fire_caster"
end

function jakiro_liquid_fire_bh:OnCreated()
	self.caster = self:GetCaster()
	self.ability = self:GetAbility()
	--cast_liquid_fire used as indicator to apply liquid fire to next attack
	self.cast_liquid_fire = false
end

--[[function jakiro_liquid_fire_bh:GetCastRange(Location, Target)
	local caster = self:GetCaster()
	-- #4 Talent: Liquid Fire Cast Range Increase
	return caster:GetAttackRange() + self:GetTalentSpecialValueFor("extra_cast_range") + caster:FindTalentValue("special_bonus_imba_jakiro_4")
end]]

function jakiro_liquid_fire_bh:OnAbilityPhaseStart()
	local caster = self:GetCaster()
	caster:StartGesture(ACT_DOTA_ATTACK)

	-- Special animation for jakiro
	if caster:GetUnitName() == "npc_dota_hero_jakiro" then
		caster:AddNewModifier(caster, self, "modifier_liquid_fire_animate", {})
	end

	-- Needs to return true for successful cast
	return true
end

function jakiro_liquid_fire_bh:OnAbilityPhaseInterrupted()
	local caster = self:GetCaster()
	caster:RemoveModifierByNameAndCaster("modifier_liquid_fire_animate", caster)
end

function jakiro_liquid_fire_bh:OnSpellStart()
	if IsServer() then
		local target = self:GetCursorTarget()
		local caster = self:GetCaster()

		self.cast_liquid_fire = true

		EmitSoundOn("Hero_Jakiro.LiquidFire", caster)
		self:FireTrackingProjectile("particles/units/heroes/hero_jakiro/jakiro_base_attack_fire.vpcf", target, caster:GetProjectileSpeed(), {}, DOTA_PROJECTILE_ATTACHMENT_ATTACK_2, true, true, 200)	
	end
end

function jakiro_liquid_fire_bh:OnProjectileHit(hTarget, vLocation)
	local caster = self:GetCaster()
	if hTarget then
		EmitSoundOn("Hero_Jakiro.LiquidFire", hTarget)
		local particle_liquid_fire = "particles/units/heroes/hero_jakiro/jakiro_liquid_fire_explosion.vpcf"
		local modifier_liquid_fire_debuff = "modifier_liquid_fire_debuff"
		local duration = self:GetSpecialValueFor("duration")

		-- Parameters
		local radius = self:GetSpecialValueFor("radius")

		-- Play explosion particle
		local fire_pfx = ParticleManager:CreateParticle( particle_liquid_fire, PATTACH_POINT, caster )
		ParticleManager:SetParticleControlEnt(fire_pfx, 0, hTarget, PATTACH_POINT, "attach_hitloc", hTarget:GetAbsOrigin(), true)
		ParticleManager:SetParticleControl( fire_pfx, 1, Vector(radius * 2,0,0) )
		ParticleManager:ReleaseParticleIndex( fire_pfx )

		-- Apply liquid fire modifier to enemies in the area
		local enemies = caster:FindEnemyUnitsInRadius(hTarget:GetAbsOrigin(), radius)
		for _,enemy in pairs(enemies) do
			enemy:AddNewModifier(caster, self, modifier_liquid_fire_debuff, { duration = duration })
		end

		caster:PerformAttack(target, true, true, true, true, false, false, false)
	end
end

modifier_liquid_fire_caster = class({
	IsHidden				= function(self) return true end,
	IsPurgable	  			= function(self) return false end,
	IsDebuff	  			= function(self) return false end,
	RemoveOnDeath 			= function(self) return false end,
	AllowIllusionDuplicate	= function(self) return false end
})

function modifier_liquid_fire_caster:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_START,
		MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_EVENT_ON_ATTACK_FAIL,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_EVENT_ON_ORDER
	}

	return funcs
end

function modifier_liquid_fire_caster:OnCreated()

	self.parent = self:GetParent()
	self.caster = self:GetCaster()
	self.ability = self:GetAbility()
	-- apply_aoe_modifier_debuff_on_hit used as indicator to apply AOE modifier on target hit
	-- { target(key) : times_to_apply_liquid_fire_on_attack_lands (value)}
	-- This is done to allow attacking with liquid fire on correct targets if refresher orb is used
	self.apply_aoe_modifier_debuff_on_hit = {}
	if IsServer() then
		self:StartIntervalThink(0.25)
	end
end

function modifier_liquid_fire_caster:OnIntervalThink()
	if self.particleFX and not self:GetAbility():IsCooldownReady() then
		ParticleManager:ClearParticle( self.particleFX )
		self.particleFX = nil
	elseif not self.particleFX and self:GetAbility():IsCooldownReady() then
		self.particleFX = ParticleManager:CreateParticle("particles/units/heroes/hero_jakiro/jakiro_liquid_fire_ready.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster() )
		ParticleManager:SetParticleControlEnt(self.particleFX, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack2", self:GetCaster():GetAbsOrigin(), true)
	end
end

function modifier_liquid_fire_caster:_IsLiquidFireProjectile()
	local caster = self.caster
	return caster:GetProjectileModel() == "particles/units/heroes/hero_jakiro/jakiro_base_attack_fire.vpcf"
end

function modifier_liquid_fire_caster:OnAttackStart(keys)
	if IsServer() then
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		local target = keys.target
		local attacker = keys.attacker

		if caster == attacker then
			if not ability:IsHidden() and not target:IsMagicImmune() and ability:GetAutoCastState() and ability:IsCooldownReady() then

				-- Special animation for jakiro
				if caster:GetUnitName() == "npc_dota_hero_jakiro" then
					caster:AddNewModifier(caster, ability, "modifier_liquid_fire_animate", {})
				end

				-- Change projectile
				caster:SetProjectileModel("particles/units/heroes/hero_jakiro/jakiro_base_attack_fire.vpcf")
			elseif self:_IsLiquidFireProjectile() then
				-- Revert projectile
				caster:RevertProjectile()
			end
		end
	end
end

function modifier_liquid_fire_caster:OnAttack(keys)
	if IsServer() then
		local caster = self:GetCaster()
		local target = keys.target
		local attacker = keys.attacker
		local ability = self:GetAbility()

		if caster == attacker and (self:_IsLiquidFireProjectile() or ability.cast_liquid_fire) and ability:IsCooldownReady() then
			EmitSoundOn("Hero_Jakiro.LiquidFire", caster)
			-- Remove manual cast indicator
			ability.cast_liquid_fire = false

			-- Apply modifier on next hit
			if self.apply_aoe_modifier_debuff_on_hit[target] == nil then
				self.apply_aoe_modifier_debuff_on_hit[target] = 1;
			else
				self.apply_aoe_modifier_debuff_on_hit[target] = self.apply_aoe_modifier_debuff_on_hit[target] + 1;
			end

			local cooldown = ability:GetCooldown( ability:GetLevel() - 1 ) *  (1 - caster:GetCooldownReduction() * 0.01)

			-- Start cooldown
			ability:StartCooldown( cooldown )
		end
	end
end

function modifier_liquid_fire_caster:_ApplyAOELiquidFire( keys )
	if IsServer() then
		local caster = self.caster
		local attacker = keys.attacker
		local target = keys.target
		local target_liquid_fire_counter = self.apply_aoe_modifier_debuff_on_hit[target]

		if caster == attacker and target_liquid_fire_counter and target_liquid_fire_counter > 0 then
			self.apply_aoe_modifier_debuff_on_hit[target] = target_liquid_fire_counter - 1;
			-- Remove key reference
			if self.apply_aoe_modifier_debuff_on_hit[target] == 0 then
				self.apply_aoe_modifier_debuff_on_hit[target] = nil
			end

			local ability = self.ability

			local ability_level = ability:GetLevel() - 1
			local particle_liquid_fire = "particles/units/heroes/hero_jakiro/jakiro_liquid_fire_explosion.vpcf"
			local modifier_liquid_fire_debuff = "modifier_liquid_fire_debuff"
			local duration = ability:GetLevelSpecialValueFor("duration", ability_level)

			-- Parameters
			local radius = ability:GetLevelSpecialValueFor("radius", ability_level)

			EmitSoundOn("Hero_Jakiro.LiquidFire", target)

			-- Play explosion particle
			local fire_pfx = ParticleManager:CreateParticle( particle_liquid_fire, PATTACH_POINT, caster )
			ParticleManager:SetParticleControlEnt(fire_pfx, 0, target, PATTACH_POINT, "attach_hitloc", target:GetAbsOrigin(), true)
			ParticleManager:SetParticleControl( fire_pfx, 1, Vector(radius * 2,0,0) )
			ParticleManager:ReleaseParticleIndex( fire_pfx )

			-- Apply liquid fire modifier to enemies in the area
			local enemies = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(), nil, radius, ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
			for _,enemy in pairs(enemies) do
				enemy:AddNewModifier(caster, ability, modifier_liquid_fire_debuff, { duration = duration })
			end
		end
	end
end

function modifier_liquid_fire_caster:OnAttackLanded( keys )
	self:_ApplyAOELiquidFire(keys)
end

function modifier_liquid_fire_caster:OnAttackFail( keys )
	self:_ApplyAOELiquidFire(keys)
end

function modifier_liquid_fire_caster:OnOrder(keys)
	local order_type = keys.order_type

	-- On any order apart from attacking target, clear the cast_liquid_fire variable.
	if order_type ~= DOTA_UNIT_ORDER_ATTACK_TARGET then
		self.ability.cast_liquid_fire = false
	end
end

-- Modifier to play animation for jakiro's other head
modifier_liquid_fire_animate = class({
	IsHidden					    = function(self) return true end,
	IsPurgable						= function(self) return false end,
	IsDebuff						= function(self) return false end,
	RemoveOnDeath					= function(self) return true end,
	GetActivityTranslationModifiers	= function(self) return "liquid_fire" end
})

function modifier_liquid_fire_animate:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
		MODIFIER_EVENT_ON_ATTACK
	}

	return funcs
end

function modifier_liquid_fire_animate:OnAttack(keys)
	if IsServer() then
		local attacker = keys.attacker

		if attacker == self:GetCaster() then
			self:Destroy()
		end
	end
end

modifier_liquid_fire_debuff = ({})
function modifier_liquid_fire_debuff:OnCreated(table)
	if IsServer() then
		self:StartIntervalThink(0.5)
	end
end

function modifier_liquid_fire_debuff:OnIntervalThink()
	self:GetAbility():DealDamage(self:GetCaster(), self:GetParent(), self:GetTalentSpecialValueFor("damage")*0.5, {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
end

function modifier_liquid_fire_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
	}
	return funcs
end

function modifier_liquid_fire_debuff:GetModifierAttackSpeedBonus_Constant()
	return self:GetTalentSpecialValueFor("slow_as")
end

function modifier_liquid_fire_debuff:GetEffectName() 
	return "particles/units/heroes/hero_jakiro/jakiro_liquid_fire_debuff.vpcf" 
end

function modifier_liquid_fire_debuff:GetEffectAttachType() 
	return PATTACH_ABSORIGIN_FOLLOW 
end
