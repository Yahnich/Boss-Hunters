lifestealer_ghoul_frenzy_bh = class({})

function lifestealer_ghoul_frenzy_bh:GetIntrinsicModifierName()
    return "modifier_lifestealer_ghoul_frenzy_bh_handle"
end

modifier_lifestealer_ghoul_frenzy_bh_handle = class({})
LinkLuaModifier( "modifier_lifestealer_ghoul_frenzy_bh_handle", "heroes/hero_lifestealer/lifestealer_ghoul_frenzy_bh.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_lifestealer_ghoul_frenzy_bh_handle:OnCreated(kv)
	self:OnRefresh()
end

function modifier_lifestealer_ghoul_frenzy_bh_handle:OnRefresh(kv)
	self.duration = self:GetTalentSpecialValueFor("duration")
	self.attack_speed = self:GetTalentSpecialValueFor("attack_speed_bonus")
	
	self.talent1 = self:GetCaster():HasTalent("special_bonus_unique_lifestealer_ghoul_frenzy_1")
	self.talent2 = self:GetCaster():HasTalent("special_bonus_unique_lifestealer_ghoul_frenzy_2")
	self.talent2Chance = self:GetCaster():FindTalentValue("special_bonus_unique_lifestealer_ghoul_frenzy_2")
	self.talent2Damage = self:GetCaster():FindTalentValue("special_bonus_unique_lifestealer_ghoul_frenzy_2", "value2") / 100
end

function modifier_lifestealer_ghoul_frenzy_bh_handle:DeclareFunctions()
	return { MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_EVENT_ON_ATTACK_LANDED  }
end

function modifier_lifestealer_ghoul_frenzy_bh_handle:OnAttackLanded(params)
	if params.attacker == self:GetParent() then
		params.target:AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_lifestealer_ghoul_frenzy_bh_debuff", {duration = self.duration} )
		if self.talent1 then
			params.attacker:AddNewModifier( params.attacker, self:GetAbility(), "modifier_lifestealer_ghoul_frenzy_bh_buff", {duration = self.duration} )
		end
		if self.talent2 and self:RollPRNG( self.talent2Chance ) then
			self:GetAbility():DealDamage( params.attacker, params.target, params.target:GetHealth() * self.talent2Damage, {damage_type = DAMAGE_TYPE_PURE}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE )
			local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_phantom_assassin/phantom_assassin_crit_impact.vpcf", PATTACH_CUSTOMORIGIN, params.attacker )
                    ParticleManager:SetParticleControlEnt( nFXIndex, 0, params.target, PATTACH_POINT_FOLLOW, "attach_hitloc", params.target:GetOrigin(), true )
                    ParticleManager:SetParticleControl( nFXIndex, 1, params.target:GetOrigin() )
                    ParticleManager:SetParticleControlForward( nFXIndex, 1, -params.attacker:GetForwardVector() )
                    ParticleManager:SetParticleControlEnt( nFXIndex, 10, params.target, PATTACH_ABSORIGIN_FOLLOW, nil, params.target:GetOrigin(), true )
                    ParticleManager:ReleaseParticleIndex( nFXIndex )
		end
	end
end

function modifier_lifestealer_ghoul_frenzy_bh_handle:GetModifierAttackSpeedBonus_Constant(params)
	return self.attack_speed
end

function modifier_lifestealer_ghoul_frenzy_bh_handle:IsHidden()
    return true
end

modifier_lifestealer_ghoul_frenzy_bh_debuff = class({})
LinkLuaModifier( "modifier_lifestealer_ghoul_frenzy_bh_debuff", "heroes/hero_lifestealer/lifestealer_ghoul_frenzy_bh.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_lifestealer_ghoul_frenzy_bh_debuff:OnCreated(kv)
	self:OnRefresh()
end

function modifier_lifestealer_ghoul_frenzy_bh_debuff:OnRefresh(kv)
	self.armor_reduction = self:GetTalentSpecialValueFor("armor_reduction")
	
	self.talent1Val = -self:GetTalentSpecialValueFor("attack_speed_bonus") * self:GetCaster():FindTalentValue("special_bonus_unique_lifestealer_ghoul_frenzy_1") / 100
end

function modifier_lifestealer_ghoul_frenzy_bh_debuff:DeclareFunctions()
	return { MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT  }
end

function modifier_lifestealer_ghoul_frenzy_bh_debuff:GetModifierPhysicalArmorBonus(params)
	return self.armor_reduction
end

function modifier_lifestealer_ghoul_frenzy_bh_debuff:GetModifierAttackSpeedBonus_Constant(params)
	return self.talent1Val
end

function modifier_lifestealer_ghoul_frenzy_bh_debuff:GetEffectName()
	return "particles/items2_fx/orb_of_venom.vpcf"
end

modifier_lifestealer_ghoul_frenzy_bh_buff = class({})
LinkLuaModifier( "modifier_lifestealer_ghoul_frenzy_bh_buff", "heroes/hero_lifestealer/lifestealer_ghoul_frenzy_bh.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_lifestealer_ghoul_frenzy_bh_buff:OnCreated(kv)
	self:OnRefresh()
end

function modifier_lifestealer_ghoul_frenzy_bh_buff:OnRefresh(kv)
	self.armor_reduction = -self:GetTalentSpecialValueFor("armor_reduction")
	self.talent1Val = self:GetCaster():FindTalentValue("special_bonus_unique_lifestealer_ghoul_frenzy_1") / 100
end

function modifier_lifestealer_ghoul_frenzy_bh_buff:DeclareFunctions()
	return { MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS }
end

function modifier_lifestealer_ghoul_frenzy_bh_buff:GetModifierPhysicalArmorBonus(params)
	return self.armor_reduction * self.talent1Val
end