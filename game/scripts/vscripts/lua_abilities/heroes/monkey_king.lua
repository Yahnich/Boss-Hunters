function JinguHit(keys)
	local caster = keys.caster
	local ability = keys.ability
	
	local jinguBuff = caster:FindModifierByName("modifier_jingu_mastery_activated")
	if jinguBuff then
		jinguBuff:DecrementStackCount()
		if jinguBuff:GetStackCount() <= 0 then
			jinguBuff:Destroy()
			caster:RemoveModifierByName("modifier_jingu_mastery_activated_damage")
		end
	end
end

function CheckJingu(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	if caster:HasModifier("modifier_jingu_mastery_activated") or target:IsIllusion() or not caster:IsRealHero() or caster:PassivesDisabled() then return
	else
		local jinguStack = target:FindModifierByName("modifier_jingu_mastery_hitcount")
		if not jinguStack then 
			ability:ApplyDataDrivenModifier(caster, target, "modifier_jingu_mastery_hitcount", {duration = ability:GetTalentSpecialValueFor("counter_duration")})
			jinguStack = target:FindModifierByName("modifier_jingu_mastery_hitcount")
			jinguStack:SetStackCount(0)
			
		end
		jinguStack:SetStackCount(jinguStack:GetStackCount() + 1)
		if not target.OverHeadJingu then 
			target.OverHeadJingu = ParticleManager:CreateParticle(keys.particle, PATTACH_OVERHEAD_FOLLOW, target)
			ParticleManager:SetParticleControl(target.OverHeadJingu, 0, target:GetAbsOrigin())
		end
		ParticleManager:SetParticleControl(target.OverHeadJingu, 1, Vector(0,jinguStack:GetStackCount(),0))
		
		if jinguStack:GetStackCount() == ability:GetTalentSpecialValueFor("required_hits") then
			local jinguBuff = ability:ApplyDataDrivenModifier(caster, caster, "modifier_jingu_mastery_activated", {})
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_jingu_mastery_activated_damage", {})
			jinguBuff:SetStackCount(ability:GetTalentSpecialValueFor("charges"))
			jinguStack:Destroy()			
		end
	end
end

function JinguOverheadDestroy(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	
	ParticleManager:DestroyParticle(target.OverHeadJingu, false)
	ParticleManager:ReleaseParticleIndex(target.OverHeadJingu)
	target.OverHeadJingu = nil
end

monkey_king_wukongs_stature = class({})

function monkey_king_wukongs_stature:GetIntrinsicModifierName()
	if self:GetCaster():HasScepter() then
		return "modifier_monkey_king_wukongs_stature_scepter"
	end
end

function monkey_king_wukongs_stature:OnSpellStart()
	local caster = self:GetCaster()
	caster:AddNewModifier(caster, self, "modifier_monkey_king_wukongs_stature_active", {duration = self:GetTalentSpecialValueFor("duration")})
end

function monkey_king_wukongs_stature:OnInventoryContentsChanged()
	local caster = self:GetCaster()
	if caster:HasScepter() then
		caster:AddNewModifier(caster, self, "modifier_monkey_king_wukongs_stature_scepter", {})
	else
		caster:RemoveModifierByName("modifier_monkey_king_wukongs_stature_scepter")
	end
end

modifier_monkey_king_wukongs_stature_scepter = class({})
LinkLuaModifier( "modifier_monkey_king_wukongs_stature_scepter", "lua_abilities/heroes/monkey_king.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_monkey_king_wukongs_stature_scepter:OnCreated()
	self.scepter_bonus = self:GetTalentSpecialValueFor("scepter_passive_bonus") / 100
	self.armor = self:GetTalentSpecialValueFor("bonus_armor")
	self.dmg = self:GetTalentSpecialValueFor("bonus_damage")
	self.range = self:GetTalentSpecialValueFor("bonus_attack_range")
	self.scale = self:GetTalentSpecialValueFor("bonus_model_scale")
end

function modifier_monkey_king_wukongs_stature_scepter:OnRefresh()
	self.scepter_bonus = self:GetTalentSpecialValueFor("scepter_passive_bonus") / 100
	self.armor = self:GetTalentSpecialValueFor("bonus_armor")
	self.dmg = self:GetTalentSpecialValueFor("bonus_damage")
	self.range = self:GetTalentSpecialValueFor("bonus_attack_range")
	self.scale = self:GetTalentSpecialValueFor("bonus_model_scale")
end

function modifier_monkey_king_wukongs_stature_scepter:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_MODEL_SCALE,
		MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
	}
end

function modifier_monkey_king_wukongs_stature_scepter:GetModifierPhysicalArmorBonus()
	return self.armor * self.scepter_bonus
end

function modifier_monkey_king_wukongs_stature_scepter:GetModifierBaseAttack_BonusDamage()
	return self.dmg * self.scepter_bonus
end

function modifier_monkey_king_wukongs_stature_scepter:GetModifierAttackRangeBonus()
	return self.range * self.scepter_bonus
end

function modifier_monkey_king_wukongs_stature_scepter:GetModifierModelScale()
	return self.scale * self.scepter_bonus
end

function modifier_monkey_king_wukongs_stature_scepter:IsHidden()
	return true
end



modifier_monkey_king_wukongs_stature_active = class({})
LinkLuaModifier( "modifier_monkey_king_wukongs_stature_active", "lua_abilities/heroes/monkey_king.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_monkey_king_wukongs_stature_active:OnCreated()
	self.armor = self:GetTalentSpecialValueFor("bonus_armor")
	self.dmg = self:GetTalentSpecialValueFor("bonus_damage")
	self.range = self:GetTalentSpecialValueFor("bonus_attack_range")
	self.scale = self:GetTalentSpecialValueFor("bonus_model_scale")
	self.bat = self:GetTalentSpecialValueFor("base_attack_time")
	self.ms = self:GetTalentSpecialValueFor("move_speed")
	if IsServer() then EmitSoundOn("Hero_MonkeyKing.FurArmy", self:GetParent()) end
end


function modifier_monkey_king_wukongs_stature_active:OnRefresh()
	self.armor = self:GetTalentSpecialValueFor("bonus_armor")
	self.dmg = self:GetTalentSpecialValueFor("bonus_damage")
	self.range = self:GetTalentSpecialValueFor("bonus_attack_range")
	self.scale = self:GetTalentSpecialValueFor("bonus_model_scale")
	self.bat = self:GetTalentSpecialValueFor("base_attack_time")
	self.ms = self:GetTalentSpecialValueFor("move_speed")
end

function modifier_monkey_king_wukongs_stature_active:OnDestroy()
	if IsServer() then EmitSoundOn("Hero_MonkeyKing.FurArmy.End", self:GetParent()) end
end

function modifier_monkey_king_wukongs_stature_active:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_MODEL_SCALE,
		MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
		MODIFIER_PROPERTY_MOVESPEED_LIMIT,
		MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE_MIN,
		MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
	}
end

function modifier_monkey_king_wukongs_stature_active:GetModifierPhysicalArmorBonus()
	return self.armor
end

function modifier_monkey_king_wukongs_stature_active:GetModifierBaseAttack_BonusDamage()
	return self.dmg
end

function modifier_monkey_king_wukongs_stature_active:GetModifierAttackRangeBonus()
	return self.range
end

function modifier_monkey_king_wukongs_stature_active:GetModifierModelScale()
	return self.scale
end

function modifier_monkey_king_wukongs_stature_active:GetModifierMoveSpeed_AbsoluteMin()
	return self.ms
end

function modifier_monkey_king_wukongs_stature_active:GetModifierMoveSpeed_Limit()
	return self.ms
end

function modifier_monkey_king_wukongs_stature_active:GetBaseAttackTime_Bonus()
	return self.bat
end

function modifier_monkey_king_wukongs_stature_active:GetStatusEffectName()
	return "particles/status_fx/status_effect_monkey_king_fur_army.vpcf"
end

function modifier_monkey_king_wukongs_stature_active:StatusEffectPriority()
	return 10
end