function CounterHelix( keys )
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability
    local helix_modifier = keys.helix_modifier

    -- If the caster has the helix modifier then do not trigger the counter helix
    -- as its considered to be on cooldown
    if target == caster and not caster:HasModifier(helix_modifier) then
        ability:ApplyDataDrivenModifier(caster, caster, helix_modifier, {})
		ability:StartCooldown(ability:GetCooldown(-1))
    end
end

function CounterHelixDamage( keys )
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability
	
	local armor = caster:GetPhysicalArmorValue()
	local armor_to_damage = ability:GetTalentSpecialValueFor("armor_to_damage") * armor
    ApplyDamage({victim = target, attacker = caster, damage = ability:GetAbilityDamage() + armor_to_damage, damage_type = ability:GetAbilityDamageType(), ability = ability})
end

function ScepterDunkCheck(keys)
end


function axe_culling_blade_fct(keys)
    local caster = keys.caster
    local ability = keys.ability
    local target = keys.target
    local ability_level = ability:GetLevel() - 1
    local kill_threshold = ability:GetTalentSpecialValueFor( "kill_threshold") / 100
	local damageType = DAMAGE_TYPE_MAGICAL
    local damage = ability:GetTalentSpecialValueFor( "damage") / 100
    if target:GetUnitName() ~= "npc_dota_boss36" then
        if target:GetHealth() <= kill_threshold * target:GetMaxHealth() then
            StartSoundEvent("Hero_Axe.Culling_Blade_Success", target )
            local kill_effect = ParticleManager:CreateParticle("particles/units/heroes/hero_axe/axe_culling_blade_kill.vpcf", PATTACH_ABSORIGIN , target)
            ParticleManager:SetParticleControl(kill_effect, 0, target:GetAbsOrigin())
            ParticleManager:SetParticleControl(kill_effect, 1, target:GetAbsOrigin())
            ParticleManager:SetParticleControl(kill_effect, 2, target:GetAbsOrigin())
            ParticleManager:SetParticleControl(kill_effect, 3, target:GetAbsOrigin())
            ParticleManager:SetParticleControl(kill_effect, 4, target:GetAbsOrigin())
			ParticleManager:ReleaseParticleIndex(kill_effect)
            target:ForceKill(true)
            ability:EndCooldown()
        else
            local damageTable = {
                victim = target,
                attacker = caster,
                damage = damage * target:GetMaxHealth()/get_aether_multiplier(caster),
                ability = keys.ability,
                damage_type = damageType
            }
            ApplyDamage(damageTable)
            StartSoundEvent("Hero_Axe.Culling_Blade_Fail", target )
        end
    else
        ability:EndCooldown()
    end
	ability:ApplyDataDrivenModifier( caster, caster, "axe_culling_boost", {duration = keys.duration} )
end

function AxeSteeledTemper(keys)
	local caster = keys.caster
    local ability = keys.ability
	
	local strength = caster:GetStrength()
	
	caster:SetModifierStackCount("modifier_axe_steeled_temper", caster, strength)
end

axe_battle_hunger_ebf = class({})

function axe_battle_hunger_ebf:GetIntrinsicModifierName()
	return "modifier_axe_battle_hunger_ebf_scepter_check"
end

function axe_battle_hunger_ebf:OnSpellStart()
	if IsServer() then
		local hTarget = self:GetCursorTarget()
		EmitSoundOn("Hero_Axe.Battle_Hunger", hTarget)
		local debuff = hTarget:AddNewModifier(self:GetCaster(), self, "modifier_axe_battle_hunger_ebf_debuff", {duration = self:GetTalentSpecialValueFor("duration")})
		local buff = self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_axe_battle_hunger_ebf_buff", {duration = self:GetTalentSpecialValueFor("duration")})
		debuff:IncrementStackCount()
		buff:IncrementStackCount()
	end
end

LinkLuaModifier( "modifier_axe_battle_hunger_ebf_scepter_check", "lua_abilities/heroes/axe.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_axe_battle_hunger_ebf_scepter_check = class({})

function modifier_axe_battle_hunger_ebf_scepter_check:IsHidden()
	return true
end

function modifier_axe_battle_hunger_ebf_scepter_check:DeclareFunctions()
	funcs = {
				MODIFIER_EVENT_ON_ABILITY_EXECUTED,
			}
	return funcs
end

function modifier_axe_battle_hunger_ebf_scepter_check:OnAbilityExecuted(params)
	if IsServer() then
		if self:GetParent():HasScepter() then
			if params.ability:GetName() == "axe_berserkers_call" then
				local units = FindUnitsInRadius(params.unit:GetTeamNumber(), params.unit:GetAbsOrigin(), nil, params.ability:GetCastRange(), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
				for _, unit in pairs(units) do
					self:GetCaster():SetCursorCastTarget(unit)
					self:GetAbility():OnSpellStart()
				end
			end
		end
	end
end

LinkLuaModifier( "modifier_axe_battle_hunger_ebf_buff", "lua_abilities/heroes/axe.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_axe_battle_hunger_ebf_buff = class({})

function modifier_axe_battle_hunger_ebf_buff:OnCreated()
	self.strgain = self:GetAbility():GetSpecialValueFor("strength_bonus")
	if IsServer() then
		self.expireTime = self:GetAbility():GetTalentSpecialValueFor("duration")
		self.strTable = {}
		table.insert(self.strTable, GameRules:GetGameTime())
		self:StartIntervalThink(0.5)
	end
end

function modifier_axe_battle_hunger_ebf_buff:OnRefresh()
	self.strgain = self:GetAbility():GetSpecialValueFor("strength_bonus")
	if IsServer() then
		table.insert(self.strTable, GameRules:GetGameTime())
	end
end

function modifier_axe_battle_hunger_ebf_buff:OnIntervalThink()
	if #self.strTable > 0 then
		for i = #self.strTable, 1, -1 do
			if self.strTable[i] + self.expireTime < GameRules:GetGameTime() then
				table.remove(self.strTable, i)		
			end
		end
		self:SetStackCount(#self.strTable)
		if #self.strTable == 0 then
			self:Destroy()
		end
		self:GetParent():CalculateStatBonus()
	else
		self:Destroy()
	end
end

function modifier_axe_battle_hunger_ebf_buff:DeclareFunctions()
	funcs = {
				MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
			}
	return funcs
end

function modifier_axe_battle_hunger_ebf_buff:GetModifierBonusStats_Strength()
	return self.strgain * self:GetStackCount()
end

LinkLuaModifier( "modifier_axe_battle_hunger_ebf_debuff", "lua_abilities/heroes/axe.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_axe_battle_hunger_ebf_debuff = class({})

function modifier_axe_battle_hunger_ebf_debuff:OnCreated()
	if IsServer() then
		self.damage = self:GetAbility():GetTalentSpecialValueFor("damage_per_second") * 0.5
		self.expireTime = self:GetAbility():GetTalentSpecialValueFor("duration")
		self.strTable = {}
		table.insert(self.strTable, GameRules:GetGameTime())
		self:StartIntervalThink(0.5)
	end
end

function modifier_axe_battle_hunger_ebf_debuff:OnRefresh()
	if IsServer() then
		self.damage = self:GetAbility():GetTalentSpecialValueFor("damage_per_second") * 0.5
		table.insert(self.strTable, GameRules:GetGameTime())
	end
end

function modifier_axe_battle_hunger_ebf_debuff:GetEffectName()
	return "particles/units/heroes/hero_axe/axe_battle_hunger.vpcf"
end

function modifier_axe_battle_hunger_ebf_debuff:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_axe_battle_hunger_ebf_debuff:GetStatusEffectName()
	return "particles/status_fx/status_effect_battle_hunger.vpcf" 
end

function modifier_axe_battle_hunger_ebf_debuff:OnIntervalThink()
	if #self.strTable > 0 then
		for i = #self.strTable, 1, -1 do
			if self.strTable[i] + self.expireTime < GameRules:GetGameTime() then
				table.remove(self.strTable, i)		
			end
		end
		self:SetStackCount(#self.strTable)
		if #self.strTable == 0 then
			self:Destroy()
		end
	else
		self:Destroy()
	end
	ApplyDamage({victim = self:GetParent(), attacker = self:GetCaster(), damage = self.damage * self:GetStackCount(), damage_type = self:GetAbility():GetAbilityDamageType(), ability = self:GetAbility()})
end