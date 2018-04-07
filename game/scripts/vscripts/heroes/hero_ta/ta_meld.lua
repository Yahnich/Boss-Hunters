ta_meld = class({})
LinkLuaModifier( "modifier_ta_meld", "heroes/hero_ta/ta_meld.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_ta_meld_armor", "heroes/hero_ta/ta_meld.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_ta_meld_enemy", "heroes/hero_ta/ta_meld.lua", LUA_MODIFIER_MOTION_NONE )

function ta_meld:IsStealable()
	return true
end

function ta_meld:IsHiddenWhenStolen()
	return false
end

function ta_meld:OnSpellStart()
	local caster = self:GetCaster()
	EmitSoundOn("Hero_TemplarAssassin.Meld", caster)

	caster:AddNewModifier(caster, self, "modifier_ta_meld", {Duration = self:GetSpecialValueFor("invis_duration")})
	caster:AddNewModifier(caster, self, "modifier_ta_meld_armor", {})
end

modifier_ta_meld_armor = ({})
function modifier_ta_meld_armor:OnCreated(table)
    if IsServer() then
    	self:GetParent():SetProjectileModel("particles/units/heroes/hero_templar_assassin/templar_assassin_meld_attack.vpcf")
    end
end

function modifier_ta_meld_armor:OnRemoved()
    if IsServer() then
    	self:GetParent():RevertProjectile()
    end
end

function modifier_ta_meld_armor:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_EVENT_ON_ATTACK_LANDED
    }
    return funcs
end

function modifier_ta_meld_armor:GetModifierPreAttack_BonusDamage()
	return self:GetTalentSpecialValueFor("bonus_damage")
end

function modifier_ta_meld_armor:OnAttackLanded(params)
	if IsServer() then
		if params.attacker == self:GetParent() then
			EmitSoundOn("Hero_TemplarAssassin.Meld.Attack", params.target)
			params.target:AddNewModifier(params.attacker, self:GetAbility(), "modifier_ta_meld_enemy", {Duration = self:GetTalentSpecialValueFor("reduc_duration")})
			if params.attacker:HasTalent("special_bonus_unique_ta_meld_2") then
				params.target:AddNewModifier(params.attacker, self:GetAbility(), "modifier_disarmed", {Duration = params.attacker:FindTalentValue("special_bonus_unique_ta_meld_2")})
			end
			self:Destroy()
		end
	end
end

function modifier_ta_meld_armor:GetEffectName()
	return "particles/units/heroes/hero_templar_assassin/templar_assassin_meld.vpcf"
end

modifier_ta_meld = ({})
function modifier_ta_meld:OnCreated(table)
	if IsServer() then
		self:GetParent():SetThreat(0)
		self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_invisible", {Duration = self:GetSpecialValueFor("invis_duration")})
	end
end

function modifier_ta_meld:OnRemoved()
	if IsServer() then
		EmitSoundOn("Hero_TemplarAssassin.Meld.Move", self:GetParent())
		self:GetParent():RemoveModifierByName("modifier_invisible")
	end
end
function modifier_ta_meld:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ORDER
    }
    return funcs
end

function modifier_ta_meld:OnOrder(params)
	if IsServer() then
		if params.unit == self:GetParent() then
			self:Destroy()
		end
	end
end

function modifier_ta_meld:IsHidden()
	return true
end

modifier_ta_meld_enemy = ({})
function modifier_ta_meld_enemy:OnCreated(table)
    if IsServer() then
    	self.nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_templar_assassin/templar_assassin_meld_armor.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster())
    	ParticleManager:SetParticleControlEnt(self.nfx, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
    end
end

function modifier_ta_meld_enemy:OnRemoved()
    if IsServer() then
    	ParticleManager:ClearParticle(self.nfx)
    end
end

function modifier_ta_meld_enemy:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
    }
    return funcs
end

function modifier_ta_meld_enemy:GetModifierPhysicalArmorBonus()
	return self:GetTalentSpecialValueFor("armor_reduc")
end

function modifier_ta_meld_enemy:GetEffectName()
	return "particles/units/heroes/hero_templar_assassin/templar_meld_overhead.vpcf"
end

function modifier_ta_meld_enemy:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end