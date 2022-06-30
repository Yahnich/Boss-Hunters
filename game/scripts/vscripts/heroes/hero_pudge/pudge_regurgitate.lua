pudge_regurgitate = class({})

function pudge_regurgitate:IsStealable()
	return true
end

function pudge_regurgitate:IsHiddenWhenStolen()
	return false
end

function pudge_regurgitate:OnSpellStart()
	local caster = self:GetCaster()
	
	EmitSoundOn("Hero_Pudge.Eject", caster)
	caster:AddNewModifier(caster, self, "modifier_pudge_regurgitate", {Duration = 1})
	
	self:DealDamage( caster, caster, caster:GetHealth( ) * self:GetTalentSpecialValueFor("health_cost") / 100, {damage_type = DAMAGE_TYPE_PURE, damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_NON_LETHAL + DOTA_DAMAGE_FLAG_HPLOSS + DOTA_DAMAGE_FLAG_BYPASSES_INVULNERABILITY} )
end

modifier_pudge_regurgitate = class({})
LinkLuaModifier("modifier_pudge_regurgitate", "heroes/hero_pudge/pudge_regurgitate", LUA_MODIFIER_MOTION_NONE)

function modifier_pudge_regurgitate:OnCreated(table)
	self.duration = self:GetTalentSpecialValueFor("duration")
	if IsServer() then
		local caster = self:GetParent()

		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_pudge/pudge_regurgitate_breath.vpcf", PATTACH_POINT_FOLLOW, caster)
					ParticleManager:SetParticleControlEnt(nfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_eye_l", caster:GetAbsOrigin(), true)
					ParticleManager:SetParticleControlEnt(nfx, 3, caster, PATTACH_POINT_FOLLOW, "attach_eye_l", caster:GetAbsOrigin(), true)
		self:AttachEffect(nfx)
		
		local nfx2 = ParticleManager:CreateParticle("particles/units/heroes/hero_pudge/pudge_regurgitate_breath.vpcf", PATTACH_POINT_FOLLOW, caster)
					ParticleManager:SetParticleControlEnt(nfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_eye_r", caster:GetAbsOrigin(), true)
					ParticleManager:SetParticleControlEnt(nfx, 3, caster, PATTACH_POINT_FOLLOW, "attach_eye_r", caster:GetAbsOrigin(), true)
		self:AttachEffect(nfx2)
		
		self:OnIntervalThink( )
		self:StartIntervalThink( 0.2 )
	end
end

function modifier_pudge_regurgitate:OnIntervalThink()
	if IsServer() then
		local caster = self:GetParent()
		local ability = self:GetAbility()
		local vDir = caster:GetForwardVector()
		local vPos = caster:GetAbsOrigin()
		local length = ability:GetTrueCastRange()
		local radius = 300

		local enemies = caster:FindEnemyUnitsInCone(vDir, vPos, radius, length, {})
		for _,enemy in pairs(enemies) do
			local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_pudge/pudge_regurgitate_hit_c_2.vpcf", PATTACH_POINT_FOLLOW, caster)
						ParticleManager:SetParticleControlEnt(nfx, 0, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true)
						ParticleManager:SetParticleControlEnt(nfx, 3, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true)
						ParticleManager:ReleaseParticleIndex(nfx)
			enemy:AddNewModifier( caster, ability, "modifier_pudge_regurgitate_debuff", {duration = self.duration})
		end
	end
end

function modifier_pudge_regurgitate:OnDestroy()
	if IsServer() then
		EmitSoundOn("Hero_Pudge.Swallow", self:GetParent())
	end
end

function modifier_pudge_regurgitate:IsHidden()
	return true
end


modifier_pudge_regurgitate_debuff = class({})
LinkLuaModifier("modifier_pudge_regurgitate_debuff", "heroes/hero_pudge/pudge_regurgitate", LUA_MODIFIER_MOTION_NONE)

function modifier_pudge_regurgitate_debuff:OnCreated()
	self:OnRefresh()
	
	if IsServer() and self:GetCaster():HasTalent("special_bonus_unique_pudge_regurgitate_1") then
		self.talent1Dmg = self:GetCaster():FindTalentValue("special_bonus_unique_pudge_regurgitate_1") / 100
		self:StartIntervalThink(1)
	end
end

function modifier_pudge_regurgitate_debuff:OnRefresh()
	self.armor = self:GetTalentSpecialValueFor("armor_reduction")
	self.lifesteal = self:GetTalentSpecialValueFor("lifesteal")
	self.mr = self:GetTalentSpecialValueFor("mr_reduction")
	
	self:GetParent():HookInModifier( "GetModifierLifestealTargetBonus", self )
end

function modifier_pudge_regurgitate_debuff:OnDestroy()
	self:GetParent():HookOutModifier( "GetModifierLifestealTargetBonus", self )
end

function modifier_pudge_regurgitate_debuff:OnIntervalThink()
	local caster = self:GetCaster()
	local parent = self:GetParent()
	local ability = self:GetAbility()
	
	ability:DealDamage( caster, parent, caster:GetStrength() * self.talent1Dmg )
end

function modifier_pudge_regurgitate_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
			MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS }
end

function modifier_pudge_regurgitate_debuff:GetModifierPhysicalArmorBonus()
	return self.armor
end

function modifier_pudge_regurgitate_debuff:GetModifierLifestealTargetBonus( params )
	if params.attacker == self:GetCaster() and params.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK then
		return self.lifesteal
	end
end

function modifier_pudge_regurgitate_debuff:GetModifierMagicalResistanceBonus()
	return self.mr
end

function modifier_pudge_regurgitate_debuff:GetEffectName()
	return "particles/units/heroes/hero_pudge/pudge_regurgitate_debuff.vpcf"
end