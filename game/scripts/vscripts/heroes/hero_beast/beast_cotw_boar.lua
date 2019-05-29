beast_cotw_boar = class({})

function beast_cotw_boar:IsStealable()
	return true
end

function beast_cotw_boar:IsHiddenWhenStolen()
	return false
end

function beast_cotw_boar:OnSpellStart()
	local caster = self:GetCaster()
	caster:AddNewModifier(caster, self, "modifier_cotw_boar_spirit", {})
	caster:RemoveModifierByName("modifier_cotw_hawk_spirit")
end

modifier_cotw_boar_spirit = class({})
LinkLuaModifier( "modifier_cotw_boar_spirit", "heroes/hero_beast/beast_cotw_boar.lua" ,LUA_MODIFIER_MOTION_NONE )
function modifier_cotw_boar_spirit:OnCreated(table)
	if IsServer() then
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		EmitSoundOn("Hero_Beastmaster.Call.Boar", caster)
		if ability.currentSpirit and not ability.currentSpirit:IsNull() then
			ability.currentSpirit:ForceKill(false)
			UTIL_Remove( ability.currentSpirit )
			ability.currentSpirit = nil
		end
		ability.currentSpirit = caster:CreateSummon( "npc_dota_beastmaster_boar_1", caster:GetAbsOrigin() )

		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_beastmaster/beastmaster_call_bird.vpcf", PATTACH_POINT, caster)
		ParticleManager:SetParticleControl(nfx, 0, ability.currentSpirit:GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex(nfx)

		ability.currentSpirit:AddNewModifier(caster, ability, "modifier_cotw_boar_spirit_boar", {})
		
		local hp = ability:GetTalentSpecialValueFor("boar_health")
		local dmg = ability:GetTalentSpecialValueFor("boar_damage")
		local bat = ability:GetTalentSpecialValueFor("boar_bat")
		local ms = ability:GetTalentSpecialValueFor("boar_ms")
		
		ability.currentSpirit:SetCoreHealth(hp)
		ability.currentSpirit:SetAverageBaseDamage(dmg, 15)
		ability.currentSpirit:SetBaseAttackTime(bat)
		ability.currentSpirit:SetBaseMoveSpeed(ms)
		
		ability.currentSpirit:SetPhysicalArmorBaseValue( 6 + ability:GetLevel() )
		ability.currentSpirit:SetBaseMagicalResistanceValue( 33 )
		ability.currentSpirit:SetBaseHealthRegen( hp / 100 )
		
		self:StartIntervalThink( 1 )
		self:SetDuration( -1, true)
		
		self.respawnTime = ability:GetTalentSpecialValueFor("respawn_time")
	end
end

function modifier_cotw_boar_spirit:OnRefresh(table)
	self:OnCreated()
end

function modifier_cotw_boar_spirit:OnIntervalThink()
	local ability = self:GetAbility()
	if not ability.currentSpirit then
		self:OnCreated()
	end
	if ability.currentSpirit and ( ability.currentSpirit:IsNull() or not ability.currentSpirit:IsAlive() ) then
		ability.currentSpirit = nil
	end
	if not ability.currentSpirit then
		self:StartIntervalThink( self.respawnTime )
		self:SetDuration( self.respawnTime + 0.1, true)
	end
end

function modifier_cotw_boar_spirit:OnRemoved()
	if IsServer() then
		local ability = self:GetAbility()
		StopSoundOn("Hero_Beastmaster.Call.Boar", self:GetCaster())
		if ability.currentSpirit and not ability.currentSpirit:IsNull() then
			ability.currentSpirit:ForceKill(false)
			UTIL_Remove( ability.currentSpirit )
			ability.currentSpirit = nil
		end
	end
end

function modifier_cotw_boar_spirit:IsDebuff()
	return false
end


modifier_cotw_boar_spirit_boar = class({})
LinkLuaModifier( "modifier_cotw_boar_spirit_boar", "heroes/hero_beast/beast_cotw_boar.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_cotw_boar_spirit_boar:OnCreated()
	self.duration = self:GetTalentSpecialValueFor("debuff_duration")
	
	self.talent = self:GetCaster():HasTalent("special_bonus_unique_beast_cotw_boar_1")
	self.radius = self:GetCaster():FindTalentValue("special_bonus_unique_beast_cotw_boar_1", "radius")
	
	print( self.talent, self.radius )
end

function modifier_cotw_boar_spirit_boar:OnRefresh()
	self:OnCreated()
end

function modifier_cotw_boar_spirit_boar:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED }
end

function modifier_cotw_boar_spirit_boar:OnAttackLanded(params)
	if params.attacker == self:GetParent() and params.target.AddNewModifier then
		params.target:AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_cotw_boar_spirit_boar_slow", {duration = self.duration} )
	end
end

function modifier_cotw_boar_spirit_boar:IsAura()
	return self.talent
end

function modifier_cotw_boar_spirit_boar:GetAuraRadius()
	return self.radius
end

function modifier_cotw_boar_spirit_boar:GetModifierAura()
	return "modifier_cotw_boar_spirit_boar_aura"
end

function modifier_cotw_boar_spirit_boar:GetAuraDuration()
	return 0.5
end

function modifier_cotw_boar_spirit_boar:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_cotw_boar_spirit_boar:GetAuraSearchType()
	return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_cotw_boar_spirit_boar:IsHidden()
	return true
end

modifier_cotw_boar_spirit_boar_slow = class({})
LinkLuaModifier( "modifier_cotw_boar_spirit_boar_slow", "heroes/hero_beast/beast_cotw_boar.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_cotw_boar_spirit_boar_slow:OnCreated()
	self.as = self:GetTalentSpecialValueFor("as_slow")
	self.ms = self:GetTalentSpecialValueFor("ms_slow")
end

function modifier_cotw_boar_spirit_boar_slow:OnRefresh()
	self:OnCreated()
end

function modifier_cotw_boar_spirit_boar_slow:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_cotw_boar_spirit_boar_slow:GetModifierAttackSpeedBonus()
	return self.as
end

function modifier_cotw_boar_spirit_boar_slow:GetModifierMoveSpeedBonus_Percentage()
	return self.ms
end

function modifier_cotw_boar_spirit_boar_slow:GetEffectName()
	return "particles/items2_fx/orb_of_venom.vpcf"
end

modifier_cotw_boar_spirit_boar_aura = class({})
LinkLuaModifier( "modifier_cotw_boar_spirit_boar_aura", "heroes/hero_beast/beast_cotw_boar.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_cotw_boar_spirit_boar_aura:OnCreated()
	self.regen = self:GetCaster():FindTalentValue("special_bonus_unique_beast_cotw_boar_1")
end

function modifier_cotw_boar_spirit_boar_aura:OnRefresh()
	self:OnCreated()
end

function modifier_cotw_boar_spirit_boar_aura:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE }
end

function modifier_cotw_boar_spirit_boar_aura:GetModifierHealthRegenPercentage()
	return self.regen
end