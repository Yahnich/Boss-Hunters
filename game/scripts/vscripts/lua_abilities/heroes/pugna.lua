pugna_decrepify_ebf = class({})

if IsServer() then
	function pugna_decrepify_ebf:OnSpellStart()
		local caster = self:GetCaster()
		local hTarget = self:GetCursorTarget()
		if caster:GetTeam() == hTarget:GetTeam() then
			hTarget:AddNewModifier(caster, self, "modifier_pugna_decrepify_ally", {duration = self:GetSpecialValueFor("tooltip_duration")})
		else
			hTarget:AddNewModifier(caster, self, "modifier_pugna_decrepify_enemy", {duration = self:GetSpecialValueFor("tooltip_duration")})
		end
		EmitSoundOn("Hero_Pugna.Decrepify", hTarget)
	end
end

LinkLuaModifier( "modifier_pugna_decrepify_ally", "lua_abilities/heroes/pugna.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_pugna_decrepify_ally = class({})

function modifier_pugna_decrepify_ally:OnCreated()
	self.magic_damage = self:GetAbility():GetSpecialValueFor("bonus_spell_damage_pct_allies")
	self.slow = self:GetAbility():GetSpecialValueFor("bonus_movement_speed_allies")
end

function modifier_pugna_decrepify_ally:CheckState()
    local state = {
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_ATTACK_IMMUNE] = true,
	}
	return state
end

function modifier_pugna_decrepify_ally:DeclareFunctions()
	funcs = {
				MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
				MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS
			}
	return funcs
end

function modifier_pugna_decrepify_ally:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end

function modifier_pugna_decrepify_ally:GetModifierMagicalResistanceBonus()
	return self.magic_damage
end

function modifier_pugna_decrepify_ally:GetEffectName()
	return "particles/units/heroes/hero_pugna/pugna_decrepify.vpcf"
end

function modifier_pugna_decrepify_ally:GetStatusEffectName()
	return "particles/status_fx/status_effect_ghost.vpcf"
end

function modifier_pugna_decrepify_ally:StatusEffectPriority()
	return 15
end

LinkLuaModifier( "modifier_pugna_decrepify_enemy", "lua_abilities/heroes/pugna.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_pugna_decrepify_enemy = class({})

function modifier_pugna_decrepify_enemy:OnCreated()
	self.magic_damage = self:GetAbility():GetSpecialValueFor("bonus_spell_damage_pct_allies")
	self.slow = self:GetAbility():GetSpecialValueFor("bonus_movement_speed_allies")
end

function modifier_pugna_decrepify_enemy:CheckState()
    local state = {
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_DISARMED] = true,
	}
	return state
end

function modifier_pugna_decrepify_enemy:DeclareFunctions()
	funcs = {
				MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
				MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS
			}
	return funcs
end

function modifier_pugna_decrepify_enemy:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end

function modifier_pugna_decrepify_enemy:GetModifierMagicalResistanceBonus()
	return self.magic_damage
end

function modifier_pugna_decrepify_enemy:GetEffectName()
	return "particles/units/heroes/hero_pugna/pugna_decrepify.vpcf"
end

function modifier_pugna_decrepify_enemy:GetStatusEffectName()
	return "particles/status_fx/status_effect_ghost.vpcf"
end

function modifier_pugna_decrepify_enemy:StatusEffectPriority()
	return 15
end

pugna_nether_turret = class({})
if IsServer() then
	function pugna_nether_turret:OnSpellStart()
		local caster = self:GetCaster()
		local point =  self:GetCursorPosition()
		local netherward = CreateUnitByName( "npc_dota_pugna_nether_ward_1", point, false, nil, nil, caster:GetTeamNumber() )
		netherward:AddNewModifier(self:GetCaster(), self, "modifier_pugna_nether_turret_thinker", {duration = self:GetDuration()})
		netherward.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_pugna/pugna_ward_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, netherward)
			ParticleManager:SetParticleControl(netherward.particle, 0, netherward:GetAbsOrigin())
		EmitSoundOn("Hero_Pugna.NetherWard", netherward)
	end
end

LinkLuaModifier( "modifier_pugna_nether_turret_thinker", "lua_abilities/heroes/pugna.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_pugna_nether_turret_thinker = class({})

function modifier_pugna_nether_turret_thinker:OnCreated( kv )
	self.aura_radius = self:GetAbility():GetSpecialValueFor( "radius" )
	if IsServer() then
		self.dmg_mult = self:GetAbility():GetTalentSpecialValueFor( "dmg_mult" )
	end
end

function modifier_pugna_nether_turret_thinker:OnDestroy( kv )
	if IsServer() then
		ParticleManager:DestroyParticle(self:GetParent().particle, false)
		ParticleManager:ReleaseParticleIndex(self:GetParent().particle)
		self:GetParent():RemoveSelf()
	end
end


function modifier_pugna_nether_turret_thinker:DeclareFunctions()
	funcs = {
				MODIFIER_EVENT_ON_TAKEDAMAGE
			}
	return funcs
end

function modifier_pugna_nether_turret_thinker:OnTakeDamage(params)
	if IsServer() then
		if params and params.attacker and not params.attacker:IsNull() and not ( HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) or HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) ) then
			if params.attacker:GetTeam() ~= self:GetParent():GetTeam() and params.attacker:HasModifier("modifier_pugna_nether_turret_aura") then
				local attack = ParticleManager:CreateParticle("particles/units/heroes/hero_pugna/pugna_ward_attack.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
				ParticleManager:SetParticleControl(attack, 1, params.attacker:GetAbsOrigin())
				ParticleManager:ReleaseParticleIndex(attack)
				local damage = params.damage
				if params.damage > params.unit:GetMaxHealth() then damage = params.unit:GetMaxHealth() end
				params.attacker:EmitSound("Hero_Pugna.NetherWard.Target")
				self:GetParent():EmitSound("Hero_Pugna.NetherWard.Attack")
				ApplyDamage({ victim = params.attacker, attacker = self:GetCaster(), damage = damage*self.dmg_mult, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility() })
			end
		end
	end
end

function modifier_pugna_nether_turret_thinker:IsHidden()
	return true
end

function modifier_pugna_nether_turret_thinker:IsAura()
	return true
end

--------------------------------------------------------------------------------

function modifier_pugna_nether_turret_thinker:GetModifierAura()
	return "modifier_pugna_nether_turret_aura"
end

--------------------------------------------------------------------------------

function modifier_pugna_nether_turret_thinker:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

--------------------------------------------------------------------------------

function modifier_pugna_nether_turret_thinker:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

--------------------------------------------------------------------------------

function modifier_pugna_nether_turret_thinker:GetAuraRadius()
	return self.aura_radius
end

function modifier_pugna_nether_turret_thinker:IsPurgable()
    return false
end

function modifier_pugna_nether_turret_thinker:CheckState()
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

LinkLuaModifier( "modifier_pugna_nether_turret_aura", "lua_abilities/heroes/pugna.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_pugna_nether_turret_aura = class({})

function modifier_pugna_nether_turret_aura:IsHidden()
	return true
end

pugna_lifedrain_end = class({})

if IsServer() then
	function pugna_lifedrain_end:OnSpellStart()
		local modifiers = self:GetCaster():FindAllModifiersByName("modifier_pugna_life_drain")
		for _, modifier in pairs(modifiers) do
			modifier:Destroy()
		end
	end
end

pugna_lifedrain_ebf = class({})

function pugna_lifedrain_ebf:GetCooldown(nLevel)
	local cooldown = self.BaseClass.GetCooldown( self, nLevel )
	if self:GetCaster():HasScepter() then cooldown = self:GetSpecialValueFor("scepter_cooldown") end
	return cooldown
end

if IsServer() then
	function pugna_lifedrain_ebf:OnSpellStart()
		local caster = self:GetCaster()
		local hTarget = self:GetCursorTarget()
		EmitSoundOn("Hero_Pugna.LifeDrain.Target", hTarget)
		if caster:GetTeam() == hTarget:GetTeam() then
			caster:AddNewModifier(hTarget, self, "modifier_pugna_life_drain", {duration = self:GetSpecialValueFor("duration_tooltip")})
		else
			hTarget:AddNewModifier(caster, self, "modifier_pugna_life_drain", {duration = self:GetSpecialValueFor("duration_tooltip")})
		end
	end
end