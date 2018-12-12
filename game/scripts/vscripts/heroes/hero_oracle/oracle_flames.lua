oracle_flames = class({})
LinkLuaModifier("modifier_oracle_flames_handle", "heroes/hero_oracle/oracle_flames", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_oracle_flames", "heroes/hero_oracle/oracle_flames", LUA_MODIFIER_MOTION_NONE)

function oracle_flames:IsStealable()
    return true
end

function oracle_flames:IsHiddenWhenStolen()
    return false
end

function oracle_flames:GetBehavior()
    if self:GetCaster():HasScepter() then
    	return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_AUTOCAST
    end
    return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
end

function oracle_flames:GetIntrinsicModifierName()
    return "modifier_oracle_flames_handle"
end

function oracle_flames:GetAbilityDamageType()
    if self:GetCaster():HasTalent("special_bonus_unique_oracle_flames_2") then
		return DAMAGE_TYPE_PURE
	end
	return DAMAGE_TYPE_MAGICAL
end

function oracle_flames:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	
	EmitSoundOn("Hero_Oracle.PurifyingFlames.Damage", target)

	ParticleManager:FireParticle("particles/units/heroes/hero_oracle/oracle_purifyingflames_cast.vpcf", PATTACH_POINT_FOLLOW, caster, {[1]="attach_attack1"})

	local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_oracle/oracle_purifyingflames_hit.vpcf", PATTACH_POINT, caster)
				ParticleManager:SetParticleControlEnt(nfx, 0, target, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
				ParticleManager:SetParticleControlEnt(nfx, 1, target, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
				ParticleManager:SetParticleControlEnt(nfx, 2, target, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
				ParticleManager:SetParticleControlEnt(nfx, 4, target, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
				ParticleManager:ReleaseParticleIndex(nfx)

	target:AddNewModifier(caster, self, "modifier_oracle_flames", {Duration = self:GetTalentSpecialValueFor("duration")})

	if target:GetTeam() == caster:GetTeam() then
		self:DealDamage(caster, target, self:GetTalentSpecialValueFor("damage"), {damage_flags = DOTA_DAMAGE_FLAG_NON_LETHAL}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
	else
		self:DealDamage(caster, target, self:GetTalentSpecialValueFor("damage"), {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
	end
end

modifier_oracle_flames_handle = class({})
function modifier_oracle_flames_handle:OnCreated(table)
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end

function modifier_oracle_flames_handle:OnIntervalThink()
	local caster = self:GetCaster()
	local ability = self:GetAbility()

	if caster:IsAlive() and caster:HasScepter() and ability:GetAutoCastState() and ability:IsOwnersManaEnough() and ability:IsCooldownReady() then
		if not caster:IsChanneling() and not caster:IsMoving() then
			if caster:HasModifier("modifier_oracle_innate_offense") then
				if caster:GetAttackTarget() then
					ability:CastSpell(caster:GetAttackTarget())
				end

			elseif caster:HasModifier("modifier_oracle_innate_defense") then
				local allies = caster:FindFriendlyUnitsInRadius(caster:GetAbsOrigin(), ability:GetTrueCastRange())
				for _,ally in pairs(allies) do
					ability:CastSpell(ally)
					break
				end

			end
		end
	end
end

function modifier_oracle_flames_handle:IsHidden()
	return true
end

function modifier_oracle_flames_handle:IsPurgable()
	return false
end

function modifier_oracle_flames_handle:IsPurgeException()
	return false
end

modifier_oracle_flames = class({})
function modifier_oracle_flames:OnCreated(table)
	self.attribute = MODIFIER_ATTRIBUTE_NONE

	if self:GetCaster():HasTalent("special_bonus_unique_oracle_flames_1") then
		self.attribute = MODIFIER_ATTRIBUTE_MULTIPLE
	end

	if IsServer() then
		EmitSoundOn("Hero_Oracle.PurifyingFlames", self:GetParent())

		self.heal = self:GetTalentSpecialValueFor("heal")
		self:StartIntervalThink(1)
	end
end

function modifier_oracle_flames:OnRefresh(table)
	if IsServer() then
		StopSoundOn("Hero_Oracle.PurifyingFlames", self:GetParent())
		EmitSoundOn("Hero_Oracle.PurifyingFlames", self:GetParent())
		
		self.heal = self:GetTalentSpecialValueFor("heal")
	end
end

function modifier_oracle_flames:OnIntervalThink()
	self:GetParent():HealEvent(self.heal, self:GetAbility(), self:GetCaster(), false)
end

function modifier_oracle_flames:OnRemoved()
	StopSoundOn("Hero_Oracle.PurifyingFlames", self:GetParent())
end

function modifier_oracle_flames:GetEffectName()
	return "particles/units/heroes/hero_oracle/oracle_purifyingflames.vpcf"
end

function modifier_oracle_flames:GetAttributes()
	return self.attribute
end

function modifier_oracle_flames:IsDebuff()
	return false
end

function modifier_oracle_flames:IsPurgable()
	return true
end