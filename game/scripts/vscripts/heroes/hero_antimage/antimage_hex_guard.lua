antimage_hex_guard = class ({})

function antimage_hex_guard:GetIntrinsicModifierName()
	return "modifier_antimage_hex_guard"
end

function antimage_hex_guard:GetBehavior()
	return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
end

function antimage_hex_guard:OnSpellStart()
	local caster = self:GetCaster()
	caster:AddNewModifier( caster, self, "modifier_antimage_hex_guard_talent", {duration = self:GetTalentSpecialValueFor("duration")})
	
	ParticleManager:FireParticle("particles/units/heroes/hero_antimage/antimage_spellshield.vpcf", PATTACH_POINT_FOLLOW, caster, {[0] = "attach_hitloc"})
	EmitSoundOn( "Hero_Antimage.Counterspell.Cast", caster )
end

modifier_antimage_hex_guard_talent = class({})
LinkLuaModifier( "modifier_antimage_hex_guard_talent", "heroes/hero_antimage/antimage_hex_guard", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
	function modifier_antimage_hex_guard_talent:OnCreated()
		self.talent1 = self:GetParent():HasTalent("special_bonus_unique_antimage_hex_guard_1") 
		self.talent1Val = self:GetParent():FindTalentValue("special_bonus_unique_antimage_hex_guard_1") 
		
		local fx = ParticleManager:CreateParticle( "particles/units/heroes/hero_antimage/antimage_counter.vpcf", PATTACH_POINT_FOLLOW, self:GetParent() )
		ParticleManager:SetParticleControlEnt(fx, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		ParticleManager:SetParticleControl( fx, 1, Vector(100,0,0) )
		self:AddEffect( fx )
	end
		
	function modifier_antimage_hex_guard_talent:OnDestroy()
		self:GetAbility():EndDelayedCooldown()
	end
end

function modifier_antimage_hex_guard_talent:DeclareFunctions()
	return {MODIFIER_PROPERTY_ABSORB_SPELL}
end

function modifier_antimage_hex_guard_talent:GetAbsorbSpell(params)
	local caster = params.ability:GetCaster()
	local parent = self:GetParent()
	if caster:GetTeam() ~= self:GetParent():GetTeam() then
		ParticleManager:FireParticle("particles/units/heroes/hero_antimage/antimage_spellshield.vpcf", PATTACH_POINT_FOLLOW, parent, {[0] = "attach_hitloc"})
		EmitSoundOn( "Hero_Antimage.Counterspell.Absorb", parent )
		
		parent:PerformAbilityAttack( caster, false, self:GetAbility() )
		ParticleManager:FireRopeParticle( "particles/units/heroes/hero_antimage/antimage_volatile_inscriptions.vpcf", PATTACH_POINT_FOLLOW, parent, caster )
		EmitSoundOn( "Hero_Antimage.Counterspell.Target", caster )
		
		if self.talent1 then
			for _, enemy in ipairs( parent:FindEnemyUnitsInRadius( parent:GetAbsOrigin(), self.talent1Val ) ) do
				if enemy ~= caster then
					ParticleManager:FireRopeParticle( "particles/units/heroes/hero_antimage/antimage_volatile_inscriptions.vpcf", PATTACH_POINT_FOLLOW, parent, enemy )
					parent:PerformAbilityAttack( enemy, false, self:GetAbility() )
					EmitSoundOn( "Hero_Antimage.Counterspell.Target", enemy )
				end
			end
		end
		
		self:Destroy()
		return 1
	end
end

modifier_antimage_hex_guard = class({})
LinkLuaModifier( "modifier_antimage_hex_guard", "heroes/hero_antimage/antimage_hex_guard", LUA_MODIFIER_MOTION_NONE)

function modifier_antimage_hex_guard:OnCreated()
	self:OnRefresh()
end

function modifier_antimage_hex_guard:OnRefresh()
	self.mr = self:GetTalentSpecialValueFor("magic_resistance")
	
	self.talent1 = self:GetParent():HasTalent("special_bonus_unique_antimage_hex_guard_1") 
	self.talent1Val = self:GetParent():FindTalentValue("special_bonus_unique_antimage_hex_guard_1") 
end

function modifier_antimage_hex_guard:DeclareFunctions()
	return {MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS, MODIFIER_EVENT_ON_TAKEDAMAGE}
end

function modifier_antimage_hex_guard:GetModifierMagicalResistanceBonus()
	return self.mr
end

function modifier_antimage_hex_guard:OnTakeDamage(params)
	local parent = self:GetParent()
	if params.unit == parent and params.damage_type == DAMAGE_TYPE_MAGICAL and self.talent1
	and not ( HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) or HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) ) then
		local damage = params.original_damage * self.mr / 100
		for _, enemy in ipairs( parent:FindEnemyUnitsInRadius( parent:GetAbsOrigin(), self.talent1Val ) ) do
			ParticleManager:FireRopeParticle( "particles/units/heroes/hero_antimage/antimage_volatile_inscriptions.vpcf", PATTACH_POINT_FOLLOW, parent, enemy )
			self:GetAbility():DealDamage( parent, enemy, damage, {damage_type = DAMAGE_TYPE_MAGICAL, damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_REFLECTION })
		end
	end
end

function modifier_antimage_hex_guard:IsHidden()
	return true
end