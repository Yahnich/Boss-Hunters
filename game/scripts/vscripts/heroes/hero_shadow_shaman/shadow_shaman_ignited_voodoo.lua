shadow_shaman_ignited_voodoo = class({})

function shadow_shaman_ignited_voodoo:OnSpellStart()
	local hTarget = self:GetCursorTarget()
	local hCaster = self:GetCaster()
	
	-- cosmetic
	hTarget:EmitSound("Hero_ShadowShaman.Hex.Target")
	local voodooPoof = ParticleManager:CreateParticle("particles/units/heroes/hero_shadowshaman/shadowshaman_voodoo.vpcf", PATTACH_POINT_FOLLOW, hTarget)
	ParticleManager:ReleaseParticleIndex(voodooPoof)
	
	if hTarget:IsIllusion() then
		hTarget:ForceKill(true)
	else
		hTarget:AddNewModifier(hCaster, self, "modifier_shadow_shaman_ignited_voodoo", {duration = self:GetSpecialValueFor("duration")})
	end
end

LinkLuaModifier("modifier_shadow_shaman_ignited_voodoo", "heroes/hero_shadow_shaman/shadow_shaman_ignited_voodoo", LUA_MODIFIER_MOTION_NONE)
modifier_shadow_shaman_ignited_voodoo = class({})

function modifier_shadow_shaman_ignited_voodoo:OnCreated()
	self.ms = self:GetTalentSpecialValueFor("movespeed")
	if IsServer() then
		self:GetAbility():StartDelayedCooldown()
	end
end

function modifier_shadow_shaman_ignited_voodoo:OnRefresh()
	self.ms = self:GetTalentSpecialValueFor("movespeed")
	if IsServer() then
		self:GetAbility():StartDelayedCooldown()
	end
end

function modifier_shadow_shaman_ignited_voodoo:OnDestroy()
	if IsServer() then
		self:GetAbility():EndDelayedCooldown()
		local caster = self:GetCaster()
		local parent = self:GetParent()
		local parentPos = parent:GetAbsOrigin()
		local radius = self:GetAbility():GetSpecialValueFor("radius")
		local damage = self:GetAbility():GetSpecialValueFor("damage")
		local tDuration = caster:FindTalentValue("special_bonus_unique_shadow_shaman_ignited_voodoo_1", "duration")
		EmitSoundOn("Hero_Techies.Suicide", parent)
		local voodooBoom = ParticleManager:CreateParticle("particles/units/heroes/hero_techies/techies_suicide.vpcf", PATTACH_ABSORIGIN, parent)
		ParticleManager:SetParticleControl(voodooBoom,0,parentPos)
		ParticleManager:SetParticleControl(voodooBoom,1,Vector(radius/2,0,0 ))
		ParticleManager:SetParticleControl(voodooBoom,2,Vector(radius,radius,radius ))
		ParticleManager:ReleaseParticleIndex(voodooBoom)
		for _, enemy in ipairs( caster:FindEnemyUnitsInRadius(parentPos, radius) ) do
			self:GetAbility():DealDamage(caster, enemy, damage)
			if caster:HasTalent("special_bonus_unique_shadow_shaman_ignited_voodoo_1") then
				enemy:AddNewModifier(caster, self:GetAbility(), "modifier_shadow_shaman_ignited_voodoo_dot", {duration = tDuration})
			end
		end
	end
end

function modifier_shadow_shaman_ignited_voodoo:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MODEL_CHANGE,
		MODIFIER_PROPERTY_MODEL_SCALE,
		MODIFIER_PROPERTY_MOVESPEED_BASE_OVERRIDE
	}

	return funcs
end

function modifier_shadow_shaman_ignited_voodoo:GetModifierModelChange()
	return "models/props_gameplay/chicken.vmdl"
end

function modifier_shadow_shaman_ignited_voodoo:GetModifierModelScale()
	return -50
end

function modifier_shadow_shaman_ignited_voodoo:GetModifierMoveSpeedOverride()
	return self.ms
end

function modifier_shadow_shaman_ignited_voodoo:CheckState()
	local state = {
	[MODIFIER_STATE_DISARMED] = true,
	[MODIFIER_STATE_HEXED] = true,
	[MODIFIER_STATE_MUTED] = true,
	[MODIFIER_STATE_SILENCED] = true
	}

	return state
end


LinkLuaModifier("modifier_shadow_shaman_ignited_voodoo_dot", "heroes/hero_shadow_shaman/shadow_shaman_ignited_voodoo", LUA_MODIFIER_MOTION_NONE)
modifier_shadow_shaman_ignited_voodoo_dot = class({})

if IsServer() then
	function modifier_shadow_shaman_ignited_voodoo_dot:OnCreated()
		self.damage = self:GetTalentSpecialValueFor("damage") * self:GetCaster():FindTalentValue("special_bonus_unique_shadow_shaman_ignited_voodoo_1") / 100
		self:StartIntervalThink(1)
	end

	function modifier_shadow_shaman_ignited_voodoo_dot:OnRefresh()
		self.damage = self:GetTalentSpecialValueFor("damage") * self:GetCaster():FindTalentValue("special_bonus_unique_shadow_shaman_ignited_voodoo_1") / 100
	end

	function modifier_shadow_shaman_ignited_voodoo_dot:OnIntervalThink()
		self:GetAbility():DealDamage( self:GetCaster(), self:GetParent(), self.damage)
	end
end

function modifier_shadow_shaman_ignited_voodoo_dot:GetEffectName()
	return ""
end