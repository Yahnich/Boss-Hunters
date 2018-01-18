bristleback_spiky_shell = class({})
LinkLuaModifier( "modifier_spiky_shell", "heroes/hero_bristleback/bristleback_spiky_shell.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_quills_enemy", "heroes/hero_bristleback/bristleback_quills.lua",LUA_MODIFIER_MOTION_NONE )

function bristleback_spiky_shell:GetIntrinsicModifierName()
	return "modifier_spiky_shell"
end

modifier_spiky_shell = class({})
function modifier_spiky_shell:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE,
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
	}
	return funcs
end

function modifier_spiky_shell:OnTakeDamage(params)
	if IsServer() then
		if params.unit == self:GetCaster() then
			local ability = self:GetCaster():FindAbilityByName("bristleback_quills")
			if RollPercentage(self:GetTalentSpecialValueFor("chance")) and ability:IsTrained() then
				local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_bristleback/bristleback_quill_spray.vpcf", PATTACH_POINT, self:GetCaster())
				ParticleManager:SetParticleControl(nfx, 0, self:GetCaster():GetAbsOrigin())
				ParticleManager:ReleaseParticleIndex(nfx)
				local enemies = self:GetCaster():FindEnemyUnitsInRadius(self:GetCaster():GetAbsOrigin(), ability:GetTalentSpecialValueFor("radius"), {})
				for _,enemy in pairs(enemies) do
					if enemy:HasModifier("modifier_quills_enemy") then
						local damage = ability:GetTalentSpecialValueFor("quill_base_damage") + enemy:FindModifierByName("modifier_quills_enemy"):GetStackCount()*ability:GetTalentSpecialValueFor("quill_stack_damage")
						self:GetAbility():DealDamage(self:GetCaster(), enemy, damage, {damage_type = DAMAGE_TYPE_PHYSICAL}, 0)
						if enemy:IsAlive() then
							enemy:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_quills_enemy", {Duration = ability:GetTalentSpecialValueFor("quill_stack_duration")}):IncrementStackCount()
						end
					else
						self:GetAbility():DealDamage(self:GetCaster(), enemy, ability:GetTalentSpecialValueFor("quill_base_damage"), {damage_type = DAMAGE_TYPE_PHYSICAL}, 0)
						if enemy:IsAlive() then
							enemy:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_quills_enemy", {Duration = ability:GetTalentSpecialValueFor("quill_stack_duration")}):IncrementStackCount()
						end
					end
				end
			end
		end
	end
end

function modifier_spiky_shell:GetModifierIncomingDamage_Percentage()
	return self:GetTalentSpecialValueFor("damage_reduction")
end

function modifier_spiky_shell:IsHidden()
	return true
end