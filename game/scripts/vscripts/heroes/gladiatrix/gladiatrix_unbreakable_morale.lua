gladiatrix_unbreakable_morale = class({})

function gladiatrix_unbreakable_morale:GetIntrinsicModifierName()
	return "modifier_gladiatrix_unbreakable_morale_passive"
end

function gladiatrix_unbreakable_morale:OnSpellStart()
	if IsServer() then
		local hTarget = self:GetCursorTarget()
		EmitSoundOn("Hero_LegionCommander.PressTheAttack", hTarget)
		hTarget:Purge(false, true, false, true, true)
		hTarget:AddNewModifier(self:GetCaster(), self, "modifier_gladiatrix_unbreakable_morale_buff", {duration = self:GetSpecialValueFor("duration")})
		if self:GetCaster():HasTalent("gladiatrix_unbreakable_morale_talent_1") then
			hTarget:AddNewModifier(self:GetCaster(), self, "modifier_gladiatrix_unbreakable_morale_hp_talent", {duration = self:GetSpecialValueFor("duration")})
		end
	end
end

LinkLuaModifier( "modifier_gladiatrix_unbreakable_morale_passive", "heroes/gladiatrix/gladiatrix_unbreakable_morale.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_gladiatrix_unbreakable_morale_passive = class({})

function modifier_gladiatrix_unbreakable_morale_passive:OnCreated()
	self.procChance = self:GetAbility():GetSpecialValueFor("passive_chance")
end

function modifier_gladiatrix_unbreakable_morale_passive:OnRefresh()
	self.procChance = self:GetAbility():GetSpecialValueFor("passive_chance")
end

function modifier_gladiatrix_unbreakable_morale_passive:IsHidden()
	return true
end

function modifier_gladiatrix_unbreakable_morale_passive:DeclareFunctions()
	funcs = {
				MODIFIER_EVENT_ON_ATTACK_LANDED
			}
	return funcs
end

function modifier_gladiatrix_unbreakable_morale_passive:OnAttackLanded(params)
	if IsServer() then
		if params.target:IsSameTeam(self:GetParent()) and CalculateDistance(params.target, self:GetParent()) <= self:GetAbility():GetCastRange(self:GetParent():GetAbsOrigin(), params.target) and not self:GetParent():HasModifier("modifier_gladiatrix_unbreakable_morale_passive_cooldown") and not params.target:HasModifier("modifier_gladiatrix_unbreakable_morale_buff") then
			print(self.procChance)
			if RollPercentage(self.procChance) and self:GetParent():IsAlive() then
				self:GetParent():SetCursorCastTarget(params.target)
				self:GetAbility():OnSpellStart()
				self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_gladiatrix_unbreakable_morale_passive_cooldown", {duration = self:GetAbility():GetTrueCooldown()})
			end
		end
	end
end

LinkLuaModifier( "modifier_gladiatrix_unbreakable_morale_passive_cooldown", "heroes/gladiatrix/gladiatrix_unbreakable_morale.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_gladiatrix_unbreakable_morale_passive_cooldown = class({})

function modifier_gladiatrix_unbreakable_morale_passive_cooldown:IsPurgable()
	return false
end

function modifier_gladiatrix_unbreakable_morale_passive_cooldown:IsDebuff()
	return true
end

LinkLuaModifier( "modifier_gladiatrix_unbreakable_morale_buff", "heroes/gladiatrix/gladiatrix_unbreakable_morale.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_gladiatrix_unbreakable_morale_buff = class({})

function modifier_gladiatrix_unbreakable_morale_buff:OnCreated()
	self.hpRegen = self:GetAbility():GetSpecialValueFor("hp_regen")
	self.attackSpeed = self:GetAbility():GetSpecialValueFor("attack_speed")
	if IsServer() then
		self:StartIntervalThink(0)
		self:GetParent().press = ParticleManager:CreateParticle("particles/units/heroes/hero_legion_commander/legion_commander_press.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControl(self:GetParent().press, 0, self:GetParent():GetAbsOrigin())
		ParticleManager:SetParticleControl(self:GetParent().press, 1, self:GetParent():GetAbsOrigin())
		ParticleManager:SetParticleControlEnt(self:GetParent().press, 2, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetParent():GetAbsOrigin(), true)
		ParticleManager:SetParticleControl(self:GetParent().press, 3, self:GetParent():GetAbsOrigin())
		self:AttachEffect(self:GetParent().press)
	end
end

function modifier_gladiatrix_unbreakable_morale_buff:OnIntervalThink()
	self:GetParent():Purge(false, true, false, true, true)
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


LinkLuaModifier( "modifier_gladiatrix_unbreakable_morale_hp_talent", "heroes/gladiatrix/gladiatrix_unbreakable_morale.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_gladiatrix_unbreakable_morale_hp_talent = class({})

function modifier_gladiatrix_unbreakable_morale_hp_talent:OnCreated()
	if IsServer() then
		self.hpBonus = math.max( self:GetAbility():GetSpecialValueFor("max_hp_bonus_talent"), self:GetAbility():GetSpecialValueFor("max_hp_bonus_talent_pct") * self:GetParent():GetMaxHealth() / 100 )
		self.healPerTick = self.hpBonus * FrameTime() / self:GetDuration()
		self:SetStackCount(self.hpBonus)
		self:StartIntervalThink(0)
	end
end

function modifier_gladiatrix_unbreakable_morale_hp_talent:OnRefresh()
	if IsServer() then
		local oldHP = self:GetParent():GetMaxHealth() - self.hpBonus
		self.hpBonus = math.max( self:GetAbility():GetSpecialValueFor("max_hp_bonus_talent"), self:GetAbility():GetSpecialValueFor("max_hp_bonus_talent_pct") * oldHP / 100 )
		self:SetStackCount(self.hpBonus)
		self.healPerTick = self.hpBonus * FrameTime() / self:GetDuration()
	end
end

function modifier_gladiatrix_unbreakable_morale_hp_talent:OnIntervalThink()
	if self:GetParent():GetHealthPercent() < 100 then
		self:GetParent():SetHealth(self:GetParent():GetHealth() + self.healPerTick)
	end
end

function modifier_gladiatrix_unbreakable_morale_hp_talent:OnDestroy()
	if IsServer() then
		ParticleManager:DestroyParticle(self:GetParent().press, false)
		ParticleManager:ReleaseParticleIndex(self:GetParent().press)
		self:GetParent().press = nil
	end
end

function modifier_gladiatrix_unbreakable_morale_hp_talent:DeclareFunctions()
	funcs = {
				MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS,
			}
	return funcs
end

function modifier_gladiatrix_unbreakable_morale_hp_talent:GetModifierExtraHealthBonus()
	return self:GetStackCount()
end

function modifier_gladiatrix_unbreakable_morale_hp_talent:IsHidden()
	return true
end
