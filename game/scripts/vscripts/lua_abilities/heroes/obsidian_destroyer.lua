obsidian_destroyer_arcane_orb_ebf = class({})

function obsidian_destroyer_arcane_orb_ebf:GetIntrinsicModifierName()
	return "modifier_obsidian_destroyer_autocast"
end

function obsidian_destroyer_arcane_orb_ebf:OnSpellStart()
	local target = self:GetCursorTarget()
	self:LaunchArcaneOrb(target, true)
end

function obsidian_destroyer_arcane_orb_ebf:IsStealable()
	return false
end

function obsidian_destroyer_arcane_orb_ebf:GetCastRange(location, target)
	return self:GetCaster():GetAttackRange()
end

function obsidian_destroyer_arcane_orb_ebf:GetAOERadius()
	return self:GetSpecialValueFor("int_splash_radius")	
end

function obsidian_destroyer_arcane_orb_ebf:LaunchArcaneOrb(target, bAttack)
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

function obsidian_destroyer_arcane_orb_ebf:OnProjectileHit(target, position)
	if target then
		local caster = self:GetCaster()
		ParticleManager:FireParticle("particles/units/hero_obsidian_destroyer/obsidian_destroyer_arcane_orb_aoe.vpcf", PATTACH_POINT_FOLLOW, target)
		self:DealDamage(caster, target, caster:GetMana() * self:GetSpecialValueFor("mana_pool_damage_pct") / 100)
		for _, enemy in ipairs( caster:FindEnemyUnitsInRadius(target:GetAbsOrigin(), self:GetSpecialValueFor("int_splash_radius")) ) do
			if enemy ~= target then
				self:DealDamage(caster, enemy, self:GetSpecialValueFor("int_splash") * caster:GetIntellect() / 100)
			end
		end
	end
end

modifier_obsidian_destroyer_autocast = class({})
LinkLuaModifier("modifier_obsidian_destroyer_autocast", "lua_abilities/heroes/obsidian_destroyer.lua", 0)

function modifier_obsidian_destroyer_autocast:IsHidden()
	return true
end

if IsServer() then
	function modifier_obsidian_destroyer_autocast:OnCreated()
		self:StartIntervalThink(0.03)
	end
	
	function modifier_obsidian_destroyer_autocast:OnIntervalThink()
		local caster = self:GetCaster()
		if self:GetAbility():GetAutoCastState() then
			caster:SetProjectileModel("particles/empty_projectile.vcpf")
		else
			caster:SetProjectileModel("particles/units/heroes/hero_obsidian_destroyer/obsidian_destroyer_base_attack.vpcf")
		end
	end
	
	function modifier_obsidian_destroyer_autocast:DeclareFunctions()
		return {MODIFIER_EVENT_ON_ATTACK}
	end
	
	function modifier_obsidian_destroyer_autocast:OnAttack(params)
		if params.attacker == self:GetParent() and params.target and self:GetAbility():GetAutoCastState() then
			self:GetAbility():LaunchArcaneOrb(params.target)
		end
	end
end

obsidian_destroyer_astral_imprisonment_ebf = class({})

function obsidian_destroyer_astral_imprisonment_ebf:OnSpellStart()
	if IsServer() then
		local hTarget = self:GetCursorTarget()
		EmitSoundOn("Hero_ObsidianDestroyer.AstralImprisonment.Cast", self:GetCaster())
		local flash = ParticleManager:CreateParticle("particles/units/heroes/hero_obsidian_destroyer/obsidian_destroyer_prison_start.vpcf", PATTACH_ABSORIGIN , hTarget)
			ParticleManager:SetParticleControl(flash, 0, hTarget:GetAbsOrigin())
			ParticleManager:SetParticleControl(flash, 1, hTarget:GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex(flash)
		if hTarget:GetTeam() == self:GetCaster():GetTeam() then
			hTarget:AddNewModifier(self:GetCaster(), self, "modifier_obsidian_destroyer_astral_imprisonment_prison", {duration = self:GetTalentSpecialValueFor("prison_duration")})
		else
			local modifier = self:GetCaster():AddNewModifier(self:GetCaster(), self,"modifier_obsidian_destroyer_astral_imprisonment_int_gain", {duration = self:GetTalentSpecialValueFor("steal_duration")})
			modifier:IncrementStackCount()
			local endFlash = ParticleManager:CreateParticle("particles/units/heroes/hero_obsidian_destroyer/obsidian_destroyer_prison_end.vpcf", PATTACH_ABSORIGIN , hTarget)
				ParticleManager:SetParticleControl(endFlash, 0, hTarget:GetAbsOrigin())
			ParticleManager:ReleaseParticleIndex(endFlash)
			EmitSoundOn("Hero_ObsidianDestroyer.AstralImprisonment.End", hTarget)
			hTarget:AddNewModifier(self:GetCaster(), self,"modifier_stunned", {duration = self:GetTalentSpecialValueFor("prison_duration") / 2})
			local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), hTarget:GetAbsOrigin(), nil, self:GetTalentSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
			for _,enemy in pairs(enemies) do
				ApplyDamage({victim = enemy, attacker = self:GetCaster(), damage = self:GetSpecialValueFor("damage"), damage_type = self:GetAbilityDamageType(), ability = self})
			end
		end
	end
end

LinkLuaModifier( "modifier_obsidian_destroyer_astral_imprisonment_int_gain", "lua_abilities/heroes/obsidian_destroyer.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_obsidian_destroyer_astral_imprisonment_int_gain = class({})

function modifier_obsidian_destroyer_astral_imprisonment_int_gain:OnCreated()
	self.intgain = self:GetAbility():GetSpecialValueFor("int_gain")
	if IsServer() then
		self.buff = ParticleManager:CreateParticle("particles/obsidian_imprisonment_buff.vpcf", PATTACH_ABSORIGIN_FOLLOW , self:GetParent())
			ParticleManager:SetParticleControl(self.buff, 0, self:GetParent():GetAbsOrigin())
			ParticleManager:SetParticleControlEnt(self.buff, 12, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetParent():GetAbsOrigin(), true)
		self.expireTime = self:GetAbility():GetTalentSpecialValueFor("steal_duration")
		self.intTable = {}
		table.insert(self.intTable, GameRules:GetGameTime())
		self:StartIntervalThink(0.1)
	end
end

function modifier_obsidian_destroyer_astral_imprisonment_int_gain:OnRefresh()
	self.intgain = self:GetAbility():GetSpecialValueFor("int_gain")
	if IsServer() then
		table.insert(self.intTable, GameRules:GetGameTime())
	end
end

function modifier_obsidian_destroyer_astral_imprisonment_int_gain:OnIntervalThink()
	if #self.intTable > 0 then
		for i = #self.intTable, 1, -1 do
			if self.intTable[i] + self.expireTime < GameRules:GetGameTime() then
				table.remove(self.intTable, i)		
			end
		end
		self:SetStackCount(#self.intTable)
		if #self.intTable == 0 then
			self:Destroy()
		end
		self:GetParent():CalculateStatBonus()
	else
		self:Destroy()
	end
end

function modifier_obsidian_destroyer_astral_imprisonment_int_gain:OnDestroy()
	if IsServer() then
		ParticleManager:DestroyParticle(self.buff, false)
		ParticleManager:ReleaseParticleIndex(self.buff)
	end
end

function modifier_obsidian_destroyer_astral_imprisonment_int_gain:DeclareFunctions()
	funcs = {
				MODIFIER_PROPERTY_STATS_INTELLECT_BONUS
			}
	return funcs
end

function modifier_obsidian_destroyer_astral_imprisonment_int_gain:GetModifierBonusStats_Intellect()
	return self.intgain * self:GetStackCount()
end

LinkLuaModifier( "modifier_obsidian_destroyer_astral_imprisonment_prison", "lua_abilities/heroes/obsidian_destroyer.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_obsidian_destroyer_astral_imprisonment_prison = class({})

function modifier_obsidian_destroyer_astral_imprisonment_prison:OnCreated()
	if IsServer() then
		EmitSoundOn("Hero_ObsidianDestroyer.AstralImprisonment", hTarget)
	end
end

function modifier_obsidian_destroyer_astral_imprisonment_prison:OnDestroy()
	if IsServer() then
		local endFlash = ParticleManager:CreateParticle("particles/units/heroes/hero_obsidian_destroyer/obsidian_destroyer_prison_end.vpcf", PATTACH_ABSORIGIN , hTarget)
				ParticleManager:SetParticleControl(endFlash, 0, hTarget:GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex(endFlash)
		EmitSoundOn("Hero_ObsidianDestroyer.AstralImprisonment.End", hTarget)
		local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), hTarget:GetAbsOrigin(), nil, self:GetTalentSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
		for _,enemy in pairs(enemies) do
			ApplyDamage({victim = enemy, attacker = self:GetCaster(), damage = self:GetSpecialValueFor("damage"), damage_type = self:GetAbilityDamageType(), ability = self})
		end
	end
end

function modifier_obsidian_destroyer_astral_imprisonment_prison:CheckState()
	local state = {
		[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_OUT_OF_GAME] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_ATTACK_IMMUNE] = true
	}
	return state
end

function modifier_obsidian_destroyer_astral_imprisonment_prison:GetEffectName()
	return "particles/units/heroes/hero_obsidian_destroyer/obsidian_destroyer_prison.vpcf"
end

obsidian_destroyer_essence_aura_ebf = class({})

function  obsidian_destroyer_essence_aura_ebf:GetIntrinsicModifierName()
	return "modifier_obsidian_destroyer_essence_aura_ebf_passive"
end

function obsidian_destroyer_essence_aura_ebf:OnSpellStart()
	self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_obsidian_destroyer_essence_aura_ebf_active", {duration = self:GetSpecialValueFor("buff_duration")})
end

modifier_obsidian_destroyer_essence_aura_ebf_active = class({})
LinkLuaModifier("modifier_obsidian_destroyer_essence_aura_ebf_active", "lua_abilities/heroes/obsidian_destroyer", 0)

function modifier_obsidian_destroyer_essence_aura_ebf_active:OnCreated()
	if IsServer() then
		ParticleManager:FireParticle("particles/units/heroes/hero_obsidian_destroyer/obsidian_destroyer_essence_effect.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
	end
end

function modifier_obsidian_destroyer_essence_aura_ebf_active:DeclareFunctions()
	return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
end

function modifier_obsidian_destroyer_essence_aura_ebf_active:GetModifierIncomingDamage_Percentage(params)
	if params.damage < self:GetParent():GetMana() then
		self:GetParent():SpendMana(params.damage, self:GetAbility() )
		return -100
	else
		local dmgPct = self:GetParent():GetMana() / params.damage
		self:GetParent():SpendMana(self:GetParent():GetMana(), self:GetAbility() )
		return -(100 - dmgPct*100)
	end
end

function modifier_obsidian_destroyer_essence_aura_ebf_active:GetStatusEffectName()
	return "particles/status_fx/status_effect_siren_song.vpcf"
end

function modifier_obsidian_destroyer_essence_aura_ebf_active:StatusEffectPriority()
	return 10
end

function modifier_obsidian_destroyer_essence_aura_ebf_active:GetEffectName()
	return "particles/units/heroes/hero_obsidian_destroyer/obsidian_destroyer_avatar.vpcf"
end

modifier_obsidian_destroyer_essence_aura_ebf_passive = class({})
LinkLuaModifier("modifier_obsidian_destroyer_essence_aura_ebf_passive", "lua_abilities/heroes/obsidian_destroyer", 0)


function modifier_obsidian_destroyer_essence_aura_ebf_passive:OnCreated()
	self.mana = self:GetSpecialValueFor("bonus_mana")
	self.manaregen = self:GetSpecialValueFor("bonus_mana_regen")
	self.spellamp = self:GetSpecialValueFor("bonus_spell_amp")
	if IsServer() then self:StartIntervalThink(0.1) end
end

function modifier_obsidian_destroyer_essence_aura_ebf_passive:OnRefresh()
	self.mana = self:GetSpecialValueFor("bonus_mana")
	self.manaregen = self:GetSpecialValueFor("bonus_mana_regen")
	self.spellamp = self:GetSpecialValueFor("bonus_spell_amp")
end

function modifier_obsidian_destroyer_essence_aura_ebf_passive:OnIntervalThink()
	if self:GetAbility():IsCooldownReady() then
		self:SetStackCount( 0 )
	else
		self:SetStackCount( 1 )
	end
end
	
function modifier_obsidian_destroyer_essence_aura_ebf_passive:IsHidden()
	return self:GetStackCount() == 1
end

function modifier_obsidian_destroyer_essence_aura_ebf_passive:DeclareFunctions()
	return {MODIFIER_PROPERTY_MANA_BONUS, MODIFIER_PROPERTY_MANA_REGEN_CONSTANT, MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE	}
end

function modifier_obsidian_destroyer_essence_aura_ebf_passive:GetModifierManaBonus()
	if not self:IsHidden() then
		return self.mana
	end
end

function modifier_obsidian_destroyer_essence_aura_ebf_passive:GetModifierConstantManaRegen()
	if not self:IsHidden() then
		return self.manaregen
	end
end

function modifier_obsidian_destroyer_essence_aura_ebf_passive:GetModifierSpellAmplify_Percentage()
	if not self:IsHidden() then
		return self.spellamp
	end
end

obsidian_destroyer_sanitys_eclipse_ebf = class({})

function obsidian_destroyer_sanitys_eclipse_ebf:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end

function obsidian_destroyer_sanitys_eclipse_ebf:OnSpellStart()
	if IsServer() then
		EmitSoundOn("Hero_ObsidianDestroyer.SanityEclipse.Cast", self:GetCaster())
		local vTarget = self:GetCursorPosition()
		local radius = self:GetTalentSpecialValueFor("radius")
		local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), vTarget, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
		if self:GetCaster():HasScepter() then
			local imprison = self:GetCaster():FindAbilityByName("obsidian_destroyer_astral_imprisonment_ebf")
			for _,enemy in pairs(enemies) do
				self:GetCaster():SetCursorCastTarget(enemy)
				imprison:OnSpellStart()
			end
			self:GetCaster():CalculateStatBonus()
		end
		local intDamage = self:GetTalentSpecialValueFor("damage_multiplier") * self:GetCaster():GetIntellect()
		for _,enemy in pairs(enemies) do
			ApplyDamage({victim = enemy, attacker = self:GetCaster(), damage = intDamage, damage_type = self:GetAbilityDamageType(), ability = self})
			enemy:AddNewModifier(self:GetCaster(), self, "modifier_obsidian_destroyer_sanitys_eclipse_mindbreak", {duration = self:GetTalentSpecialValueFor("debuff_duration")})
		end
		local eclipse = ParticleManager:CreateParticle("particles/units/heroes/hero_obsidian_destroyer/obsidian_destroyer_sanity_eclipse_area.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
			ParticleManager:SetParticleControl(eclipse, 0, vTarget)
			ParticleManager:SetParticleControl(eclipse, 1, Vector(radius, 0, 0))
			ParticleManager:SetParticleControl(eclipse, 2, Vector(radius, 0, 0))
			ParticleManager:SetParticleControl(eclipse, 3, Vector(radius, 0, 0))
		ParticleManager:ReleaseParticleIndex(eclipse)
		EmitSoundOn("Hero_ObsidianDestroyer.SanityEclipse", self:GetCaster())
	end
end

LinkLuaModifier( "modifier_obsidian_destroyer_sanitys_eclipse_mindbreak", "lua_abilities/heroes/obsidian_destroyer.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_obsidian_destroyer_sanitys_eclipse_mindbreak = class({})

function modifier_obsidian_destroyer_sanitys_eclipse_mindbreak:OnCreated()
	if IsServer() then
		EmitSoundOn("DOTA_Item.SilverEdge.Target", self:GetParent())
		EmitSoundOn("Hero_ObsidianDestroyer.EssenceAura", self:GetParent())
	end
end

function modifier_obsidian_destroyer_sanitys_eclipse_mindbreak:GetEffectName()
	return "particles/obsidian_mindbreak.vpcf"
end

function modifier_obsidian_destroyer_sanitys_eclipse_mindbreak:CheckState()
	local state = {
		[MODIFIER_STATE_PASSIVES_DISABLED] = true,
		[MODIFIER_STATE_SILENCED] = true
	}
	return state
end