gladiatrix_war_fury = class({})

function gladiatrix_war_fury:GetAOERadius()
	return self:GetSpecialValueFor( "radius" )
end

function gladiatrix_war_fury:OnSpellStart()
	self.vTarget = self:GetCursorPosition()
	self.duration = self:GetSpecialValueFor("duration")
	local dummy = CreateUnitByName( "npc_dummy_blank", self.vTarget, false, nil, nil, self:GetCaster():GetTeamNumber() )
	dummy:AddNewModifier(self:GetCaster(), self, "modifier_gladiatrix_war_fury_thinker", {duration = self.duration})
end

LinkLuaModifier( "modifier_gladiatrix_war_fury_thinker", "heroes/gladiatrix/gladiatrix_war_fury.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_gladiatrix_war_fury_thinker = class({})

function modifier_gladiatrix_war_fury_thinker:OnCreated( kv )
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

function modifier_gladiatrix_war_fury_thinker:OnDestroy( kv )
	if IsServer() then
		self:GetParent():RemoveSelf()
		ParticleManager:DestroyParticle(self.FXIndex, false)
		ParticleManager:ReleaseParticleIndex(self.FXIndex)
		StopSoundOn("Hero_LegionCommander.Duel",self:GetCaster())
	end
end


function modifier_gladiatrix_war_fury_thinker:OnIntervalThink( kv )
	if IsServer() then
		if self:GetCaster():HasTalent("gladiatrix_war_fury_talent_1") then
			local enemies = self:GetParent():FindEnemyUnitsInRadius(self:GetParent():GetAbsOrigin(), self.aura_radius, {})
			for _, enemy in ipairs(enemies) do
				if self:GetCaster():HasModifier("modifier_gladiatrix_war_fury_buff") then
					enemy:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_gladiatrix_war_fury_taunt_talent", {duration = 1.51})
				else
					enemy:RemoveModifierByName("modifier_gladiatrix_war_fury_taunt_talent")
				end
				
			end
		end
		EmitSoundOn("Hero_LegionCommander.Duel.Victory", self:GetCaster())
	end
end

function modifier_gladiatrix_war_fury_thinker:IsHidden()
	return true
end

--------------------------------------------------------------------------------

function modifier_gladiatrix_war_fury_thinker:IsAura()
	return true
end

--------------------------------------------------------------------------------

function modifier_gladiatrix_war_fury_thinker:GetModifierAura()
	return "modifier_gladiatrix_war_fury_buff"
end

--------------------------------------------------------------------------------

function modifier_gladiatrix_war_fury_thinker:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

--------------------------------------------------------------------------------

function modifier_gladiatrix_war_fury_thinker:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO
end

--------------------------------------------------------------------------------

function modifier_gladiatrix_war_fury_thinker:GetAuraRadius()
	return self.aura_radius
end

--------------------------------------------------------------------------------
function modifier_gladiatrix_war_fury_thinker:IsPurgable()
    return false
end

function modifier_gladiatrix_war_fury_thinker:CheckState()
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

LinkLuaModifier( "modifier_gladiatrix_war_fury_buff", "heroes/gladiatrix/gladiatrix_war_fury.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_gladiatrix_war_fury_buff = class({})

function modifier_gladiatrix_war_fury_buff:OnCreated()
	self.bonusDamage = nil
	if IsServer() then
		self.bonusDamage = self:GetAbility():GetTalentSpecialValueFor("bonus_damage_aura")
		SendClientSync("war_fury_bonus_damage", self.bonusDamage)
	end
	self.lifesteal = self:GetAbility():GetSpecialValueFor("lifesteal")
	self.bonusArmor = self:GetAbility():GetSpecialValueFor("armor")
end

function modifier_gladiatrix_war_fury_buff:DeclareFunctions()
	funcs = {
				MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
				MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
				MODIFIER_EVENT_ON_ATTACK_LANDED
			}
	return funcs
end

function modifier_gladiatrix_war_fury_buff:GetModifierPreAttack_BonusDamage()
	if IsServer() and not CustomNetTables:GetTableValue( "syncing_purposes", "war_fury_bonus_damage").value then
		SendClientSync("war_fury_bonus_damage", self.bonusDamage)
	end
	self.bonusDamage = self.bonusDamage or CustomNetTables:GetTableValue( "syncing_purposes", "war_fury_bonus_damage").value
	return self.bonusDamage
end

function modifier_gladiatrix_war_fury_buff:GetModifierPhysicalArmorBonus()
	return self.bonusArmor
end

function modifier_gladiatrix_war_fury_buff:GetEffectName()
	return "particles/units/heroes/hero_legion_commander/legion_commander_duel_buff.vpcf"
end

function modifier_gladiatrix_war_fury_buff:GetStatusEffectName()
	return "particles/status_fx/status_effect_legion_commander_duel.vpcf"
end

function modifier_gladiatrix_war_fury_buff:OnAttackLanded(params)
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

LinkLuaModifier( "modifier_gladiatrix_war_fury_taunt_talent", "heroes/gladiatrix/gladiatrix_war_fury.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_gladiatrix_war_fury_taunt_talent = class({})
if IsServer() then
	function modifier_gladiatrix_war_fury_taunt_talent:OnCreated()
		self:GetParent():SetForceAttackTarget(nil)
		local order = 
		{
			UnitIndex = self:GetParent():entindex(),
			OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
			TargetIndex = self:GetCaster()y:entindex()
		}
		ExecuteOrderFromTable(order)
		self:GetParent():SetForceAttackTarget(self:GetCaster())
	end

	function modifier_gladiatrix_war_fury_taunt_talent:OnDestroy()
		self:GetParent():SetForceAttackTarget(nil)
	end
end