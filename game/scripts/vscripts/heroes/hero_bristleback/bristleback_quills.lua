bristleback_quills = class({})
LinkLuaModifier( "modifier_quills", "heroes/hero_bristleback/bristleback_quills.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_quills_enemy", "heroes/hero_bristleback/bristleback_quills.lua",LUA_MODIFIER_MOTION_NONE )

function bristleback_quills:OnToggle()
	local caster = self:GetCaster()

	if self:GetToggleState() then
		caster:AddNewModifier(caster, self, "modifier_quills", {})
		self:RefundManaCost()
		self:EndCooldown()
	else
		caster:RemoveModifierByName("modifier_quills")
		self:RefundManaCost()
		self:SetCooldown()
	end
end

modifier_quills = class({})
function modifier_quills:OnCreated(table)
	if IsServer() then
		self:StartIntervalThink(self:GetAbility():GetCooldown(self:GetAbility():GetLevel()))
	end
end

function modifier_quills:OnRemoved()
	if IsServer() then
		StopSoundOn("Hero_Bristleback.QuillSpray.Cast", self:GetCaster())
	end
end

function modifier_quills:OnIntervalThink()
	if self:GetCaster():GetMana() >= self:GetAbility():GetManaCost(self:GetAbility():GetLevel()) and self:GetCaster():IsAlive() then

		EmitSoundOn("Hero_Bristleback.QuillSpray.Cast", self:GetCaster())

		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_bristleback/bristleback_quill_spray.vpcf", PATTACH_POINT, self:GetCaster())
		ParticleManager:SetParticleControl(nfx, 0, self:GetCaster():GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex(nfx)
		local enemies = self:GetCaster():FindEnemyUnitsInRadius(self:GetCaster():GetAbsOrigin(), self:GetSpecialValueFor("radius"), {})
		for _,enemy in pairs(enemies) do
			EmitSoundOn("Hero_Bristleback.QuillSpray.Target", enemy)
			if enemy:HasModifier("modifier_quills_enemy") then
				local damage = self:GetSpecialValueFor("quill_base_damage") + enemy:FindModifierByName("modifier_quills_enemy"):GetStackCount()*self:GetSpecialValueFor("quill_stack_damage")
				self:GetAbility():DealDamage(self:GetCaster(), enemy, damage, {damage_type = DAMAGE_TYPE_PHYSICAL}, 0)
				if enemy:IsAlive() then
					if enemy:FindModifierByName("modifier_quills_enemy"):GetStackCount() < self:GetSpecialValueFor("quill_max_stacks") then
						enemy:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_quills_enemy", {Duration = self:GetSpecialValueFor("quill_stack_duration")}):IncrementStackCount()
					else
						enemy:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_quills_enemy", {Duration = self:GetSpecialValueFor("quill_stack_duration")})
					end
				end
			else
				self:GetAbility():DealDamage(self:GetCaster(), enemy, self:GetSpecialValueFor("quill_base_damage"), {damage_type = DAMAGE_TYPE_PHYSICAL}, 0)
				if enemy:IsAlive() then
					enemy:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_quills_enemy", {Duration = self:GetSpecialValueFor("quill_stack_duration")}):IncrementStackCount()
				end
			end
		end

		if self:GetCaster():HasTalent("special_bonus_unique_bristleback_quills_1") and self:GetCaster():FindAbilityByName("bristleback_snot"):IsTrained() and RollPercentage(self:GetCaster():FindTalentValue("special_bonus_unique_bristleback_quills_1")) then
			self:GetCaster():FindAbilityByName("bristleback_snot"):CastAbility()
		end

		self:GetCaster():SpendMana(self:GetAbility():GetManaCost(self:GetAbility():GetLevel()), self:GetAbility())
	end
end

modifier_quills_enemy = class({})
function modifier_quills_enemy:OnRemoved()
	if IsServer() then
		StopSoundOn("Hero_Bristleback.QuillSpray.Target", self:GetParent())
		local count = self:GetStackCount()
		if self:GetStackCount() > 0 and self:GetParent():IsAlive() then
			self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_quills_enemy", {Duration = self:GetSpecialValueFor("quill_stack_duration")}):SetStackCount(count-1)
		else
			self:Destroy()
		end
	end
end

function modifier_quills_enemy:GetEffectName()
	return "particles/units/heroes/hero_bristleback/bristleback_quill_spray_hit.vpcf"
end

function modifier_quills_enemy:IsDebuff()
	return true
end