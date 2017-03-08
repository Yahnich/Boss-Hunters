legion_commander_overwhelming_odds_ebf = class({})

function legion_commander_overwhelming_odds_ebf:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end

function legion_commander_overwhelming_odds_ebf:OnAbilityPhaseStart()
	if IsServer() then
		self.cast2 = ParticleManager:CreateParticle("particles/units/heroes/hero_legion_commander/legion_commander_odds_cast.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, self:GetCaster())
			ParticleManager:SetParticleControlEnt(self.cast2, 1, self:GetCaster(), PATTACH_CUSTOMORIGIN_FOLLOW, "attach_attack1", self:GetCaster():GetAbsOrigin(), true)
		self.cast = ParticleManager:CreateParticle("particles/units/heroes/hero_legion_commander/legion_commander_odds_cast.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, self:GetCaster())
			ParticleManager:SetParticleControlEnt(self.cast, 1, self:GetCaster(), PATTACH_CUSTOMORIGIN_FOLLOW, "attach_attack2", self:GetCaster():GetAbsOrigin(), true)
	end
	EmitSoundOn("Hero_LegionCommander.Overwhelming.Cast",self:GetCaster())
	return true
end

function legion_commander_overwhelming_odds_ebf:OnAbilityPhaseInterrupted()
	if IsServer() then
		ParticleManager:DestroyParticle(self.cast, false)
		ParticleManager:ReleaseParticleIndex(self.cast)
		ParticleManager:DestroyParticle(self.cast2, false)
		ParticleManager:ReleaseParticleIndex(self.cast2)
	end
end

function legion_commander_overwhelming_odds_ebf:OnSpellStart()
	if IsServer() then
		ParticleManager:DestroyParticle(self.cast, false)
		ParticleManager:ReleaseParticleIndex(self.cast)
		ParticleManager:DestroyParticle(self.cast2, false)
		ParticleManager:ReleaseParticleIndex(self.cast2)
		local caster = self:GetCaster()
		local target = self:GetCursorPosition()
		EmitSoundOn("Hero_LegionCommander.Overwhelming.Location",self:GetCaster())
		local radius = self:GetSpecialValueFor("radius")
		local base_damage = self:GetSpecialValueFor("damage")
		local bonus_damage = self:GetSpecialValueFor("damage_per_unit")
		local duration = self:GetSpecialValueFor("duration")
		local arrows = ParticleManager:CreateParticle("particles/units/heroes/hero_legion_commander/legion_commander_odds.vpcf", PATTACH_ABSORIGIN , caster)
				ParticleManager:SetParticleControl(arrows, 0, target)
				ParticleManager:SetParticleControl(arrows, 1, target)
				ParticleManager:SetParticleControl(arrows, 3, target)
				ParticleManager:SetParticleControl(arrows, 4, Vector(radius,0,0) )
				ParticleManager:SetParticleControl(arrows, 5, Vector(radius,0,0) )
				ParticleManager:SetParticleControl(arrows, 6, target)
				ParticleManager:SetParticleControl(arrows, 7, target)
				ParticleManager:SetParticleControl(arrows, 8, target)
		ParticleManager:ReleaseParticleIndex(arrows)
		local units = FindUnitsInRadius(caster:GetTeam(), target, nil, radius, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, 0, false)
		local damageToApply = 0
		local stacks = 1
		for _,unit in pairs(units) do -- check units
			if ((unit:IsHero() and unit:GetTeam() == caster:GetTeam()) or unit:GetTeam() ~= caster:GetTeam()) and unit ~= self:GetCaster() then
				damageToApply = damageToApply + bonus_damage
				stacks = stacks + 1
			end
		end
		for _,unit in pairs(units) do -- deal damage
			if unit:GetTeam() ~= caster:GetTeam() then
				ApplyDamage({victim = unit, attacker = caster, damage = damageToApply, damage_type = self:GetAbilityDamageType(), ability = self})
				EmitSoundOn("Hero_LegionCommander.Overwhelming.Creep",unit)
			else
				-- unit:AddNewModifier(caster, self, "modifier_legion_commander_overwhelming_odds_buff_visual", {duration = duration})
				unit:AddNewModifier(caster, self, "modifier_legion_commander_overwhelming_odds_buff_stacks", {duration = duration})
				unit:SetModifierStackCount("modifier_legion_commander_overwhelming_odds_buff_stacks", caster, stacks)
				EmitSoundOn("Hero_LegionCommander.Overwhelming.Hero",unit)
			end
		end
		caster:AddNewModifier(caster, self, "modifier_legion_commander_overwhelming_odds_buff_stacks", {duration = duration})
		caster:SetModifierStackCount("modifier_legion_commander_overwhelming_odds_buff_stacks", caster, stacks)
	end
end

LinkLuaModifier( "modifier_legion_commander_overwhelming_odds_buff_stacks", "lua_abilities/heroes/legion_commander.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_legion_commander_overwhelming_odds_buff_stacks = class({})

function modifier_legion_commander_overwhelming_odds_buff_stacks:OnCreated()
	self.armor_bonus = self:GetAbility():GetSpecialValueFor("bonus_armor")
	self.speed_bonus = self:GetAbility():GetSpecialValueFor("bonus_speed")
	if IsServer() then
		EmitSoundOn("Hero_LegionCommander.Overwhelming.Buff",self:GetParent())
	end
end

function modifier_legion_commander_overwhelming_odds_buff_stacks:GetEffectName()
	return "particles/units/heroes/hero_legion_commander/legion_commander_odds_buff.vpcf"
end

function modifier_legion_commander_overwhelming_odds_buff_stacks:DeclareFunctions()
	funcs = {
				MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
				MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
			}
	return funcs
end

function modifier_legion_commander_overwhelming_odds_buff_stacks:GetModifierMoveSpeedBonus_Percentage()
	return self.speed_bonus * self:GetStackCount()
end

function modifier_legion_commander_overwhelming_odds_buff_stacks:GetModifierPhysicalArmorBonus()
	return self.armor_bonus * self:GetStackCount()
end

legion_commander_press_the_attack_ebf = class({})

function legion_commander_press_the_attack_ebf:GetIntrinsicModifierName()
	return "modifier_legion_commander_press_the_attack_passive"
end

function legion_commander_press_the_attack_ebf:OnSpellStart()
	if IsServer() then
		local hTarget = self:GetCursorTarget()
		EmitSoundOn("Hero_LegionCommander.PressTheAttack", hTarget)
		hTarget:Purge(false, true, false, true, true)
		hTarget:AddNewModifier(self:GetCaster(), self, "modifier_legion_commander_press_the_attack_buff", {duration = self:GetSpecialValueFor("duration")})
		hTarget.press = ParticleManager:CreateParticle("particles/units/heroes/hero_legion_commander/legion_commander_press.vpcf", PATTACH_ABSORIGIN_FOLLOW, hTarget)
				ParticleManager:SetParticleControl(hTarget.press, 0, hTarget:GetAbsOrigin())
				ParticleManager:SetParticleControl(hTarget.press, 1, hTarget:GetAbsOrigin())
				ParticleManager:SetParticleControlEnt(hTarget.press, 2, hTarget, PATTACH_POINT_FOLLOW, "attach_attack1", hTarget:GetAbsOrigin(), true)
				ParticleManager:SetParticleControl(hTarget.press, 3, hTarget:GetAbsOrigin())
	end
end

LinkLuaModifier( "modifier_legion_commander_press_the_attack_passive", "lua_abilities/heroes/legion_commander.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_legion_commander_press_the_attack_passive = class({})

function modifier_legion_commander_press_the_attack_passive:OnCreated()
	self.procChance = self:GetAbility():GetSpecialValueFor("passive_chance")
end

function modifier_legion_commander_press_the_attack_passive:IsHidden()
	return true
end

function modifier_legion_commander_press_the_attack_passive:DeclareFunctions()
	funcs = {
				MODIFIER_EVENT_ON_ATTACK_LANDED
			}
	return funcs
end

function modifier_legion_commander_press_the_attack_passive:OnAttackLanded(params)
	if IsServer() then
		if params.target:GetTeam() == self:GetParent():GetTeam() and CalculateDistance(params.target, self:GetParent()) <= self:GetAbility():GetCastRange(self:GetParent():GetAbsOrigin(), params.target) and not self:GetParent():HasModifier("modifier_legion_commander_press_the_attack_passve_cooldown") and not params.target:HasModifier("modifier_legion_commander_press_the_attack_buff") then
			if RollPercentage(self.procChance) and self:GetParent():IsAlive() then
				self:GetParent():SetCursorCastTarget(params.target)
				self:GetAbility():OnSpellStart()
				self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_legion_commander_press_the_attack_passive_cooldown", {duration = self:GetAbility():GetTrueCooldown()})
			end
		end
	end
end

LinkLuaModifier( "modifier_legion_commander_press_the_attack_passive_cooldown", "lua_abilities/heroes/legion_commander.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_legion_commander_press_the_attack_passive_cooldown = class({})

function modifier_legion_commander_press_the_attack_passive_cooldown:IsDebuff()
	return true
end

LinkLuaModifier( "modifier_legion_commander_press_the_attack_buff", "lua_abilities/heroes/legion_commander.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_legion_commander_press_the_attack_buff = class({})

function modifier_legion_commander_press_the_attack_buff:OnCreated()
	self.hpRegen = self:GetAbility():GetSpecialValueFor("hp_regen")
	self.attackSpeed = self:GetAbility():GetSpecialValueFor("attack_speed")
end

function modifier_legion_commander_press_the_attack_buff:OnDestroy()
	if IsServer() then
		ParticleManager:DestroyParticle(self:GetParent().press, false)
		ParticleManager:ReleaseParticleIndex(self:GetParent().press)
	end
end

function modifier_legion_commander_press_the_attack_buff:DeclareFunctions()
	funcs = {
				MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
				MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
			}
	return funcs
end

function modifier_legion_commander_press_the_attack_buff:GetModifierAttackSpeedBonus_Constant()
	return self.attackSpeed
end

function modifier_legion_commander_press_the_attack_buff:GetModifierConstantHealthRegen()
	return self.hpRegen
end

legion_commander_moment_of_courage_ebf = class({})

function legion_commander_moment_of_courage_ebf:GetIntrinsicModifierName()
	return "modifier_legion_commander_moment_of_courage_ebf_passive"
end

LinkLuaModifier( "modifier_legion_commander_moment_of_courage_ebf_passive", "lua_abilities/heroes/legion_commander.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_lifesteal_generic", "lua_abilities/heroes/modifiers/modifier_lifesteal_generic.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_legion_commander_moment_of_courage_ebf_passive = class({})

function modifier_legion_commander_moment_of_courage_ebf_passive:OnCreated()
	self.procChance = self:GetAbility():GetSpecialValueFor("trigger_chance")
	self.duration = self:GetAbility():GetSpecialValueFor("buff_duration")
	self.lifesteal = self:GetAbility():GetSpecialValueFor("hp_leech_percent")
	if IsServer() then
		self:StartIntervalThink(0.03)
	end
end

function modifier_legion_commander_moment_of_courage_ebf_passive:OnIntervalThink()
	if self:GetParent():IsAttacking() and self:GetParent():HasModifier("modifier_legion_commander_moment_of_courage_ebf_buff") then
		Timers:CreateTimer(0.06,function()
			self:GetParent():PerformAttack(self:GetParent():GetAttackTarget(), false, true, true, false, false, false, true)
			EmitSoundOn("Hero_LegionCommander.Courage", self:GetParent())
			local hit1 = ParticleManager:CreateParticle("particles/units/heroes/hero_legion_commander/legion_commander_courage_tgt.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
				ParticleManager:SetParticleControlEnt(hit1, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetCaster():GetAbsOrigin(), true)
			local hit2 = ParticleManager:CreateParticle("particles/units/heroes/hero_legion_commander/legion_commander_courage_hit.vpcf", PATTACH_POINT_FOLLOW, self:GetParent():GetAttackTarget())
				ParticleManager:SetParticleControlEnt(hit2, 0, self:GetParent():GetAttackTarget(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAttackTarget():GetAbsOrigin(), true)
			ParticleManager:ReleaseParticleIndex(hit1)
			ParticleManager:ReleaseParticleIndex(hit2)
		end)
	end
end

function modifier_legion_commander_moment_of_courage_ebf_passive:IsHidden()
	return true
end

function modifier_legion_commander_moment_of_courage_ebf_passive:DeclareFunctions()
	funcs = {
				MODIFIER_EVENT_ON_ATTACK_LANDED,
			}
	return funcs
end

function modifier_legion_commander_moment_of_courage_ebf_passive:OnAttackLanded(params)
	if IsServer() then
		if params.attacker == self:GetParent() then
			if self:GetParent():HasModifier("modifier_legion_commander_moment_of_courage_ebf_buff") then
				self:GetParent():RemoveModifierByName("modifier_lifesteal_generic")
				self:GetParent():RemoveModifierByName("modifier_legion_commander_moment_of_courage_ebf_buff")
			elseif RollPercentage(self.procChance) and self:GetAbility():IsCooldownReady() then
				self:GetAbility():StartCooldown(self:GetAbility():GetTrueCooldown())
				self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_legion_commander_moment_of_courage_ebf_buff", {duration = self.duration})
				local lifesteal = self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_lifesteal_generic", {duration = self.duration})
				lifesteal.lifesteal = self.lifesteal
			end
		elseif params.target == self:GetParent() then
			if RollPercentage(self.procChance) and self:GetAbility():IsCooldownReady() then
				self:GetAbility():StartCooldown(self:GetAbility():GetTrueCooldown())
				self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_legion_commander_moment_of_courage_ebf_buff", {duration = self.duration})
				local lifesteal = self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_lifesteal_generic", {duration = self.duration})
				lifesteal.lifesteal = self.lifesteal
			end
		end
	end
end

LinkLuaModifier( "modifier_legion_commander_moment_of_courage_ebf_buff", "lua_abilities/heroes/legion_commander.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_legion_commander_moment_of_courage_ebf_buff = class({})

function modifier_legion_commander_moment_of_courage_ebf_passive:OnDestroy()
	self:GetParent():RemoveModifierByName("modifier_lifesteal_generic")
end

lc_ebf_war_fury = class({})

function lc_ebf_war_fury:GetAOERadius()
	return self:GetSpecialValueFor( "radius" )
end

function lc_ebf_war_fury:OnSpellStart()
	self.vTarget = self:GetCursorPosition()
	self.duration = self:GetSpecialValueFor("duration")
	local dummy = CreateUnitByName( "npc_dummy_blank", self.vTarget, false, nil, nil, self:GetCaster():GetTeamNumber() )
	dummy:AddNewModifier(self:GetCaster(), self, "modifier_legion_commander_war_fury_thinker", {duration = self.duration})
end

LinkLuaModifier( "modifier_legion_commander_war_fury_thinker", "lua_abilities/heroes/legion_commander.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_legion_commander_war_fury_thinker = class({})

function modifier_legion_commander_war_fury_thinker:OnCreated( kv )
	self.aura_radius = self:GetAbility():GetSpecialValueFor( "radius" )
	if IsServer() then
		EmitSoundOn("Hero_LegionCommander.WarFuryShout",self:GetCaster())
		EmitSoundOn("Hero_LegionCommander.Duel.Cast",self:GetCaster())
		EmitSoundOn("Hero_LegionCommander.Duel",self:GetCaster())
		
		self.FXIndex = ParticleManager:CreateParticle( "particles/legion_war_fury_ring.vpcf", PATTACH_ABSORIGIN, self:GetParent() )
		ParticleManager:SetParticleControl( self.FXIndex, 0, self:GetParent():GetOrigin() )
		ParticleManager:SetParticleControl( self.FXIndex, 5, Vector( self.aura_radius, self.aura_radius, self.aura_radius) )
		ParticleManager:SetParticleControl( self.FXIndex, 6, self:GetParent():GetOrigin() )
		ParticleManager:SetParticleControl( self.FXIndex, 7, self:GetParent():GetOrigin() )
		ParticleManager:SetParticleControl( self.FXIndex, 10, self:GetParent():GetOrigin() )
		self:StartIntervalThink(1.5)
	end
end

function modifier_legion_commander_war_fury_thinker:OnDestroy( kv )
	if IsServer() then
		self:GetParent():RemoveSelf()
		ParticleManager:DestroyParticle(self.FXIndex, false)
		ParticleManager:ReleaseParticleIndex(self.FXIndex)
		StopSoundOn("Hero_LegionCommander.Duel",self:GetCaster())
	end
end


function modifier_legion_commander_war_fury_thinker:OnIntervalThink( kv )
	if IsServer() then
		EmitSoundOn("Hero_LegionCommander.Duel.Victory", self:GetCaster())
	end
end

function modifier_legion_commander_war_fury_thinker:IsHidden()
	return true
end

--------------------------------------------------------------------------------

function modifier_legion_commander_war_fury_thinker:IsAura()
	return true
end

--------------------------------------------------------------------------------

function modifier_legion_commander_war_fury_thinker:GetModifierAura()
	return "modifier_legion_commander_war_fury_buff"
end

--------------------------------------------------------------------------------

function modifier_legion_commander_war_fury_thinker:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

--------------------------------------------------------------------------------

function modifier_legion_commander_war_fury_thinker:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO
end

--------------------------------------------------------------------------------

function modifier_legion_commander_war_fury_thinker:GetAuraRadius()
	return self.aura_radius
end

--------------------------------------------------------------------------------
function modifier_legion_commander_war_fury_thinker:IsPurgable()
    return false
end

function modifier_legion_commander_war_fury_thinker:CheckState()
    local state = {
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_ROOTED] = true,
		[MODIFIER_STATE_ATTACK_IMMUNE] = true,
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
		[MODIFIER_STATE_DISARMED] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
		[MODIFIER_STATE_UNSELECTABLE] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true
	}
	return state
end

LinkLuaModifier( "modifier_legion_commander_war_fury_buff", "lua_abilities/heroes/legion_commander.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_legion_commander_war_fury_buff = class({})

function modifier_legion_commander_war_fury_buff:OnCreated()
	self.bonusDamage = nil
	if IsServer() then
		self.bonusDamage = self:GetAbility():GetTalentSpecialValueFor("bonus_damage_aura")
		SendClientSync("war_fury_bonus_damage", self.bonusDamage)
	end
	self.lifesteal = self:GetAbility():GetSpecialValueFor("lifesteal")
	self.bonusArmor = self:GetAbility():GetSpecialValueFor("armor")
end

function modifier_legion_commander_war_fury_buff:DeclareFunctions()
	funcs = {
				MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
				MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
				MODIFIER_EVENT_ON_ATTACK_LANDED
			}
	return funcs
end

function modifier_legion_commander_war_fury_buff:GetModifierPreAttack_BonusDamage()
	if IsServer() and not CustomNetTables:GetTableValue( "syncing_purposes", "war_fury_bonus_damage").value then
		SendClientSync("war_fury_bonus_damage", self.bonusDamage)
	end
	self.bonusDamage = self.bonusDamage or CustomNetTables:GetTableValue( "syncing_purposes", "war_fury_bonus_damage").value
	return self.bonusDamage
end

function modifier_legion_commander_war_fury_buff:GetModifierPhysicalArmorBonus()
	return self.bonusArmor
end

function modifier_legion_commander_war_fury_buff:GetEffectName()
	return "particles/units/heroes/hero_legion_commander/legion_commander_duel_buff.vpcf"
end

function modifier_legion_commander_war_fury_buff:GetStatusEffectName()
	return "particles/status_fx/status_effect_legion_commander_duel.vpcf"
end

function modifier_legion_commander_war_fury_buff:OnAttackLanded(params)
	if IsServer() then
		if params.attacker == self:GetParent() then
			local flHeal = params.original_damage * (1 - params.target:GetPhysicalArmorReduction() / 100 ) * self.lifesteal / 100
			params.attacker:Heal(flHeal, params.attacker)
			local lifesteal = ParticleManager:CreateParticle("particles/units/heroes/hero_skeletonking/wraith_king_vampiric_aura_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, params.attacker)
				ParticleManager:SetParticleControlEnt(lifesteal, 0, params.attacker, PATTACH_POINT_FOLLOW, "attach_hitloc", params.attacker:GetAbsOrigin(), true)
				ParticleManager:SetParticleControlEnt(lifesteal, 1, params.attacker, PATTACH_POINT_FOLLOW, "attach_hitloc", params.attacker:GetAbsOrigin(), true)
			ParticleManager:ReleaseParticleIndex(lifesteal)
		end
	end
end