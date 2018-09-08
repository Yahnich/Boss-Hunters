green_dragon_toxic_pool = class({})
LinkLuaModifier( "modifier_green_dragon_toxic_pool", "bosses/boss_green_dragon/green_dragon_toxic_pool", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_green_dragon_toxic_pool_handle", "bosses/boss_green_dragon/green_dragon_toxic_pool", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_green_dragon_toxic_pool_debuff", "bosses/boss_green_dragon/green_dragon_toxic_pool", LUA_MODIFIER_MOTION_NONE )

function green_dragon_toxic_pool:OnAbilityPhaseStart()
	ParticleManager:FireLinearWarningParticle(self:GetCaster():GetAbsOrigin(), self:GetCaster():GetAbsOrigin() + CalculateDirection( self:GetCursorPosition(), self:GetCaster():GetAbsOrigin() ) * self:GetTrueCastRange(), self:GetSpecialValueFor("width"))
	return true
end

function green_dragon_toxic_pool:GetChannelTime()
	return self:GetSpecialValueFor("channel_duration")
end

function green_dragon_toxic_pool:GetChannelAnimation()
	return ACT_DOTA_CAST_ABILITY_1
end

function green_dragon_toxic_pool:OnChannelFinish(bInterrupted)
	if bInterrupted then
		self:RefundManaCost()
		self:EndCooldown()
	end
end

function green_dragon_toxic_pool:OnSpellStart()	
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_green_dragon_toxic_pool_handle", {Duration = self:GetSpecialValueFor("channel_duration")})
end

function green_dragon_toxic_pool:OnProjectileHit( hTarget, vLocation )
	if hTarget ~= nil and ( not hTarget:IsMagicImmune() ) and ( not hTarget:IsInvulnerable() ) then
		local caster = self:GetCaster()
		hTarget:AddNewModifier(self:GetCaster(), self, "modifier_green_dragon_toxic_pool_debuff", {Duration = self:GetSpecialValueFor("debuff_duration")})
		EmitSoundOn( "Hero_Venomancer.VenomousGaleImpact", hTarget )
		
		local vDirection = CalculateDirection(vLocation, self:GetCaster():GetOrigin())
		
		local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_venomancer/venomancer_venomous_gale_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, hTarget )
		ParticleManager:SetParticleControlForward( nFXIndex, 1, vDirection )
		ParticleManager:ReleaseParticleIndex( nFXIndex )
	else
		if RollPercentage(25) then
			EmitSoundOnLocationWithCaster(vLocation, "soundName", hCaster)
			CreateModifierThinker(self:GetCaster(), self, "modifier_green_dragon_toxic_pool", {Duration = self:GetSpecialValueFor("pool_duration")}, vLocation, self:GetCaster():GetTeam(), false)
		end
	end
	return false
end

modifier_green_dragon_toxic_pool_handle = class({})
function modifier_green_dragon_toxic_pool_handle:OnCreated(table)
	if IsServer() then self:StartIntervalThink(0.1) end
end

function modifier_green_dragon_toxic_pool_handle:OnIntervalThink()
	local caster = self:GetCaster()
	EmitSoundOn("Hero_Viper.Nethertoxin.Cast", caster)
	caster:StartGesture(ACT_DOTA_CAST_ABILITY_1)
	local fDir = caster:GetForwardVector()
	local rndAng = math.rad( RandomInt( -self:GetTalentSpecialValueFor("spread"), self:GetTalentSpecialValueFor("spread") ) )
	local dirX = fDir.x * math.cos(rndAng) - fDir.y * math.sin(rndAng); 
	local dirY = fDir.x * math.sin(rndAng) + fDir.y * math.cos(rndAng);
	local direction = Vector( dirX, dirY, 0 )

	self:GetAbility():FireLinearProjectile("particles/units/heroes/hero_venomancer/venomancer_venomous_gale.vpcf", direction*self:GetSpecialValueFor("speed"), math.random(250, self:GetAbility():GetTrueCastRange()), self:GetTalentSpecialValueFor("width"), {}, false, true, 300)
end

modifier_green_dragon_toxic_pool = class({})
function modifier_green_dragon_toxic_pool:OnCreated(table)
	if IsServer() then
		local caster = self:GetCaster()
		local parent = self:GetParent()
		local radius = self:GetSpecialValueFor("radius")

		EmitSoundOn("Hero_Viper.NetherToxin", parent)
		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_viper/viper_nethertoxin.vpcf", PATTACH_POINT, caster)
					ParticleManager:SetParticleControl(nfx, 0, parent:GetAbsOrigin())
					ParticleManager:SetParticleControl(nfx, 1, Vector(radius,radius,radius))
					ParticleManager:SetParticleControl(nfx, 3, parent:GetAbsOrigin())
		self:AttachEffect(nfx)
	end
end

function modifier_green_dragon_toxic_pool:OnRemoved()
    if IsServer() then
    	StopSoundOn("Hero_Viper.NetherToxin", self:GetParent())
    end
end

function modifier_green_dragon_toxic_pool:IsAura()
    return true
end

function modifier_green_dragon_toxic_pool:GetAuraDuration()
    return self:GetSpecialValueFor("debuff_duration")
end

function modifier_green_dragon_toxic_pool:GetAuraRadius()
    return self:GetSpecialValueFor("radius")
end

function modifier_green_dragon_toxic_pool:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_green_dragon_toxic_pool:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_green_dragon_toxic_pool:GetAuraSearchType()
    return DOTA_UNIT_TARGET_ALL
end

function modifier_green_dragon_toxic_pool:GetModifierAura()
    return "modifier_green_dragon_toxic_pool_debuff"
end

modifier_green_dragon_toxic_pool_debuff = class({})

function modifier_green_dragon_toxic_pool_debuff:OnCreated()
	if IsServer() then
		self:StartIntervalThink(self:GetSpecialValueFor("tick_rate"))
	end
end

function modifier_green_dragon_toxic_pool_debuff:OnIntervalThink()
	self:GetAbility():DealDamage(self:GetCaster(), self:GetParent(), self:GetSpecialValueFor("damage")*self:GetSpecialValueFor("tick_rate"), {}, OVERHEAD_ALERT_BONUS_POISON_DAMAGE)
end

function modifier_green_dragon_toxic_pool_debuff:GetEffectName()
	return "particles/units/heroes/hero_venomancer/venomancer_gale_poison_debuff.vpcf"
end

function modifier_green_dragon_toxic_pool_debuff:IsPurgable()
	return true
end

function modifier_green_dragon_toxic_pool_debuff:IsPurgeException()
	return true
end