function DeathCoil( event )
	-- Variables
	local caster = event.caster
	local target = event.target
	local ability = event.ability
	local damage = ability:GetTalentSpecialValueFor( "target_damage")
	local self_heal = ability:GetTalentSpecialValueFor( "self_heal" )
	local heal = ability:GetTalentSpecialValueFor( "heal_amount" )
	local heal_pct = ability:GetTalentSpecialValueFor( "heal_pct" ) / 100
	local projectile_speed = ability:GetTalentSpecialValueFor( "projectile_speed" )
	local particle_name = "particles/units/heroes/hero_abaddon/abaddon_death_coil.vpcf"

	-- Play the ability sound
	caster:EmitSound("Hero_Abaddon.DeathCoil.Cast")
	target:EmitSound("Hero_Abaddon.DeathCoil.Target")

	-- If the target and caster are on a different team, do Damage. Heal otherwise
	if target:GetTeamNumber() ~= caster:GetTeamNumber() then
		ApplyDamage({ victim = target, attacker = caster, damage = damage,	damage_type = DAMAGE_TYPE_MAGICAL, ability = ability})
	else
		target:HealEvent(heal + target:GetMaxHealth()*heal_pct, ability, caster)
	end

	-- Self Damage
	caster:HealEvent(self_heal + caster:GetMaxHealth()*heal_pct, ability, caster)

	local projectile = {
		Target = target,
		Source = caster,
		Ability = ability,
		EffectName = particle_name,
		bDodgable = false,
		bProvidesVision = false,
		iMoveSpeed = 6000,
		iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
	}
	ProjectileManager:CreateTrackingProjectile(projectile)

end

abaddon_curse_ebf = class({})

function abaddon_curse_ebf:GetIntrinsicModifierName()
	return "modifier_abaddon_curse_passive"
end

LinkLuaModifier( "modifier_abaddon_curse_passive", "lua_abilities/heroes/abaddon.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_abaddon_curse_passive = class({})

function modifier_abaddon_curse_passive:IsHidden()
	return true
end

function modifier_abaddon_curse_passive:DeclareFunctions()
	funcs = {
				MODIFIER_EVENT_ON_TAKEDAMAGE
			}
	return funcs
end

function modifier_abaddon_curse_passive:OnTakeDamage(params)
	if IsServer() then
		if params.attacker == self:GetParent() then
			params.unit:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_abaddon_curse_debuff", {duration = self:GetAbility():GetTalentSpecialValueFor("debuff_duration")} )
			params.attacker:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_abaddon_curse_buff", {duration = self:GetAbility():GetTalentSpecialValueFor("buff_duration")} )
		end
		if params.unit:HasModifier("modifier_abaddon_curse_debuff") then
			params.attacker:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_abaddon_curse_buff", {duration = self:GetAbility():GetTalentSpecialValueFor("buff_duration")} )
		end
	end
end

LinkLuaModifier( "modifier_abaddon_curse_buff", "lua_abilities/heroes/abaddon.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_abaddon_curse_buff = class({})

function modifier_abaddon_curse_buff:GetEffectName()
	return "particles/units/heroes/hero_abaddon/abaddon_frost_buff.vpcf"
end

function modifier_abaddon_curse_buff:OnCreated()
	self.movespeed = self:GetAbility():GetSpecialValueFor("move_speed_pct")
	self.attackspeed = self:GetAbility():GetSpecialValueFor("attack_speed")
end

function modifier_abaddon_curse_buff:DeclareFunctions()
	funcs = {
				MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
				MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
			}
	return funcs
end

function modifier_abaddon_curse_buff:GetModifierMoveSpeedBonus_Percentage()
	return self.movespeed
end

function modifier_abaddon_curse_buff:GetModifierAttackSpeedBonus_Constant()
	return self.attackspeed
end

LinkLuaModifier( "modifier_abaddon_curse_debuff", "lua_abilities/heroes/abaddon.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_abaddon_curse_debuff = class({})

function modifier_abaddon_curse_debuff:GetEffectName()
	return "particles/units/heroes/hero_abaddon/abaddon_frost_slow.vpcf"
end

function modifier_abaddon_curse_debuff:OnCreated()
	self.movespeed = self:GetAbility():GetSpecialValueFor("slow_pct")
	self.attackspeed = self:GetAbility():GetSpecialValueFor("attack_slow_tooltip")
end

function modifier_abaddon_curse_debuff:DeclareFunctions()
	funcs = {
				MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
				MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
			}
	return funcs
end

function modifier_abaddon_curse_debuff:GetModifierMoveSpeedBonus_Percentage()
	return self.movespeed
end

function modifier_abaddon_curse_debuff:GetModifierAttackSpeedBonus_Constant()
	return self.attackspeed
end

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
		self:GetCaster():RemoveModifierByName("modifier_abaddon_brume_weaver_handler_buff")
		hTarget:AddNewModifier(self:GetCaster(), self, "modifier_abaddon_brume_weaver_handler_buff_active", {duration = self:GetTalentSpecialValueFor("buff_duration")})
		hTarget:AddNewModifier(self:GetCaster(), self, "modifier_abaddon_brume_weaver_handler_buff", {duration = self:GetTalentSpecialValueFor("buff_duration")})
	end
end

LinkLuaModifier( "modifier_abaddon_brume_weaver_handler", "lua_abilities/heroes/abaddon.lua" ,LUA_MODIFIER_MOTION_NONE )
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
	if  self:GetAbility():IsCooldownReady() then
		self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_abaddon_brume_weaver_handler_buff", {})
	elseif not self:GetAbility():IsCooldownReady() and self:GetParent():HasModifier("modifier_abaddon_brume_weaver_handler_buff") and not self:GetParent():HasModifier("modifier_abaddon_brume_weaver_handler_buff_active") then
		self:GetParent():RemoveModifierByName("modifier_abaddon_brume_weaver_handler_buff")
	end
end

LinkLuaModifier( "modifier_abaddon_brume_weaver_handler_buff", "lua_abilities/heroes/abaddon.lua" ,LUA_MODIFIER_MOTION_NONE )
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
		local flHeal = math.ceil(params.original_damage * (1 - params.unit:GetPhysicalArmorReduction() / 100 ) * self.healFactor / self.healDuration)
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

LinkLuaModifier( "modifier_abaddon_brume_weaver_handler_heal", "lua_abilities/heroes/abaddon.lua" ,LUA_MODIFIER_MOTION_NONE )
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

LinkLuaModifier( "modifier_abaddon_brume_weaver_handler_buff_active", "lua_abilities/heroes/abaddon.lua" ,LUA_MODIFIER_MOTION_NONE )
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