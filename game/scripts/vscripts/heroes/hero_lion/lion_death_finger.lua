lion_death_finger = class({})
LinkLuaModifier( "modifier_lion_death_finger_root", "heroes/hero_lion/lion_death_finger.lua",LUA_MODIFIER_MOTION_NONE )

function lion_death_finger:IsStealable()
    return true
end

function lion_death_finger:IsHiddenWhenStolen()
    return false
end

function lion_death_finger:GetIntrinsicModifierName()
	return "modifier_lion_death_finger_grow"
end

function lion_death_finger:OnSpellStart()
    local caster = self:GetCaster()

    local point = self:GetCursorPosition()

    local radius = self:GetTalentSpecialValueFor("radius")
	local damage = self:GetTalentSpecialValueFor("damage")
	local growth = caster:FindModifierByName("modifier_lion_death_finger_grow")
	if growth then
		damage = damage + growth:GetStackCount() * 5
	end
    local startPos = caster:GetAbsOrigin()
    local endPos = startPos + CalculateDirection(point, caster)*self:GetTrueCastRange()

    EmitSoundOn("Hero_Lion.FingerOfDeath", caster)
    EmitSoundOnLocationWithCaster(point, "Hero_Lion.FingerOfDeathImpact", caster)

    local enemies = caster:FindEnemyUnitsInLine(startPos, endPos, self:GetTalentSpecialValueFor("radius"), {flag=DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES})
    if #enemies < 1 then
        self:RefundManaCost()
        self:EndCooldown()
    end
	
	if caster:HasScepter() and caster:HasModifier("modifier_lion_mana_aura_scepter") then
		local innate = caster:FindAbilityByName("lion_mana_aura")
		if innate then
			local manaDamage = caster:GetMana() * innate:GetTalentSpecialValueFor("scepter_curr_mana_dmg") / 100
			caster:SpendMana(manaDamage)
		end
	end
	local minion_bonus = self:GetTalentSpecialValueFor("minion_bonus")
	local bonus = self:GetTalentSpecialValueFor("bonus")
	local boss_bonus = self:GetTalentSpecialValueFor("boss_bonus")
    for _,enemy in pairs(enemies) do
        local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_lion/lion_spell_finger_of_death.vpcf", PATTACH_POINT, caster)
        ParticleManager:SetParticleControlEnt(nfx, 0, caster, PATTACH_POINT, "attach_attack2", caster:GetAbsOrigin(), true)
        ParticleManager:SetParticleControlForward(nfx, 0, caster:GetForwardVector())
        ParticleManager:SetParticleControlEnt(nfx, 1, enemy, PATTACH_POINT, "attach_hitloc", enemy:GetAbsOrigin(), true)
        ParticleManager:SetParticleControl(nfx, 2, enemy:GetAbsOrigin())
        local position = caster:GetAbsOrigin() + ActualRandomVector(CalculateDistance(enemy, caster), caster:GetAttackRange())
        ParticleManager:SetParticleControl(nfx, 6, position)
        local position = caster:GetAbsOrigin() + ActualRandomVector(CalculateDistance(enemy, caster), caster:GetAttackRange())
        ParticleManager:SetParticleControl(nfx, 10, position)
        ParticleManager:ReleaseParticleIndex(nfx)

        self:DealDamage(caster, enemy, damage, {}, 0)
		
		if enemy:IsAlive() then
			if caster:HasScepter() and caster:HasModifier("modifier_lion_mana_aura_scepter") then
				self:DealDamage( caster, enemy, manaDamage, {damage_flag = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION})
				ParticleManager:FireRopeParticle("particles/items2_fx/necronomicon_archer_manaburn.vpcf", PATTACH_POINT_FOLLOW, caster, enemy)
			end

			if caster:HasTalent("special_bonus_unique_lion_death_finger_2") then
				enemy:AddNewModifier(caster, self, "modifier_lion_death_finger_root", {Duration = caster:FindTalentValue("special_bonus_unique_lion_death_finger_2")})
			end
		elseif growth then
			local numbers = bonus
			if enemy:IsMinion() then
				numbers = minion_bonus
			elseif enemy:IsBoss() then
				numbers = boss_bonus
			end
			growth:SetStackCount( growth:GetStackCount() + numbers / 5 )
		end
    end

    if caster:HasTalent("special_bonus_unique_lion_death_finger_1") then
		local delay = caster:FindTalentValue("special_bonus_unique_lion_death_finger_1")
        Timers:CreateTimer(delay, function()
            local enemies = caster:FindEnemyUnitsInLine(startPos, endPos, self:GetTalentSpecialValueFor("radius"), {flag=DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES})
			local dmgFactor = caster:FindTalentValue("special_bonus_unique_lion_death_finger_1", "dmgFactor")
            if #enemies > 0 then
                for _,enemy in pairs(enemies) do
                    local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_lion/lion_spell_finger_of_death.vpcf", PATTACH_POINT, caster)
                    ParticleManager:SetParticleControlEnt(nfx, 0, caster, PATTACH_POINT, "attach_attack2", caster:GetAbsOrigin(), true)
                    ParticleManager:SetParticleControlEnt(nfx, 1, enemy, PATTACH_POINT, "attach_hitloc", enemy:GetAbsOrigin(), true)
                    ParticleManager:SetParticleControl(nfx, 2, enemy:GetAbsOrigin())
                    ParticleManager:ReleaseParticleIndex(nfx)

                    self:DealDamage(caster, enemy, damage * dmgFactor, {}, 0)
					
					if enemy:IsAlive() then
						if caster:HasScepter() and caster:HasModifier("modifier_lion_mana_aura_scepter") then
							self:DealDamage( caster, enemy, manaDamage, {damage_flag = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION})
							ParticleManager:FireRopeParticle("particles/items2_fx/necronomicon_archer_manaburn.vpcf", PATTACH_POINT_FOLLOW, caster, enemy)
						end

						if caster:HasTalent("special_bonus_unique_lion_death_finger_2") then
							enemy:AddNewModifier(caster, self, "modifier_lion_death_finger_root", {Duration = caster:FindTalentValue("special_bonus_unique_lion_death_finger_2")})
						end
					elseif growth then
						local numbers = bonus
						if enemy:IsMinion() then
							numbers = minion_bonus
						elseif enemy:IsBoss() then
							numbers = boss_bonus
						end
						growth:SetStackCount( growth:GetStackCount() + numbers / 5 )
					end
                end
            end
        end)
    end
end

modifier_lion_death_finger_grow = class({})
LinkLuaModifier( "modifier_lion_death_finger_grow", "heroes/hero_lion/lion_death_finger.lua",LUA_MODIFIER_MOTION_NONE )

function modifier_lion_death_finger_grow:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOOLTIP}
end

function modifier_lion_death_finger_grow:OnTooltip()
	return self:GetStackCount() * 5
end

function modifier_lion_death_finger_grow:IsPurgable()
	return false
end

function modifier_lion_death_finger_grow:RemoveOnDeath()
	return false
end

modifier_lion_death_finger_root = class({})
function modifier_lion_death_finger_root:CheckState()
    local state = {[MODIFIER_STATE_ROOTED] = true}
    return state
end

function modifier_lion_death_finger_root:GetEffectName()
    return "particles/econ/items/warlock/warlock_staff_hellborn/warlock_upheaval_hellborn_debuff.vpcf"
end