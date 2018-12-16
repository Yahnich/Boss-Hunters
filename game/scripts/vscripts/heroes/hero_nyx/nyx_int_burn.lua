nyx_int_burn = class({})
LinkLuaModifier( "modifier_nyx_int_burn", "heroes/hero_nyx/nyx_int_burn.lua" ,LUA_MODIFIER_MOTION_NONE )

function nyx_int_burn:IsStealable()
	return true
end

function nyx_int_burn:GetCastRange(vLocation, hTarget)
	if self:GetCaster():HasModifier("modifier_nyx_burrow") then
		return self:GetTalentSpecialValueFor("range") + self:GetTalentSpecialValueFor("burn_range")
	end
	return self:GetTalentSpecialValueFor("range")
end

function nyx_int_burn:GetBehavior()
	local caster = self:GetCaster()
	if caster:HasModifier("modifier_nyx_burrow") then
		return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE + DOTA_ABILITY_BEHAVIOR_UNRESTRICTED
	else
		return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING
	end
end

function nyx_int_burn:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	local damage = caster:GetIntellect() * self:GetTalentSpecialValueFor("damage")

	EmitSoundOn("Hero_NyxAssassin.ManaBurn.Cast", caster)
	EmitSoundOn("Hero_NyxAssassin.ManaBurn.Cast", target)

	local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_nyx_assassin/nyx_assassin_mana_burn.vpcf", PATTACH_POINT, caster)
				ParticleManager:SetParticleControlEnt(nfx, 0, target, PATTACH_POINT, "attach_hitloc", target:GetAbsOrigin(), true)
				ParticleManager:ReleaseParticleIndex(nfx)

	ParticleManager:FireParticle("particles/units/heroes/hero_nyx_assassin/nyx_assassin_mana_burn_start.vpcf", PATTACH_POINT_FOLLOW, caster, {[0]="attach_mouth"})

	target:Purge(true, false, false, false, true)
	--target:ReduceMana(damage)
	self:DealDamage(caster, target, damage, {}, OVERHEAD_ALERT_MANA_LOSS)
	if caster:HasTalent("special_bonus_unique_nyx_int_burn_1") then
		target:Silence(self, caster, caster:FindTalentValue("special_bonus_unique_nyx_int_burn_1"), false)
	end
	if caster:HasTalent("special_bonus_unique_nyx_int_burn_2") then
		target:AddNewModifier(caster, self, "modifier_nyx_int_burn", {Duration = caster:FindTalentValue("special_bonus_unique_nyx_int_burn_2","duration")})
	end

	if caster:HasModifier("modifier_nyx_burrow") then
		local enemies = caster:FindEnemyUnitsInRadius(target:GetAbsOrigin(), self:GetSpecialValueFor("burn_radius"))
		for _,enemy in pairs(enemies) do
			if enemy ~= target then
				enemy:Purge(true, false, false, false, true)
				--enemy:ReduceMana(damage)
				self:DealDamage(caster, enemy, damage, {}, OVERHEAD_ALERT_MANA_LOSS)
				if caster:HasTalent("special_bonus_unique_nyx_int_burn_1") then
					enemy:Silence(self, caster, caster:FindTalentValue("special_bonus_unique_nyx_int_burn_1"), false)
				end
				if caster:HasTalent("special_bonus_unique_nyx_int_burn_2") then
					enemy:AddNewModifier(caster, self, "modifier_nyx_int_burn", {Duration = caster:FindTalentValue("special_bonus_unique_nyx_int_burn_2","duration")})
				end
			end
		end
	end
end

modifier_nyx_int_burn = class({})
function modifier_nyx_int_burn:OnCreated(table)
	if IsServer() then self:StartIntervalThink(1) end
end

function modifier_nyx_int_burn:OnIntervalThink()
	if IsServer() then
		local damage = self:GetCaster():GetIntellect() * self:GetCaster():FindTalentValue("special_bonus_unique_nyx_int_burn_2", "damage")/100
		self:GetAbility():DealDamage(self:GetCaster(), self:GetParent(), damage, {}, 0)
	end
end

function modifier_nyx_int_burn:GetEffectName()
	return "particles/units/heroes/hero_nyx/nyx_int_burn_debuff.vpcf"
end

function modifier_nyx_int_burn:IsDebuff()
	return true
end