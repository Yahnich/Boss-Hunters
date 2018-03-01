obsidian_destroyer_arcane_missile = class({})

function obsidian_destroyer_arcane_missile:GetIntrinsicModifierName()
	return "modifier_obsidian_destroyer_arcane_missile_autocast"
end

function obsidian_destroyer_arcane_missile:OnSpellStart()
	local target = self:GetCursorTarget()
	self:LaunchArcaneOrb(target, true)
end

function obsidian_destroyer_arcane_missile:IsStealable()
	return false
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
		ParticleManager:FireParticle("particles/units/hero_obsidian_destroyer/obsidian_destroyer_arcane_orb_aoe.vpcf", PATTACH_POINT_FOLLOW, target)
		local heal = 0
		local spellsteal = caster:FindTalentValue("special_bonus_unique_outworld_devourer_arcane_orb_1") / 100
		local mainDamage = self:DealDamage(caster, target, caster:GetMana() * self:GetTalentSpecialValueFor("mana_pool_damage_pct") / 100)
		heal = heal + mainDamage * spellsteal
		for _, enemy in ipairs( caster:FindEnemyUnitsInRadius(target:GetAbsOrigin(), self:GetTalentSpecialValueFor("int_splash_radius")) ) do
			if enemy ~= target then
				local aoeDamage = self:DealDamage(caster, enemy, self:GetTalentSpecialValueFor("int_splash") * caster:GetIntellect() / 100)
				heal = heal + aoeDamage * spellsteal
			end
		end
		if heal > 0 then
			caster:HealEvent(heal, self, caster)
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
		if self:GetAbility():GetAutoCastState() then
			caster:SetProjectileModel("particles/empty_projectile.vcpf")
		else
			caster:SetProjectileModel("particles/units/heroes/hero_obsidian_destroyer/obsidian_destroyer_base_attack.vpcf")
		end
	end
	
	function modifier_obsidian_destroyer_arcane_missile_autocast:DeclareFunctions()
		return {MODIFIER_EVENT_ON_ATTACK}
	end
	
	function modifier_obsidian_destroyer_arcane_missile_autocast:OnAttack(params)
		if params.attacker == self:GetParent() and params.target and self:GetAbility():GetAutoCastState() then
			self:GetAbility():LaunchArcaneOrb(params.target)
		end
	end
end