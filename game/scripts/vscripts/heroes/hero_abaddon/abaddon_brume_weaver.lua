abaddon_brume_weaver = class({})

function abaddon_brume_weaver:GetIntrinsicModifierName()
	return "modifier_abaddon_brume_weaver_handler"
end

function abaddon_brume_weaver:GetCastAnimation()
	return ACT_DOTA_ATTACK
end

function abaddon_brume_weaver:OnSpellStart()
	if IsServer() then
		local hTarget = self:GetCursorTarget()
		EmitSoundOn("Hero_Abaddon.CastBrume", hTarget)
		if not self:GetCaster():HasTalent("special_bonus_unique_abaddon_brume_weaver_1") then self:GetCaster():RemoveModifierByName("modifier_abaddon_brume_weaver_handler_buff") end
		hTarget:AddNewModifier(self:GetCaster(), self, "modifier_abaddon_brume_weaver_handler_buff_active", {duration = self:GetTalentSpecialValueFor("buff_duration")})
		hTarget:AddNewModifier(self:GetCaster(), self, "modifier_abaddon_brume_weaver_handler_buff", {duration = self:GetTalentSpecialValueFor("buff_duration")})
	end
end

LinkLuaModifier( "modifier_abaddon_brume_weaver_handler", "heroes/hero_abaddon/abaddon_brume_weaver" ,LUA_MODIFIER_MOTION_NONE )
modifier_abaddon_brume_weaver_handler = class({})

function modifier_abaddon_brume_weaver_handler:OnCreated()
	if IsServer() then
		self:StartIntervalThink(0.03)
	end
end

function modifier_abaddon_brume_weaver_handler:IsHidden()
	return true
end

function modifier_abaddon_brume_weaver_handler:OnIntervalThink()
	if not self:GetParent():HasTalent("special_bonus_unique_abaddon_brume_weaver_1") then
		if  self:GetAbility():IsCooldownReady() then
			self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_abaddon_brume_weaver_handler_buff", {})
		elseif not self:GetAbility():IsCooldownReady() and self:GetParent():HasModifier("modifier_abaddon_brume_weaver_handler_buff") and not self:GetParent():HasModifier("modifier_abaddon_brume_weaver_handler_buff_active") then
			self:GetParent():RemoveModifierByName("modifier_abaddon_brume_weaver_handler_buff")
		end
	elseif not self:GetParent():HasModifier("modifier_abaddon_brume_weaver_handler_buff") then
		self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_abaddon_brume_weaver_handler_buff", {})
	end
end

LinkLuaModifier( "modifier_abaddon_brume_weaver_handler_buff", "heroes/hero_abaddon/abaddon_brume_weaver", LUA_MODIFIER_MOTION_NONE )
modifier_abaddon_brume_weaver_handler_buff = class({})

function modifier_abaddon_brume_weaver_handler_buff:OnCreated()
	self.healFactor = self:GetAbility():GetSpecialValueFor("heal_pct") / 100
	self.healDuration = self:GetAbility():GetSpecialValueFor("heal_duration")
	self.evasion = self:GetAbility():GetSpecialValueFor("evasion")
end

function modifier_abaddon_brume_weaver_handler_buff:OnRefresh()
	self.healFactor = self:GetAbility():GetSpecialValueFor("heal_pct") / 100
	self.healDuration = self:GetAbility():GetSpecialValueFor("heal_duration")
	self.evasion = self:GetAbility():GetSpecialValueFor("evasion")
end

function modifier_abaddon_brume_weaver_handler_buff:DeclareFunctions()
	funcs = {
				MODIFIER_EVENT_ON_TAKEDAMAGE,
				MODIFIER_PROPERTY_EVASION_CONSTANT,
			}
	return funcs
end

function modifier_abaddon_brume_weaver_handler_buff:GetModifierEvasion_Constant(params)
	return self.evasion
end

function modifier_abaddon_brume_weaver_handler_buff:OnTakeDamage(params)
	if params.unit == self:GetParent() then
		local damage = params.damage
		local flHeal = math.ceil(params.damage * self.healFactor / self.healDuration)
		local healModifier = self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_abaddon_brume_weaver_handler_heal", {duration = self.healDuration})
		healModifier:SetStackCount(flHeal)
		local procBrume = ParticleManager:CreateParticle("particles/abaddon_brume_proc.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
			ParticleManager:SetParticleControlEnt(procBrume, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex(procBrume)
	end
end

function modifier_abaddon_brume_weaver_handler_buff:GetEffectName()
	return "particles/units/heroes/hero_abaddon/abaddon_frost_slow.vpcf"
end

LinkLuaModifier( "modifier_abaddon_brume_weaver_handler_heal", "heroes/hero_abaddon/abaddon_brume_weaver", LUA_MODIFIER_MOTION_NONE )
modifier_abaddon_brume_weaver_handler_heal = class({})

function modifier_abaddon_brume_weaver_handler_heal:IsHidden()
	return true
end

function modifier_abaddon_brume_weaver_handler_heal:DeclareFunctions()
	funcs = {
				MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
			}
	return funcs
end

function modifier_abaddon_brume_weaver_handler_heal:GetModifierConstantHealthRegen()
	return self:GetStackCount()
end

function modifier_abaddon_brume_weaver_handler_heal:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

LinkLuaModifier( "modifier_abaddon_brume_weaver_handler_buff_active", "heroes/hero_abaddon/abaddon_brume_weaver", LUA_MODIFIER_MOTION_NONE )
modifier_abaddon_brume_weaver_handler_buff_active = class({})

function modifier_abaddon_brume_weaver_handler_buff_active:IsHidden()
	return true
end

function modifier_abaddon_brume_weaver_handler_buff_active:OnCreated()
	self.hpRegen = self:GetAbility():GetSpecialValueFor("base_heal")
end

function modifier_abaddon_brume_weaver_handler_buff_active:DeclareFunctions()
	funcs = {
				MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
			}
	return funcs
end

function modifier_abaddon_brume_weaver_handler_buff_active:GetModifierConstantHealthRegen()
	return self.hpRegen
end