lich_mage_damage_amp = class({})

function lich_mage_damage_amp:GetIntrinsicModifierName()
	return "modifier_lich_mage_damage_amp_ai"
end

function lich_mage_damage_amp:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	
	EmitSoundOn("Hero_Lich.ChainFrostImpact.Creep", target)
	if caster:GetOwnerEntity():HasTalent("puppeteer_lich_mage_talent_1") then
		local enemies = FindUnitsInRadius(self:GetCaster():GetTeam(), target:GetAbsOrigin(), nil, caster:GetOwnerEntity():FindTalentValue("puppeteer_lich_mage_talent_1"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
		for _, enemy in pairs(enemies) do
			enemy:AddNewModifier(self:GetCaster(), self, "modifier_lich_mage_damage_amp", {duration = self:GetSpecialValueFor("duration")})
		end
	else
		target:AddNewModifier(self:GetCaster(), self, "modifier_lich_mage_damage_amp", {duration = self:GetSpecialValueFor("duration")})
	end
end

LinkLuaModifier("modifier_lich_mage_damage_amp", "summons/lich_mage/lich_mage_damage_amp.lua", LUA_MODIFIER_MOTION_NONE)
modifier_lich_mage_damage_amp = class({})

function modifier_lich_mage_damage_amp:OnCreated()
	self.amp = self:GetAbility():GetSpecialValueFor("amp")
end

function modifier_lich_mage_damage_amp:OnRefresh()
	self.amp = self:GetAbility():GetSpecialValueFor("amp")
end

function modifier_lich_mage_damage_amp:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
	}
	return funcs
end

function modifier_lich_mage_damage_amp:GetModifierIncomingDamage_Percentage()
	return self.amp
end


function modifier_lich_mage_damage_amp:GetEffectName()
	return "particles/heroes/puppeteer/lich_mage_damage_amp.vpcf"
end

LinkLuaModifier("modifier_lich_mage_damage_amp_ai", "summons/lich_mage/lich_mage_damage_amp.lua", LUA_MODIFIER_MOTION_NONE)
modifier_lich_mage_damage_amp_ai = class({})
if IsServer() then
	function modifier_lich_mage_damage_amp_ai:OnCreated()
		self:StartIntervalThink(0.2) 
	end

	function modifier_lich_mage_damage_amp_ai:OnIntervalThink()
		if not self:GetAbility():IsFullyCastable() then return end
		if self:GetAbility():GetAutoCastState() then -- cast on random or whoever caster is attacking
			local enemies = FindUnitsInRadius(self:GetCaster():GetTeam(), self:GetCaster():GetAbsOrigin(), nil, self:GetAbility():GetSpecialValueFor("cast_range"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
			local target
			if self:GetParent():GetOwnerEntity():GetAttackTarget() then
				target = self:GetParent():GetOwnerEntity():GetAttackTarget()
			else
				for _, enemy in pairs(enemies) do
					if enemy:IsBeingAttacked() then
						target = enemy
						break
					end
				end
			end
			if not target then
				for _, enemy in pairs(enemies) do
					target = enemy
				end
			end
			if not target then return end
			self:GetCaster():Interrupt()
			ExecuteOrderFromTable({
				UnitIndex = self:GetCaster():entindex(),
				OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
				TargetIndex = target:entindex(),
				AbilityIndex = self:GetAbility():entindex(),
				Queue = true
			})
		end
	end
end

function modifier_lich_mage_damage_amp_ai:IsHidden()
	return true
end