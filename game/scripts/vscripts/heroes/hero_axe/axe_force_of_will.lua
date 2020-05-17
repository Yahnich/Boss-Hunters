axe_force_of_will = class({})

function axe_force_of_will:GetIntrinsicModifierName()
	return "modifier_axe_force_of_will"
end

modifier_axe_force_of_will = class({})
LinkLuaModifier("modifier_axe_force_of_will", "heroes/hero_axe/axe_force_of_will", LUA_MODIFIER_MOTION_NONE)

function modifier_axe_force_of_will:OnCreated()
	self.lifesteal = self:GetTalentSpecialValueFor("lifesteal") / 100
	self.mLifesteal = self:GetTalentSpecialValueFor("minion_lifesteal") / 100
	self.bChance = self:GetTalentSpecialValueFor("scepter_bash_chance")
	self.bDur = self:GetTalentSpecialValueFor("scepter_bash_duration")
end

function modifier_axe_force_of_will:DeclareFunctions()
	return {MODIFIER_EVENT_ON_TAKEDAMAGE, MODIFIER_EVENT_ON_ATTACK_LANDED }
end

function modifier_axe_force_of_will:OnTakeDamage(params)
	local parent = self:GetParent()
	if params.unit:IsTauntedBy( parent ) and params.unit ~= parent and parent:GetHealth() > 0 
	and not ( HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) or HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) or HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL) ) then
		local lifesteal = self.lifesteal
		if params.inflictor then 
			ParticleManager:FireParticle("particles/items3_fx/octarine_core_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, self)
			if params.unit:IsMinion() then
				lifesteal = self.mLifesteal
			end
		end
		local flHeal = params.damage * lifesteal
		parent:HealEvent(flHeal, self:GetAbility(), parent)
	end
end

function modifier_axe_force_of_will:OnAttackLanded(params)
	local parent = self:GetParent()
	if not parent:HasScepter() then return end
	local ability = self:GetAbility()
	if params.attacker == parent and self:RollPRNG( self.bChance ) and params.attacker:IsRealHero() then
		ability:Stun(params.target, self.bDur, true)
		EmitSoundOn("DOTA_Item.SkullBasher", params.target)
	end
end

function modifier_axe_force_of_will:IsHidden()
	return true
end