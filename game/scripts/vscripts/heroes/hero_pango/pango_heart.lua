pango_heart = class({})
LinkLuaModifier("modifier_pango_heart_handle", "heroes/hero_pango/pango_heart", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_pango_heart_delay", "heroes/hero_pango/pango_heart", LUA_MODIFIER_MOTION_NONE)

function pango_heart:IsStealable()
	return false
end

function pango_heart:IsHiddenWhenStolen()
	return false
end

function pango_heart:GetIntrinsicModifierName()
	return "modifier_pango_heart_handle"
end

modifier_pango_heart_handle = class({})
function modifier_pango_heart_handle:OnCreated()
	self.duration = self:GetSpecialValueFor("duration")
end

function modifier_pango_heart_handle:OnRefresh()
	self.duration = self:GetSpecialValueFor("duration")
end

function modifier_pango_heart_handle:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_pango_heart_handle:OnAttackLanded(params)
	if IsServer() then
		local caster = self:GetCaster()
		local attacker = params.attacker
		local target = params.target

		self.chance = self:GetSpecialValueFor("chance")
		if attacker == caster and self:RollPRNG(self.chance) then
			local procType = RandomInt( 1, 3 )
			EmitSoundOn("Hero_Pangolier.LuckyShot.Proc", target)
			ParticleManager:FireRopeParticle("particles/units/heroes/hero_pangolier/pangolier_luckyshot_disarm_cast.vpcf", PATTACH_POINT_FOLLOW, caster, target, {}, "attach_hitloc")
			if attacker:HasTalent( "special_bonus_unique_pango_heart_1" ) and not attacker:IsInAbilityAttackMode() then
				local swashbuckle = caster:FindAbilityByName("pango_swashbuckler")
				local shield = caster:FindAbilityByName("pango_shield")
				local thunder = caster:FindAbilityByName("pango_ball")
				local abilitiesToRefresh = {}
				if not swashbuckle:IsCooldownReady() then
					table.insert( abilitiesToRefresh, swashbuckle )
				end
				if not shield:IsCooldownReady() then
					table.insert( abilitiesToRefresh, shield )
				end
				if not thunder:IsCooldownReady() then
					table.insert( abilitiesToRefresh, thunder )
				end
				local abilityToRefresh = abilitiesToRefresh[RandomInt(1, #abilitiesToRefresh)]
				if abilityToRefresh then
					abilityToRefresh:Refresh()
				end
			end
			local talent2 = attacker:HasTalent( "special_bonus_unique_pango_heart_2" )
			if procType == 1 or talent2 then -- moveslow
				target:AddNewModifier(caster, self:GetAbility(), "modifier_pango_lucky_shot_moveslow", {Duration = self.duration})
			end
			if procType == 2 or talent2 then -- attackslow
				target:AddNewModifier(caster, self:GetAbility(), "modifier_pango_lucky_shot_attackslow", {Duration = self.duration})
			end
			if procType == 3 or talent2 then -- armor reduction
				target:AddNewModifier(caster, self:GetAbility(), "modifier_pango_lucky_shot_armor", {Duration = self.duration})
			end
		end
	end
end

function modifier_pango_heart_handle:IsHidden()
	return true
end

function modifier_pango_heart_handle:IsPurgable()
	return false
end

modifier_pango_lucky_shot_armor = class({})
LinkLuaModifier("modifier_pango_lucky_shot_armor", "heroes/hero_pango/pango_heart", LUA_MODIFIER_MOTION_NONE)

function modifier_pango_lucky_shot_armor:OnCreated()
	self.reduction = self:GetSpecialValueFor("armor_reduc")
end

function modifier_pango_lucky_shot_armor:OnRefresh(table)
	self.reduction = self:GetSpecialValueFor("armor_reduc")
end

function modifier_pango_lucky_shot_armor:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end

function modifier_pango_lucky_shot_armor:GetModifierPhysicalArmorBonus()
	return self.reduction
end

function modifier_pango_lucky_shot_armor:IsDebuff()
	return true
end

function modifier_pango_lucky_shot_armor:GetEffectName()
	return "particles/units/heroes/hero_pangolier/pangolier_heartpiercer_debuff.vpcf"
end

function modifier_pango_lucky_shot_armor:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

modifier_pango_lucky_shot_moveslow = class({})
LinkLuaModifier("modifier_pango_lucky_shot_moveslow", "heroes/hero_pango/pango_heart", LUA_MODIFIER_MOTION_NONE)

function modifier_pango_lucky_shot_moveslow:OnCreated()
	self.slow = self:GetSpecialValueFor("slow_pct")
end

function modifier_pango_lucky_shot_moveslow:OnRefresh(table)
	self.slow = self:GetSpecialValueFor("slow_pct")
end

function modifier_pango_lucky_shot_moveslow:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_pango_lucky_shot_moveslow:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end

function modifier_pango_lucky_shot_moveslow:IsDebuff()
	return true
end

function modifier_pango_lucky_shot_moveslow:GetEffectName()
	return "particles/units/heroes/hero_sniper/sniper_headshot_slow.vpcf"
end

function modifier_pango_lucky_shot_moveslow:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

modifier_pango_lucky_shot_attackslow = class({})
LinkLuaModifier("modifier_pango_lucky_shot_attackslow", "heroes/hero_pango/pango_heart", LUA_MODIFIER_MOTION_NONE)

function modifier_pango_lucky_shot_attackslow:OnCreated()
	self.as = self:GetSpecialValueFor("attack_slow")
end

function modifier_pango_lucky_shot_attackslow:OnRefresh(table)
	self.as = self:GetSpecialValueFor("attack_slow")
end

function modifier_pango_lucky_shot_attackslow:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}
end

function modifier_pango_lucky_shot_attackslow:GetModifierAttackSpeedBonus_Constant()
	return self.as
end

function modifier_pango_lucky_shot_attackslow:IsDebuff()
	return true
end

function modifier_pango_lucky_shot_attackslow:GetEffectName()
	return "particles/items2_fx/sange_maim.vpcf"
end