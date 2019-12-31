lycan_howl_bh = class({})

function lycan_howl_bh:OnSpellStart()
	local caster = self:GetCaster()
	
	local duration = self:GetTalentSpecialValueFor("howl_duration")
	local radius = self:GetTalentSpecialValueFor("radius")
	local talent2 = caster:HasTalent("special_bonus_unique_lycan_howl_2")
	if not GameRules:IsDaytime() then
		duration = duration * 2
	end
	for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), radius ) ) do
		enemy:AddNewModifier(caster, self, "modifier_lycan_howl_bh_buff", {duration = duration})
		if talent1 then
			enemy:AddNewModifier(caster, self, "modifier_lycan_howl_bh_fear", {duration = duration})
		end
	end
	
	ParticleManager:FireParticle("particles/units/heroes/hero_lycan/lycan_howl_cast.vpcf", PATTACH_POINT_FOLLOW, caster)
	EmitSoundOn("Hero_Lycan.Howl", caster)
end

modifier_lycan_howl_bh_buff = class({})
LinkLuaModifier("modifier_lycan_howl_bh_buff", "heroes/hero_lycan/lycan_howl_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_lycan_howl_bh_buff:OnCreated()
	self.dmg = self:GetTalentSpecialValueFor("dmg_reduction")
	self.armor = self:GetTalentSpecialValueFor("armor_reduction")
	self.lifesteal = self:GetCaster():FindTalentValue("special_bonus_unique_lycan_howl_1") / 100
	self.minionLS = self:GetCaster():FindTalentValue("special_bonus_unique_lycan_howl_1", "value2") / 100
end

function modifier_lycan_howl_bh_buff:OnRefresh()
	self:OnCreated()
end

function modifier_lycan_howl_bh_buff:DeclareFunctions()
	return {MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
			MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
			MODIFIER_EVENT_ON_TAKEDAMAGE }
end

function modifier_lycan_howl_bh_buff:OnTakeDamage(params)
	if params.unit == self:GetParent() and self.lifesteal > 0 and self:GetParent():GetHealth() > 0 and not self:GetParent():IsIllusion() then
		local lifesteal = self.lifesteal
		if self:GetParent():IsMinion() and not ( ( params.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK and not params.inflictor) or HasBit( params.damage_flags, DOTA_DAMAGE_FLAG_PROPERTY_FIRE) ) then
			lifesteal = self.minionLS
		end
		local lifesteal = ParticleManager:CreateParticle("particles/units/heroes/hero_skeletonking/wraith_king_vampiric_aura_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, params.attacker)
				ParticleManager:SetParticleControlEnt(lifesteal, 0, params.attacker, PATTACH_POINT_FOLLOW, "attach_hitloc", params.attacker:GetAbsOrigin(), true)
				ParticleManager:SetParticleControlEnt(lifesteal, 1, params.attacker, PATTACH_POINT_FOLLOW, "attach_hitloc", params.attacker:GetAbsOrigin(), true)
				ParticleManager:ReleaseParticleIndex(lifesteal)
		params.attacker:HealEvent( params.damage * self.lifesteal, self:GetAbility(), self:GetCaster() )
	end
end

function modifier_lycan_howl_bh_buff:GetModifierBaseDamageOutgoing_Percentage()
	return self.dmg
end

function modifier_lycan_howl_bh_buff:GetModifierPhysicalArmorBonus()
	return self.armor
end

function modifier_lycan_howl_bh_buff:GetEffectName()
	return "particles/units/heroes/hero_lycan/lycan_howl_buff.vpcf"
end

modifier_lycan_howl_bh_fear = class({})
LinkLuaModifier("modifier_lycan_howl_bh_fear", "heroes/hero_lycan/lycan_howl_bh", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
	function modifier_lycan_howl_bh_fear:OnCreated()
		self:StartIntervalThink(0.2)
	end
	
	function modifier_lycan_howl_bh_fear:OnIntervalThink()
		local direction = CalculateDirection(self:GetParent(), self:GetCaster())
		self:GetParent():MoveToPosition(self:GetParent():GetAbsOrigin() + direction * self:GetParent():GetIdealSpeed() * 0.2)
	end
end

function modifier_lycan_howl_bh_fear:GetEffectName()
	return "particles/units/heroes/hero_lycan/lycan_howl_buff.vpcf"
end

function modifier_lycan_howl_bh_fear:CheckState()
	return {[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
			[MODIFIER_STATE_DISARMED] = true,
			[MODIFIER_STATE_SILENCED] = true,
			[MODIFIER_STATE_PROVIDES_VISION] = true,
			}
end