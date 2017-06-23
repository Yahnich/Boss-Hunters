gladiatrix_unbreakable_morale = class({})

function gladiatrix_unbreakable_morale:OnSpellStart()
	if IsServer() then
		local hTarget = self:GetCursorTarget()
		EmitSoundOn("Hero_LegionCommander.PressTheAttack", hTarget)
		hTarget:Purge(false, true, false, true, true)
		hTarget:AddNewModifier(self:GetCaster(), self, "modifier_gladiatrix_unbreakable_morale_buff", {duration = self:GetSpecialValueFor("duration")})
		if hTarget.press then
			
		end
		
	end
end

LinkLuaModifier( "modifier_gladiatrix_unbreakable_morale_buff", "heroes/gladiatrix/gladiatrix_unbreakable_morale.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_gladiatrix_unbreakable_morale_buff = class({})

function modifier_gladiatrix_unbreakable_morale_buff:OnCreated()
	self.hpRegen = self:GetAbility():GetSpecialValueFor("hp_regen")
	self.attackSpeed = self:GetAbility():GetSpecialValueFor("attack_speed")
	if IsServer() then
		if self:GetCaster():HasTalent("gladiatrix_unbreakable_morale_talent_1") then self:StartIntervalThink(0) end
		self:GetParent().press = ParticleManager:CreateParticle("particles/units/heroes/hero_legion_commander/legion_commander_press.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControl(self:GetParent().press, 0, self:GetParent():GetAbsOrigin())
		ParticleManager:SetParticleControl(self:GetParent().press, 1, self:GetParent():GetAbsOrigin())
		ParticleManager:SetParticleControlEnt(self:GetParent().press, 2, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetParent():GetAbsOrigin(), true)
		ParticleManager:SetParticleControl(self:GetParent().press, 3, self:GetParent():GetAbsOrigin())
		self:AttachEffect(self:GetParent().press)
	end
end

if IsServer() then
	function  modifier_gladiatrix_unbreakable_morale_buff:OnDestroy()
		ParticleManager:ReleaseParticleIndex(self:GetParent().press)
		self:GetParent().press = nil
	end
end

function modifier_gladiatrix_unbreakable_morale_buff:OnIntervalThink()
	self:GetParent():Purge(false, true, false, true, true)
end


function modifier_gladiatrix_unbreakable_morale_buff:OnDestroy()
	if IsServer() then
		ParticleManager:DestroyParticle(self:GetParent().press, false)
		ParticleManager:ReleaseParticleIndex(self:GetParent().press)
		self:GetParent().press = nil
	end
end

function modifier_gladiatrix_unbreakable_morale_buff:DeclareFunctions()
	funcs = {
				MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
				MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
			}
	return funcs
end

function modifier_gladiatrix_unbreakable_morale_buff:GetModifierAttackSpeedBonus_Constant()
	return self.attackSpeed
end

function modifier_gladiatrix_unbreakable_morale_buff:GetModifierConstantHealthRegen()
	return self.hpRegen
end
