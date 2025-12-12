kunkka_tidebringer_bh = class({})

function kunkka_tidebringer_bh:IsStealable()
    return false
end

function kunkka_tidebringer_bh:GetCastRange(vLocation, hTarget)
    return self:GetSpecialValueFor("distance")
end

function kunkka_tidebringer_bh:GetIntrinsicModifierName()
    return "modifier_kunkka_tidebringer_bh_handle"
end

modifier_kunkka_tidebringer_bh_handle = class({})
LinkLuaModifier("modifier_kunkka_tidebringer_bh_handle", "heroes/hero_kunkka/kunkka_tidebringer_bh", LUA_MODIFIER_MOTION_NONE)
function modifier_kunkka_tidebringer_bh_handle:IsHidden() return true end
function modifier_kunkka_tidebringer_bh_handle:IsDebuff() return false end

function modifier_kunkka_tidebringer_bh_handle:OnCreated(table)
    self:StartIntervalThink(0.1)
end

function modifier_kunkka_tidebringer_bh_handle:OnIntervalThink()
    if IsServer() then
        if self:GetAbility():IsCooldownReady() and (not self:GetParent():HasModifier("modifier_kunkka_tidebringer_bh")) then
			self.damage = self:GetSpecialValueFor("damage_bonus")
            self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_kunkka_tidebringer_bh", {})
		elseif not self:GetAbility():IsCooldownReady() then
			self.damage = 0
        end
    end
end

function modifier_kunkka_tidebringer_bh_handle:DeclareFunctions()
    return {MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE}
end

function modifier_kunkka_tidebringer_bh_handle:GetModifierBaseAttack_BonusDamage()
    return self.damage
end

modifier_kunkka_tidebringer_bh = class({})
function modifier_kunkka_tidebringer_bh:IsDebuff() return false end

function modifier_kunkka_tidebringer_bh:OnCreated(table)
    if IsServer() then
        local caster = self:GetCaster()
        EmitSoundOn("Hero_Kunkaa.Tidebringer", caster)
        AddAnimationTranslate(caster, "tidebringer")
        local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_kunkka/kunkka_weapon_tidebringer.vpcf", PATTACH_POINT_FOLLOW, caster)
                    ParticleManager:SetParticleControlEnt(nfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_tidebringer", caster:GetAbsOrigin(), true)
                    ParticleManager:SetParticleControlEnt(nfx, 2, caster, PATTACH_POINT_FOLLOW, "attach_sword", caster:GetAbsOrigin(), true)
        self:AttachEffect(nfx)
    end
end

function modifier_kunkka_tidebringer_bh:DeclareFunctions()
    return {MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_kunkka_tidebringer_bh:OnAttackLanded(params)
    if IsServer() then
        local caster = params.attacker
        if params.attacker == self:GetCaster() and self:GetAbility():IsCooldownReady() then
            EmitSoundOn("Hero_Kunkka.Tidebringer.Attack", caster)
            ParticleManager:FireParticle("particles/units/heroes/hero_kunkka/kunkka_spell_tidebringer_b.vpcf", PATTACH_POINT, self:GetCaster(), {})
            local damage = params.original_damage * self:GetSpecialValueFor("damage")/100
			local debuffDuration = caster:GetSpecialValueFor("armor_reduction_duration")
			local globalRadius = self:GetSpecialValueFor("end_width") == -1
			if globalRadius then
				local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), -1)
				for _,enemy in pairs(enemies) do
					if enemy ~= params.target then
						EmitSoundOn("Hero_Kunkka.TidebringerDamage", caster)
						local tidebringer_hit_fx = ParticleManager:CreateParticle("particles/units/heroes/hero_kunkka/kunkka_spell_tidebringer.vpcf", PATTACH_CUSTOMORIGIN, caster)
										ParticleManager:SetParticleControlEnt(tidebringer_hit_fx, 0, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true)
										ParticleManager:SetParticleControlEnt(tidebringer_hit_fx, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
										ParticleManager:SetParticleControlForward(tidebringer_hit_fx, 1, caster:GetForwardVector())
										ParticleManager:SetParticleControlEnt(tidebringer_hit_fx, 2, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true)
										ParticleManager:ReleaseParticleIndex(tidebringer_hit_fx)
						self:GetAbility():DealDamage(caster, enemy, damage, {damage_flag = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION})
					end
					if talent1 and not enemy:IsNull() then
						enemy:AddNewModifier(caster, self, "modifier_kunkka_tidebringer_bh_talent", {duration = debuffDuration})
					end
				end
			else
				local enemies = caster:FindEnemyUnitsInCone(caster:GetForwardVector(), caster:GetAbsOrigin(), self:GetSpecialValueFor("end_width"), self:GetSpecialValueFor("distance"), {})
				for _,enemy in pairs(enemies) do
					if enemy ~= params.target then
						EmitSoundOn("Hero_Kunkka.TidebringerDamage", caster)
						local tidebringer_hit_fx = ParticleManager:CreateParticle("particles/units/heroes/hero_kunkka/kunkka_spell_tidebringer.vpcf", PATTACH_CUSTOMORIGIN, caster)
										ParticleManager:SetParticleControlEnt(tidebringer_hit_fx, 0, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true)
										ParticleManager:SetParticleControlEnt(tidebringer_hit_fx, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
										ParticleManager:SetParticleControlForward(tidebringer_hit_fx, 1, caster:GetForwardVector())
										ParticleManager:SetParticleControlEnt(tidebringer_hit_fx, 2, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true)
										ParticleManager:ReleaseParticleIndex(tidebringer_hit_fx)
						self:GetAbility():DealDamage(caster, enemy, damage, {damage_flag = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION}, 0)
					end
					if talent1 and not enemy:IsNull() then
						enemy:AddNewModifier(caster, self, "modifier_kunkka_tidebringer_bh_talent", {duration = debuffDuration})
					end
				end
			end
            self:GetAbility():SetCooldown()
            RemoveAnimationTranslate(self:GetCaster())
            self:Destroy()
        end
    end
end

modifier_kunkka_tidebringer_bh_talent = class({})
LinkLuaModifier("modifier_kunkka_tidebringer_bh", "heroes/hero_kunkka/kunkka_tidebringer_bh", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_kunkka_tidebringer_bh_talent", "heroes/hero_kunkka/kunkka_tidebringer_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_kunkka_tidebringer_bh_talent:OnCreated()
	self.armor = self:GetSpecialValueFor("armor_reduction")
end

function modifier_kunkka_tidebringer_bh_talent:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end

function modifier_kunkka_tidebringer_bh_talent:GetModifierPhysicalArmorBonus()
	return self.armor
end