phoenix_blaze_geyser = class({})

function phoenix_blaze_geyser:GetAbilityTextureName()
	if self:GetCaster():HasModifier("modifier_phoenix_kindled_soul_active") then
		return "custom/phoenix_blaze_geyser_kindled"
	else
		return "custom/phoenix_blaze_geyser"
	end
end

function phoenix_blaze_geyser:OnSpellStart()
	local dummy = CreateModifierThinker( self:GetCaster(), self, "modifier_phoenix_blaze_geyser_thinker", {duration = self:GetTalentSpecialValueFor("geyser_duration"), kindled = tostring(self:GetCaster():HasModifier("modifier_phoenix_kindled_soul_active"))}, self:GetCursorPosition(), self:GetCaster():GetTeamNumber(), false )
end

function phoenix_blaze_geyser:OnProjectileHit(target, position)
	self:DealDamage(self:GetCaster(), target, self:GetTalentSpecialValueFor("geyser_damage") + (self:GetCaster().selfImmolationDamageBonus or 0))
	if self:GetCaster():HasTalent("phoenix_blaze_geyser_talent_1") then
		local duration = self:GetCaster():FindSpecificTalentValue("phoenix_blaze_geyser_talent_1", "duration")
		target:AddNewModifier(self:GetCaster(), self, "modifier_phoenix_blaze_geyser_burn", {duration = duration})
	end
	EmitSoundOn("Hero_Jakiro.LiquidFire", target)
end

modifier_phoenix_blaze_geyser_thinker = class({})
LinkLuaModifier( "modifier_phoenix_blaze_geyser_thinker", "heroes/phoenix/phoenix_blaze_geyser.lua", LUA_MODIFIER_MOTION_NONE )

if IsServer() then
	function modifier_phoenix_blaze_geyser_thinker:OnCreated(kv)
		self.kindled = toboolean(kv.kindled)
		self.damage = self:GetAbility():GetTalentSpecialValueFor("geyser_damage") + (self:GetCaster().selfImmolationDamageBonus or 0)
		self.radius = self:GetAbility():GetTalentSpecialValueFor("geyser_attack_range")
		
		self:StartIntervalThink(self:GetAbility():GetTalentSpecialValueFor("geyser_attack_rate"))
	
		self.nFXIndex = ParticleManager:CreateParticle( "particles/heroes/phoenix/phoenix_blaze_geyser.vpcf", PATTACH_WORLDORIGIN, nil )
		ParticleManager:SetParticleControl( self.nFXIndex, 0, self:GetParent():GetOrigin() )
	end
	
	function modifier_phoenix_blaze_geyser_thinker:OnDestroy()
		ParticleManager:DestroyParticle(self.nFXIndex, false)
		ParticleManager:ReleaseParticleIndex(self.nFXIndex)
		UTIL_Remove( self:GetParent() )
	end
	
	function modifier_phoenix_blaze_geyser_thinker:OnIntervalThink()
		local enemies = self:GetCaster():FindEnemyUnitsInRadius(self:GetParent():GetAbsOrigin(), self.radius, {})
		for _, enemy in pairs(enemies) do
			local projectile = {
				Target = enemy,
				Source = self:GetParent(),
				Ability = self:GetAbility(),
				EffectName = "particles/units/heroes/hero_jakiro/jakiro_base_attack_fire.vpcf",
				bDodgable = true,
				bProvidesVision = false,
				iMoveSpeed = 900,
				iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
			}
			
			ProjectileManager:CreateTrackingProjectile(projectile)
			if not self.kindled then
				break
			end
		end
		if #enemies > 0 then EmitSoundOn("hero_jakiro.attack", self:GetParent()) end
	end
end

LinkLuaModifier( "modifier_phoenix_blaze_geyser_burn", "heroes/phoenix/phoenix_blaze_geyser.lua", LUA_MODIFIER_MOTION_NONE )
modifier_phoenix_blaze_geyser_burn = class({})

function modifier_phoenix_blaze_geyser_burn:OnCreated()
	self.damage_over_time = self:GetCaster():FindTalentValue("modifier_phoenix_blaze_geyser_burn")
	self.tick_interval = 1
	if self:GetCaster():HasScepter() then self.damage_over_time = self.damage_over_time * 2 end
	if IsServer() then self:StartIntervalThink(self.tick_interval) end
end

function modifier_phoenix_blaze_geyser_burn:OnRefresh()
	self.damage_over_time = self:GetAbility():GetTalentSpecialValueFor("damage_over_time")
	if self:GetCaster():HasScepter() then self.damage_over_time = self.damage_over_time * 2 end
end

function modifier_phoenix_blaze_geyser_burn:OnIntervalThink()
	ApplyDamage( {victim = self:GetParent(), attacker = self:GetCaster(), damage = self.damage_over_time, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility()} )
end

--------------------------------------------------------------------------------

function modifier_phoenix_blaze_geyser_burn:IsDebuff()
	return true
end

--------------------------------------------------------------------------------

function modifier_phoenix_blaze_geyser_burn:GetEffectName()
	return "particles/units/heroes/hero_jakiro/jakiro_liquid_fire_debuff.vpcf"
end


function modifier_phoenix_blaze_geyser_burn:IsFireDebuff()
	return true
end