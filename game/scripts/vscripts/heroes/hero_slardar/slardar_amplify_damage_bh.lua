slardar_amplify_damage_bh = class({})

function slardar_amplify_damage_bh:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	
	local duration = self:GetTalentSpecialValueFor("duration")
	if caster:HasTalent("special_bonus_unique_slardar_amplify_damage_1") then
		for _, enemy in ipairs( target:GetAbsOrigin(), caster:FindTalentValue("special_bonus_unique_slardar_amplify_damage_1") ) do
			self:ApplyHaze( enemy, duration )
		end
	else
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
	self.armor = self:GetTalentSpecialValueFor("armor_reduction") - self:GetCaster():GetPhysicalArmorBaseValue() * self:GetCaster():FindTalentValue("special_bonus_unique_slardar_amplify_damage_2") / 100
	if IsServer() then
		self:StartIntervalThink(0)
	end
end

function modifier_slardar_amplify_damage_bh:OnRefresh()
	self.armor = self:GetTalentSpecialValueFor("armor_reduction") - self:GetCaster():GetPhysicalArmorBaseValue() * self:GetCaster():FindTalentValue("special_bonus_unique_slardar_amplify_damage_2") / 100
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

function modifier_slardar_amplify_damage_bh:GetEffectName()
	return "particles/units/heroes/hero_slardar/slardar_amp_damage.vpcf"
end

function modifier_slardar_amplify_damage_bh:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end