venomancer_plague_ward_ebf = class({})


function venomancer_plague_ward_ebf:OnSpellStart()
	local caster = self:GetCaster()
	local position = self:GetCursorPosition()
	
	local spawnCount = self:GetTalentSpecialValueFor("spawn_count")
	EmitSoundOn("Hero_Venomancer.Plague_Ward", caster)
	for i = 1, spawnCount do
		if spawnCount > 1 then position = position + RandomVector(150) end
		self:CreateWard(position)
	end
end

function venomancer_plague_ward_ebf:CreateWard(position)
	local caster = self:GetCaster()
	local duration = self:GetTalentSpecialValueFor("duration")
	local hp = self:GetTalentSpecialValueFor("ward_hp")
	local damage = self:GetTalentSpecialValueFor("ward_damage")
	local ward = caster:CreateSummon("npc_dota_venomancer_plague_ward_1", position, duration)
	ward:SetBaseMaxHealth(hp)
	ward:SetMaxHealth(hp)
	ward:SetHealth(hp)
	ward:SetModelScale(0.6 + self:GetLevel()/10)
	ward:AddNewModifier(self:GetCaster(), self, "modifier_venomancer_plague_ward_handler", {})
	ward:SetAverageBaseDamage(damage, 15)
	ward:MoveToPositionAggressive(ward:GetAbsOrigin())
end


modifier_venomancer_plague_ward_handler = class({})
LinkLuaModifier("modifier_venomancer_plague_ward_handler", "heroes/hero_venomancer/venomancer_plague_ward_ebf", LUA_MODIFIER_MOTION_NONE)

function modifier_venomancer_plague_ward_handler:IsHidden()
	return true
end

function modifier_venomancer_plague_ward_handler:CheckState()
	return {[MODIFIER_STATE_MAGIC_IMMUNE] = true}
end

function modifier_venomancer_plague_ward_handler:DeclareFunctions()
	return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
end

function modifier_venomancer_plague_ward_handler:GetModifierIncomingDamage_Percentage(params)
	if self:GetParent():GetHealth() > 1 then
		self:GetParent():SetHealth( self:GetParent():GetHealth() - 1 )
	else
		self:GetParent():ForceKill(false)
	end
	return -999
end