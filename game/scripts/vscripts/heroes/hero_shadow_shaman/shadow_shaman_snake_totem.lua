shadow_shaman_snake_totem = class({})

function shadow_shaman_snake_totem:OnSpellStart()
	local caster = self:GetCaster()
	local position = self:GetCursorPosition()
	for i = 1, self:GetSpecialValueFor("ward_count") do
		local ward = caster:CreateSummon("npc_dota_shadow_shaman_ward_1", position, self:GetSpecialValueFor("duration"))
		ward:AddNewModifier(caster, self, "modifier_shadow_shaman_snake_totem_damage_aura", {})
		local health = self:GetSpecialValueFor("health")
		ward:SetBaseMaxHealth( health )
		ward:SetMaxHealth( health )
		ward:SetHealth( health )
		ward:SetBaseAttackTime( 0.1 )
		ward:SetBaseDamageMin(0)
		ward:SetBaseDamageMax(0)
		ward:SetModelScale( 0.9 + self:GetLevel()/10 )
		Timers:CreateTimer(0.25, function()
			local enemy = ward:FindRandomEnemyInRadius(position, ward:GetAttackRange() )
			if enemy then
				ExecuteOrderFromTable({
					UnitIndex = ward:entindex(),
					OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
					TargetIndex = enemy:entindex()
				})
			end
		end)
	end
end

modifier_shadow_shaman_snake_totem_damage_aura = class({})
LinkLuaModifier("modifier_shadow_shaman_snake_totem_damage_aura", "heroes/hero_shadow_shaman/shadow_shaman_snake_totem", LUA_MODIFIER_MOTION_NONE)

function modifier_shadow_shaman_snake_totem_damage_aura:OnCreated()
	self.radius = self:GetCaster():FindTalentValue("special_bonus_unique_shadow_shaman_snake_totem_1")
	self.scepter = self:GetCaster():HasScepter()
	self.scepter_radius = self:GetSpecialValueFor("scepter_range")
end

function modifier_shadow_shaman_snake_totem_damage_aura:IsAura()
	return true
end

function modifier_shadow_shaman_snake_totem_damage_aura:GetModifierAura()
	return "modifier_shadow_shaman_snake_totem_damage_buff"
end

function modifier_shadow_shaman_snake_totem_damage_aura:GetAuraRadius()
	return self.radius
end

function modifier_shadow_shaman_snake_totem_damage_aura:GetAuraDuration()
	return 0.5
end

function modifier_shadow_shaman_snake_totem_damage_aura:GetAuraSearchTeam()    
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_shadow_shaman_snake_totem_damage_aura:GetAuraSearchType()    
	return DOTA_UNIT_TARGET_OTHER + DOTA_UNIT_TARGET_HERO
end

function modifier_shadow_shaman_snake_totem_damage_aura:GetAuraSearchFlags()    
	return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_shadow_shaman_snake_totem_damage_aura:IsHidden()
	return true
end

function modifier_shadow_shaman_snake_totem_damage_aura:CheckState()
	return {[MODIFIER_STATE_MAGIC_IMMUNE] = true}
end

function modifier_shadow_shaman_snake_totem_damage_aura:DeclareFunctions()
	return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
			MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
			MODIFIER_EVENT_ON_ATTACK}
end

function modifier_shadow_shaman_snake_totem_damage_aura:OnAttack(params)
	if self.scepter and params.attacker == self:GetParent() and not params.attacker.preventScepterLoop then
		for _, enemy in ipairs( self:GetCaster():FindEnemyUnitsInRadius( params.attacker:GetAbsOrigin(), params.attacker:GetAttackRange() ) ) do
			if enemy ~= params.target then
				params.attacker.preventScepterLoop = true
				params.attacker:PerformAttack(enemy, false, false, false, false, true, false, false)
				params.attacker.preventScepterLoop = false
			end
		end
	end	
end

function modifier_shadow_shaman_snake_totem_damage_aura:GetModifierIncomingDamage_Percentage(params)
	if self:GetParent():GetHealth() > 1 then
		self:GetParent():SetHealth( self:GetParent():GetHealth() - 1 )
	else
		self:GetParent():ForceKill(false)
	end
	return -999
end

function modifier_shadow_shaman_snake_totem_damage_aura:GetModifierAttackRangeBonus(params)
	if self.scepter then
		return self.scepter_radius
	end
end

modifier_shadow_shaman_snake_totem_damage_buff = class({})
LinkLuaModifier("modifier_shadow_shaman_snake_totem_damage_buff", "heroes/hero_shadow_shaman/shadow_shaman_snake_totem", LUA_MODIFIER_MOTION_NONE)

function modifier_shadow_shaman_snake_totem_damage_buff:OnCreated()
	self.damage = self:GetSpecialValueFor("damage")
end

function modifier_shadow_shaman_snake_totem_damage_buff:OnRefresh()
	self.damage = self:GetSpecialValueFor("damage")
end

function modifier_shadow_shaman_snake_totem_damage_buff:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE}
end

function modifier_shadow_shaman_snake_totem_damage_buff:GetModifierPreAttack_BonusDamage()
	return self.damage
end