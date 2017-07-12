gladiatrix_adrenaline = class({})

function gladiatrix_adrenaline:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	EmitSoundOn("Hero_DoomBringer.DevourCast", self:GetCaster())
	caster:AddNewModifier(caster, self, "modifier_gladiatrix_adrenaline", {duration = self:GetTalentSpecialValueFor("duration")})
end


LinkLuaModifier( "modifier_gladiatrix_adrenaline", "heroes/gladiatrix/gladiatrix_adrenaline.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_gladiatrix_adrenaline = class({})

function modifier_gladiatrix_adrenaline:OnCreated()
	self.healamp = self:GetAbility():GetSpecialValueFor("heal_amp")
	self.reduction = self:GetAbility():GetSpecialValueFor("damage_reduction")
	if IsServer() then self:GetAbility():StartDelayedCooldown(self:GetRemainingTime(), false) end
end



function modifier_gladiatrix_adrenaline:GetEffectName()
	return "particles/heroes/gladiatrix/gladiatrix_adrenaline_rush.vpcf"
end

function modifier_gladiatrix_adrenaline:DeclareFunctions()
	funcs = {
				MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE,
				MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
			}
	return funcs
end

function modifier_gladiatrix_adrenaline:GetModifierHealAmplify_Percentage()
	return self.healamp
end
if IsServer() then
	function modifier_gladiatrix_adrenaline:GetModifierIncomingDamage_Percentage(params)
		if self:GetParent():HasTalent("gladiatrix_adrenaline_talent_1") then
			self.damageTaken = (self.damageTaken or 0) + params.damage * (100+self.reduction) / 100
			return -100
		end
		return self.reduction
	end
	
	function modifier_gladiatrix_adrenaline:OnDestroy()
		local storeDamage = self.damageTaken
		local parent = self:GetParent()
		if IsServer() then self:GetAbility():EndDelayedCooldown() end
		if parent:HasTalent("gladiatrix_adrenaline_talent_1") then
			local damage = (storeDamage or 0) * 0.3
			Timers:CreateTimer(0.3, function()
				if damage > storeDamage then damage = storeDamage end
				if damage > parent:GetHealth() then	
					parent:SetHealth(1)
				else
					parent:SetHealth(parent:GetHealth() - damage)
				end
				storeDamage = storeDamage - damage
				if storeDamage > 0 then return 0.3 end
			end)
		end
	end
end

function modifier_gladiatrix_adrenaline:GetStatusEffectName()
	return "particles/heroes/gladiatrix/status_effect_gladiatrix_imperious_shout.vpcf"
end

function modifier_gladiatrix_adrenaline:StatusEffectPriority()
	return 10
end