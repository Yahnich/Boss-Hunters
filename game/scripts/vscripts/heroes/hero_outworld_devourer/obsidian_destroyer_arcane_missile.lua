obsidian_destroyer_arcane_missile = class({})

function obsidian_destroyer_arcane_missile:IsStealable()
	return false
end

function obsidian_destroyer_arcane_missile:IsHiddenWhenStolen()
	return false
end

function obsidian_destroyer_arcane_missile:GetIntrinsicModifierName()
	return "modifier_obsidian_destroyer_arcane_missile_autocast"
end

function obsidian_destroyer_arcane_missile:OnSpellStart()
	local target = self:GetCursorTarget()
	self.forceCast = true
	self:GetCaster():SetAttacking( target )
	self:GetCaster():MoveToTargetToAttack( target )
end

function obsidian_destroyer_arcane_missile:GetCastRange(location, target)
	return self:GetCaster():GetAttackRange()
end

function obsidian_destroyer_arcane_missile:GetAOERadius()
	return self:GetTalentSpecialValueFor("int_splash_radius")	
end

function obsidian_destroyer_arcane_missile:LaunchArcaneOrb(target, bAttack)
	local caster = self:GetCaster()
	caster:SetProjectileModel("particles/empty_projectile.vcpf")
	EmitSoundOn("Hero_ObsidianDestroyer.ArcaneOrb", caster)
	if bAttack then self:GetCaster():PerformGenericAttack(target, false) end
	local projTable = {
		EffectName = "particles/units/heroes/hero_obsidian_destroyer/obsidian_destroyer_arcane_orb.vpcf",
		Ability = self,
		Target = target,
		Source = caster,
		bDodgeable = true,
		bProvidesVision = false,
		vSpawnOrigin = caster:GetAbsOrigin(),
		iMoveSpeed = caster:GetProjectileSpeed(),
		iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
	}
	ProjectileManager:CreateTrackingProjectile( projTable )
	caster:RevertProjectile()
end

function obsidian_destroyer_arcane_missile:OnProjectileHit(target, position)
	if target then
		local caster = self:GetCaster()
		local heal = 0
		local spellsteal = caster:FindTalentValue("special_bonus_unique_obsidian_destroyer_arcane_missile_1") / 100
		local mainDamage = self:DealDamage(caster, target, caster:GetMana() * self:GetTalentSpecialValueFor("mana_pool_damage_pct") / 100, {damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION})
		heal = heal + mainDamage * spellsteal
		if caster:HasTalent("special_bonus_unique_obsidian_destroyer_arcane_missile_2") then
			ParticleManager:FireParticle("particles/units/hero_obsidian_destroyer/obsidian_destroyer_arcane_orb_aoe.vpcf", PATTACH_POINT_FOLLOW, target)
			for _, enemy in ipairs( caster:FindEnemyUnitsInRadius(target:GetAbsOrigin(),  caster:FindTalentValue("special_bonus_unique_obsidian_destroyer_arcane_missile_2", "radius") ) ) do
				if enemy ~= target then
					local aoeDamage = self:DealDamage(caster, enemy, mainDamage * caster:FindTalentValue("special_bonus_unique_obsidian_destroyer_arcane_missile_2")/100, {damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION})
					heal = heal + aoeDamage * spellsteal
				end
			end
		end
		if heal > 0 then
			caster:HealEvent(heal, self, caster)
			ParticleManager:FireParticle("particles/items3_fx/octarine_core_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		end
	end
end

modifier_obsidian_destroyer_arcane_missile_autocast = class({})
LinkLuaModifier("modifier_obsidian_destroyer_arcane_missile_autocast", "heroes/hero_outworld_devourer/obsidian_destroyer_arcane_missile", LUA_MODIFIER_MOTION_NONE)

function modifier_obsidian_destroyer_arcane_missile_autocast:IsHidden()
	return true
end

if IsServer() then
	function modifier_obsidian_destroyer_arcane_missile_autocast:OnCreated()
		self:StartIntervalThink(0.03)
	end
	
	function modifier_obsidian_destroyer_arcane_missile_autocast:OnIntervalThink()
		local caster = self:GetCaster()
		if (self:GetAbility():GetAutoCastState() or self:GetAbility().forceCast) and self:GetParent():GetMana() > self:GetAbility():GetManaCost(-1) and self:GetParent():GetAttackTarget() and not self:GetParent():GetAttackTarget():IsMagicImmune() then
			caster:SetProjectileModel("particles/empty_projectile.vcpf")
		else
			caster:SetProjectileModel("particles/units/heroes/hero_obsidian_destroyer/obsidian_destroyer_base_attack.vpcf")
		end
	end
	
	function modifier_obsidian_destroyer_arcane_missile_autocast:DeclareFunctions()
		return {MODIFIER_EVENT_ON_ATTACK}
	end
	
	function modifier_obsidian_destroyer_arcane_missile_autocast:OnAttack(params)
		if params.attacker == self:GetParent() and params.target and (self:GetAbility():GetAutoCastState() or self:GetAbility().forceCast) and params.attacker:GetMana() > self:GetAbility():GetManaCost(-1) and not self:GetParent():GetAttackTarget():IsMagicImmune() then
			self:GetAbility():LaunchArcaneOrb(params.target)
			if not self:GetAbility().forceCast then
				self:GetAbility():SpendMana()
			end
			self:GetAbility().forceCast = false
		end
	end
end