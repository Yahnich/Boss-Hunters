venomancer_living_growth_ebf = class({})


function venomancer_living_growth_ebf:OnSpellStart()
	local caster = self:GetCaster()
	local position = self:GetCursorPosition()
	
	local spawnCount = self:GetSpecialValueFor("spawn_count")
	EmitSoundOn("Hero_Venomancer.Plague_Ward", caster)
	for i = 1, spawnCount do
		if spawnCount > 1 then position = position + RandomVector(150) end
		self:CreateWard(position)
	end
end

function venomancer_living_growth_ebf:CreateWard(position, duration)
	local caster = self:GetCaster()
	local fDur = duration or self:GetSpecialValueFor("duration")
	local hp = self:GetSpecialValueFor("ward_hp")
	local damage = self:GetSpecialValueFor("ward_damage")
	local ward = caster:CreateSummon("npc_dota_venomancer_living_growth_1", position or caster:GetAbsOrigin(), fDur)
	ward:SetCoreHealth(hp)
	ward:SetBaseHealthRegen(0)
	ward:SetModelScale(0.6 + self:GetLevel()/20)
	ward:SetHullRadius(0)
	ResolveNPCPositions(position, 64)
	ward:AddNewModifier( caster, self, "modifier_venomancer_living_growth_handler", {})
	if caster:HasTalent("special_bonus_unique_venomancer_poison_nova_2") and caster:FindAbilityByName("venomancer_poison_nova_ebf") then
		ward:AddNewModifier( caster, caster:FindAbilityByName("venomancer_poison_nova_ebf"), "modifier_venomancer_poison_nova_talent", {})
	end
	ward:SetAverageBaseDamage(damage, 15)
	ward:AddAbility("venomancer_venomous_ebf"):SetLevel( caster:FindAbilityByName("venomancer_venomous_ebf"):GetLevel() )
	if caster:HasTalent("special_bonus_unique_venomancer_living_growth_2") then
		ward:SetModelScale(ward:GetModelScale() * 1.25)
		local gale = ward:AddAbility("venomancer_spit_venom_ebf")
		gale:SetLevel( caster:FindAbilityByName("venomancer_spit_venom_ebf"):GetLevel() )
		AITimers:CreateTimer(1, function()
			if ward and not ward:IsNull() and ward:IsAlive() then
				if gale:IsFullyCastable() and ward:GetAttackTarget() then
					ward:SetCursorPosition( ward:GetAttackTarget():GetAbsOrigin() )
					gale:CastAbility()
				end
				return 1
			end
		end)
	end
	ward:MoveToPositionAggressive(ward:GetAbsOrigin())
end


modifier_venomancer_living_growth_handler = class({})
LinkLuaModifier("modifier_venomancer_living_growth_handler", "heroes/hero_venomancer/venomancer_living_growth_ebf", LUA_MODIFIER_MOTION_NONE)

function modifier_venomancer_living_growth_handler:OnCreated()
	self.talent2Val3 = self:GetCaster():FindTalentValue("special_bonus_unique_venomancer_living_growth_2", "value3")
end

function modifier_venomancer_living_growth_handler:IsHidden()
	return true
end

function modifier_venomancer_living_growth_handler:CheckState()
	return {[MODIFIER_STATE_MAGIC_IMMUNE] = true}
end

function modifier_venomancer_living_growth_handler:DeclareFunctions()
	return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE, MODIFIER_PROPERTY_ATTACK_RANGE_BONUS }
end

function modifier_venomancer_living_growth_handler:GetModifierAttackRangeBonus(params)
	return self.talent2Val3
end

function modifier_venomancer_living_growth_handler:GetModifierIncomingDamage_Percentage(params)
	if self:GetParent():GetHealth() > 1 then
		self:GetParent():SetHealth( self:GetParent():GetHealth() - 1 )
	else
		self:GetParent():ForceKill(false)
	end
	return -999
end