legion_commander_unbreakable_morale = class({})

-- function legion_commander_unbreakable_morale:GetIntrinsicModifierName()
	-- return "modifier_legion_commander_unbreakable_morale_passive"
-- end

function legion_commander_unbreakable_morale:OnSpellStart()
	if IsServer() then
		local target = self:GetCursorTarget()
		local caster = self:GetCaster()
		EmitSoundOn("Hero_LegionCommander.PressTheAttack", target)
		if self:GetCaster():HasScepter() then
			for _, ally in ipairs( caster:FindFriendlyUnitsInRadius( caster:GetAbsOrigin(), self:GetTrueCastRange() + 150 ) ) do
				if ally ~= target and ally:HasModifier("modifier_legion_commander_war_fury_buff") then
					self:UnbreakableMorale(ally)
				end
			end
		end
		self:UnbreakableMorale(target)
	end
end

function legion_commander_unbreakable_morale:UnbreakableMorale(target)
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")
	target:Dispel( caster, true )
	target:AddNewModifier( caster, self, "modifier_legion_commander_unbreakable_morale_buff", {duration = duration})
	target:AddNewModifier( caster, self, "modifier_legion_commander_unbreakable_morale_health_regen", {duration = duration})
	if caster:HasTalent("special_bonus_unique_legion_commander_unbreakable_morale_1") then
		target:AddNewModifier( caster, self, "modifier_legion_commander_unbreakable_morale_status_resist", {duration = duration})
	end
	if target.press then
		ParticleManager:ClearParticle(target.press)
		target.press = nil
	end
	target.press = ParticleManager:CreateParticle("particles/units/heroes/hero_legion_commander/legion_commander_press.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
			ParticleManager:SetParticleControl(target.press, 0, target:GetAbsOrigin())
			ParticleManager:SetParticleControl(target.press, 1, target:GetAbsOrigin())
			ParticleManager:SetParticleControlEnt(target.press, 2, target, PATTACH_POINT_FOLLOW, "attach_attack1", target:GetAbsOrigin(), true)
			ParticleManager:SetParticleControl(target.press, 3, target:GetAbsOrigin())
end

modifier_legion_commander_unbreakable_morale_buff = class({})
LinkLuaModifier( "modifier_legion_commander_unbreakable_morale_buff", "heroes/hero_legion_commander/legion_commander_unbreakable_morale" ,LUA_MODIFIER_MOTION_NONE )

function modifier_legion_commander_unbreakable_morale_buff:OnCreated()
	self:OnRefresh()
end

function modifier_legion_commander_unbreakable_morale_buff:OnRefresh()
	self.attackSpeed = self:GetAbility():GetSpecialValueFor("attack_speed")
	self.attackSpeedIncrease = self:GetAbility():GetSpecialValueFor("attack_speed_increase")
	
	self.talent2 = self:GetCaster():HasTalent("special_bonus_unique_legion_commander_unbreakable_morale_2")
	self.talent2Radius = self:GetCaster():FindTalentValue("special_bonus_unique_legion_commander_unbreakable_morale_2", "radius")
end

function modifier_legion_commander_unbreakable_morale_buff:OnDestroy()
	if IsServer() then
		ParticleManager:DestroyParticle(self:GetParent().press, false)
		ParticleManager:ReleaseParticleIndex(self:GetParent().press)
		self:GetParent().press = nil
	end
end

function modifier_legion_commander_unbreakable_morale_buff:DeclareFunctions()
	funcs = {
				MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
				MODIFIER_EVENT_ON_ATTACK_LANDED,
				MODIFIER_EVENT_ON_DEATH
				
			}
	return funcs
end

function modifier_legion_commander_unbreakable_morale_buff:OnAttackLanded(params)
	if params.attacker == self:GetParent() then
		self:IncrementStackCount()
	end
end

function modifier_legion_commander_unbreakable_morale_buff:OnDeath(params)
	if self.talent2 and params.unit ~= self:GetParent() and CalculateDistance( params.unit, self:GetParent() ) < self.talent2Radius then
		self:GetAbility():UnbreakableMorale( self:GetParent() )
	end
end

function modifier_legion_commander_unbreakable_morale_buff:GetModifierAttackSpeedBonus_Constant()
	return self.attackSpeed + self:GetStackCount() * self.attackSpeedIncrease
end

modifier_legion_commander_unbreakable_morale_health_regen = class({})
LinkLuaModifier( "modifier_legion_commander_unbreakable_morale_health_regen", "heroes/hero_legion_commander/legion_commander_unbreakable_morale" ,LUA_MODIFIER_MOTION_NONE )

function modifier_legion_commander_unbreakable_morale_health_regen:OnCreated()
	self:OnRefresh()
end

function modifier_legion_commander_unbreakable_morale_health_regen:OnRefresh()
	self.hpRegen = self:GetAbility():GetSpecialValueFor("hp_regen")
	self.hpRegenIncrease = self:GetAbility():GetSpecialValueFor("hp_regen_increase")
	
	self.talent1 = self:GetCaster():HasTalent("special_bonus_unique_legion_commander_unbreakable_morale_1")
	if self.talent1 then
		self.bonusArmor = self:GetCaster():FindTalentValue("special_bonus_unique_legion_commander_unbreakable_morale_1", "value2")
		self.bonusArmorIncrease = self:GetCaster():FindTalentValue("special_bonus_unique_legion_commander_unbreakable_morale_1", "value2_increase")
	end
	if IsServer() then self.deltaTime = GameRules:GetGameTime() end
end

function modifier_legion_commander_unbreakable_morale_health_regen:DeclareFunctions()
	funcs = {
				MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
				MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
				MODIFIER_EVENT_ON_ATTACK_LANDED,
				
			}
	return funcs
end

function modifier_legion_commander_unbreakable_morale_health_regen:GetModifierPhysicalArmorBonus()
	if self.talent1 then return self.bonusArmor + self:GetStackCount() * self.bonusArmorIncrease end
end

function modifier_legion_commander_unbreakable_morale_health_regen:GetModifierConstantHealthRegen()
	local regen = self.hpRegen + self:GetStackCount() * self.hpRegenIncrease
	if IsServer() and self:GetParent():GetHealthDeficit() > 0 then
		local delta = GameRules:GetGameTime() - (self.deltaTime or GameRules:GetGameTime())
		self:GetCaster().statsDamageHealed = (self:GetCaster().statsDamageHealed or 0) + math.min(  regen * delta, self:GetParent():GetHealthDeficit() )
		self.deltaTime = GameRules:GetGameTime()
	end
	return regen
end

function modifier_legion_commander_unbreakable_morale_health_regen:OnAttackLanded(params)
	if params.target == self:GetParent() then
		self:IncrementStackCount()
	end
end

function modifier_legion_commander_unbreakable_morale_health_regen:IsHidden()
	return true
end

modifier_legion_commander_unbreakable_morale_status_resist = class({})
LinkLuaModifier( "modifier_legion_commander_unbreakable_morale_status_resist", "heroes/hero_legion_commander/legion_commander_unbreakable_morale" ,LUA_MODIFIER_MOTION_NONE )

function modifier_legion_commander_unbreakable_morale_status_resist:OnCreated()
	self:OnRefresh()
end

function modifier_legion_commander_unbreakable_morale_status_resist:OnRefresh()
	self.statusResist = self:GetCaster():FindTalentValue("special_bonus_unique_legion_commander_unbreakable_morale_1", "value")
	self.statusResistIncrease = self:GetCaster():FindTalentValue("special_bonus_unique_legion_commander_unbreakable_morale_1", "value_increase")
end

function modifier_legion_commander_unbreakable_morale_status_resist:DeclareFunctions()
	funcs = {
				MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING
			}
	return funcs
end

function modifier_legion_commander_unbreakable_morale_status_resist:GetModifierStatusResistanceStacking( params )
	if IsServer() and params.unit and not params.unit:IsSameTeam( self:GetParent() ) then
		print("stranger danger")
		self:IncrementStackCount()
	end
	return self.statusResist + self:GetStackCount() * self.statusResistIncrease
end

function modifier_legion_commander_unbreakable_morale_status_resist:IsHidden()
	return true
end

-------------------------
-- UNUSED SHIT
-------------------------

modifier_legion_commander_unbreakable_morale_passive = class({})
LinkLuaModifier( "modifier_legion_commander_unbreakable_morale_passive", "heroes/hero_legion_commander/legion_commander_unbreakable_morale" ,LUA_MODIFIER_MOTION_NONE )

function modifier_legion_commander_unbreakable_morale_passive:OnCreated()
	self.procChance = self:GetAbility():GetSpecialValueFor("passive_chance")
end

function modifier_legion_commander_unbreakable_morale_passive:IsHidden()
	return true
end

function modifier_legion_commander_unbreakable_morale_passive:DeclareFunctions()
	funcs = {
				MODIFIER_EVENT_ON_ATTACK_LANDED
			}
	return funcs
end

function modifier_legion_commander_unbreakable_morale_passive:OnAttackLanded(params)
	if IsServer() then
		if params.target:GetTeam() == self:GetParent():GetTeam() and CalculateDistance(params.target, self:GetParent()) <= self:GetAbility():GetCastRange(self:GetParent():GetAbsOrigin(), params.target) and not self:GetParent():HasModifier("modifier_legion_commander_unbreakable_morale_passve_cooldown") and not params.target:HasModifier("modifier_legion_commander_unbreakable_morale_buff") then
			if RollPercentage(self.procChance) and self:GetParent():IsAlive() then
				self:GetAbility():UnbreakableMorale(params.target)
				EmitSoundOn("Hero_LegionCommander.PressTheAttack", params.target)
				self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_legion_commander_unbreakable_morale_passive_cooldown", {duration = self:GetAbility():GetTrueCooldown()})
			end
		end
	end
end

LinkLuaModifier( "modifier_legion_commander_unbreakable_morale_passive_cooldown", "heroes/hero_legion_commander/legion_commander_unbreakable_morale" ,LUA_MODIFIER_MOTION_NONE )
modifier_legion_commander_unbreakable_morale_passive_cooldown = class({})

function modifier_legion_commander_unbreakable_morale_passive_cooldown:IsDebuff()
	return true
end
