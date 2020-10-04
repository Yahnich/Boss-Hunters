slardar_amplify_damage_bh = class({})

function slardar_amplify_damage_bh:GetAOERadius()
	return caster:FindTalentValue("special_bonus_unique_slardar_amplify_damage_1")
end

function slardar_amplify_damage_bh:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	
	local duration = self:GetTalentSpecialValueFor("duration")
	if caster:HasTalent("special_bonus_unique_slardar_amplify_damage_1") then
		for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( target:GetAbsOrigin(), caster:FindTalentValue("special_bonus_unique_slardar_amplify_damage_1") ) ) do
			if not enemy:TriggerSpellAbsorb( self ) then
				self:ApplyHaze( enemy, duration )
			end
		end
	elseif not target:TriggerSpellAbsorb( self ) then
		self:ApplyHaze( target, duration )
	end
	caster:EmitSound("Hero_Slardar.Amplify_Damage")
end

function slardar_amplify_damage_bh:ApplyHaze( target, duration )
	local caster = self:GetCaster()
	target:AddNewModifier( caster, self, "modifier_slardar_amplify_damage_bh", { duration = duration or self:GetTalentSpecialValueFor("duration") } )
end

modifier_slardar_amplify_damage_bh = class({})
LinkLuaModifier( "modifier_slardar_amplify_damage_bh", "heroes/hero_slardar/slardar_amplify_damage_bh", LUA_MODIFIER_MOTION_NONE )

function modifier_slardar_amplify_damage_bh:OnCreated()
	self.armor = self:GetTalentSpecialValueFor("armor_reduction")
	self.talent2 = self:GetCaster():HasTalent("special_bonus_unique_slardar_amplify_damage_2")
	self.talent2Dmg = self:GetCaster():FindTalentValue("special_bonus_unique_slardar_amplify_damage_2")
	self.talent3 = self:GetCaster():HasTalent("special_bonus_unique_slardar_amplify_damage_3")
	self.talent3Radius = self:GetCaster():FindTalentValue("special_bonus_unique_slardar_amplify_damage_3")
	if self.talent3 then
		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_slardar/slardar_sprint.vpcf", PATTACH_POINT_FOLLOW, self:GetParent() )
		self:AddEffect( nfx )
	end
	if IsServer() then
		self:StartIntervalThink(0)
	end
end

function modifier_slardar_amplify_damage_bh:OnRefresh()
	self.armor = self:GetTalentSpecialValueFor("armor_reduction")
	self.talent2 = self:GetCaster():HasTalent("special_bonus_unique_slardar_amplify_damage_2")
	self.talent2Dmg = self:GetCaster():FindTalentValue("special_bonus_unique_slardar_amplify_damage_2")
	self.talent3 = self:GetCaster():HasTalent("special_bonus_unique_slardar_amplify_damage_3")
	self.talent3Radius = self:GetCaster():HasTalent("special_bonus_unique_slardar_amplify_damage_3")
	if IsServer() and self.talent2 then
		self:GetAbility():DealDamage( self:GetCaster(), self:GetParent(), self:GetCaster():GetPhysicalArmorValue(false) * self.talent2Dmg, {damage_type = DAMAGE_TYPE_PHYSICAL} )
	end
end

function modifier_slardar_amplify_damage_bh:OnRemoved()
	if IsServer() and self.talent2 then
		self:GetAbility():DealDamage( self:GetCaster(), self:GetParent(), self:GetCaster():GetPhysicalArmorValue(false) * self.talent2Dmg, {damage_type = DAMAGE_TYPE_PHYSICAL} )
	end
end

function modifier_slardar_amplify_damage_bh:OnIntervalThink()
	AddFOWViewer( DOTA_TEAM_GOODGUYS, self:GetParent():GetAbsOrigin(), 128, 0.03, false )
end

function modifier_slardar_amplify_damage_bh:CheckState()
	return {[MODIFIER_STATE_INVISIBLE] = false}
end

function modifier_slardar_amplify_damage_bh:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end

function modifier_slardar_amplify_damage_bh:GetModifierPhysicalArmorBonus()
	return self.armor
end


function modifier_slardar_amplify_damage_bh:IsAura()
	return self.talent3
end

function modifier_slardar_amplify_damage_bh:GetModifierAura()
	return "modifier_in_water"
end

function modifier_slardar_amplify_damage_bh:GetAuraRadius()
	return self.talent3Radius
end

function modifier_slardar_amplify_damage_bh:GetAuraDuration()
	return 0.5
end

function modifier_slardar_amplify_damage_bh:GetAuraSearchTeam()    
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_slardar_amplify_damage_bh:GetAuraSearchType()    
	return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_slardar_amplify_damage_bh:GetEffectName()
	return "particles/units/heroes/hero_slardar/slardar_amp_damage.vpcf"
end

function modifier_slardar_amplify_damage_bh:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end