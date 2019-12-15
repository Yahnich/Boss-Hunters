nyx_harden_carapace = class({})
LinkLuaModifier( "modifier_nyx_harden_carapace", "heroes/hero_nyx/nyx_harden_carapace.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_nyx_harden_carapace_armor", "heroes/hero_nyx/nyx_harden_carapace.lua" ,LUA_MODIFIER_MOTION_NONE )

function nyx_harden_carapace:IsStealable()
	return true
end

function nyx_harden_carapace:GetIntrinsicModifierName()
	return "modifier_nyx_harden_carapace_armor"
end

function nyx_harden_carapace:GetBehavior()
	local caster = self:GetCaster()
	if caster:HasModifier("modifier_nyx_burrow") then
		return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE + DOTA_ABILITY_BEHAVIOR_UNRESTRICTED
	else
		return DOTA_ABILITY_BEHAVIOR_NO_TARGET
	end
end

function nyx_harden_carapace:OnSpellStart()
	local caster = self:GetCaster()
	
	EmitSoundOn("Hero_NyxAssassin.SpikedCarapace", caster)

	if caster:HasTalent("special_bonus_unique_nyx_harden_carapace_2") then
		caster:ModifyThreat(caster:FindTalentValue("special_bonus_unique_nyx_harden_carapace_2"))
	end

	caster:AddNewModifier(caster, self, "modifier_nyx_harden_carapace", {Duration = self:GetTalentSpecialValueFor("duration")})

	if caster:HasModifier("modifier_nyx_burrow") then
		EmitSoundOn("Hero_NyxAssassin.Impale.Target", caster)
		ParticleManager:FireParticle("particles/units/heroes/hero_nyx/nyx_harden_carapace_burrow/nyx_harden_carapace_burrow.vpcf", PATTACH_POINT, caster, {[0]=caster:GetAbsOrigin(), [1]=Vector(self:GetSpecialValueFor("carapace_radius"), 0, 0)})
		local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), self:GetSpecialValueFor("carapace_radius"))
		for _,enemy in pairs(enemies) do
			if not target:TriggerSpellAbsorb(self) then
				ParticleManager:FireParticle("particles/units/heroes/hero_nyx/nyx_harden_carapace_hit/nyx_harden_carapace_hit.vpcf", PATTACH_POINT, caster, {[0]=enemy:GetAbsOrigin()})
				self:Stun(enemy, self:GetTalentSpecialValueFor("stun_duration"), false)
				local damage = caster:GetMaxHealth() * self:GetTalentSpecialValueFor("carapace_health")/100
				self:DealDamage(caster, enemy, damage, {damage_type=DAMAGE_TYPE_PURE, damage_flags=DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION}, 0)
			end
		end
	end
end

modifier_nyx_harden_carapace_armor = class({})
function modifier_nyx_harden_carapace_armor:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
	}
	return funcs
end

function modifier_nyx_harden_carapace_armor:GetModifierPhysicalArmorBonus()
	return self:GetSpecialValueFor("bonus_armor")
end

function modifier_nyx_harden_carapace_armor:IsHidden()
	return true
end

function modifier_nyx_harden_carapace_armor:IsPurgable()
	return false
end

function modifier_nyx_harden_carapace_armor:IsPurgeException()
	return false
end

modifier_nyx_harden_carapace = class({})
function modifier_nyx_harden_carapace:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}
	return funcs
end

function modifier_nyx_harden_carapace:OnTakeDamage(params)
	if IsServer() then
		local caster = params.unit
		local attacker = params.attacker
		local damageTaken = params.damage * self:GetTalentSpecialValueFor("damage")/100
		local damageType = params.damage_type
		local stunDuration = self:GetTalentSpecialValueFor("stun_duration")

		if caster == self:GetParent() and not attacker:IsMagicImmune() and attacker ~= caster then
			EmitSoundOn("Hero_NyxAssassin.SpikedCarapace.Stun", caster)
			local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_nyx_assassin/nyx_assassin_spiked_carapace_hit.vpcf", PATTACH_POINT_FOLLOW, caster)
						ParticleManager:SetParticleControlEnt(nfx, 0, attacker, PATTACH_POINT_FOLLOW, "attach_hitloc", attacker:GetAbsOrigin(), true)
						ParticleManager:SetParticleControlEnt(nfx, 1, attacker, PATTACH_POINT_FOLLOW, "attach_hitloc", attacker:GetAbsOrigin(), true)
						ParticleManager:SetParticleControl(nfx, 2, Vector(1,0,0))
						ParticleManager:ReleaseParticleIndex(nfx)

			caster:SetHealth(caster:GetHealth() + damageTaken)
			self:GetAbility():Stun(attacker, stunDuration, false)
			self:GetAbility():DealDamage(caster, attacker, damageTaken, {damage_type=damageType, damage_flags=DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_REFLECTION}, 0)
			
		end
	end
end

function modifier_nyx_harden_carapace:GetEffectName()
	return "particles/units/heroes/hero_nyx_assassin/nyx_assassin_spiked_carapace.vpcf"
end