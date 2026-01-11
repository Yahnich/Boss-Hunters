juggernaut_breathless_lunge = class({})

function juggernaut_breathless_lunge:GetCastPoint()
	return self:GetSpecialValueFor("AbilityCastPoint")
end

function juggernaut_breathless_lunge:GetCastRange()
	return self:GetSpecialValueFor("jump_distance")
end

function juggernaut_breathless_lunge:OnAbilityPhaseStart()
	local caster = self:GetCaster()
	EmitSoundOn("Hero_Juggernaut.PreAttack", caster)
	caster:StartGesture(ACT_DOTA_ATTACK_EVENT)
end

function juggernaut_breathless_lunge:OnAbilityPhaseInterrupted()
	local caster = self:GetCaster()
	caster:RemoveGesture(ACT_DOTA_ATTACK_EVENT)
end

function juggernaut_breathless_lunge:OnSpellStart()
	local caster = self:GetCaster()
	local position = self:GetCursorPosition()

	local speed = self:GetSpecialValueFor("jump_speed")
	local distance = CalculateDistance( caster, position )
	ProjectileManager:ProjectileDodge(caster)
	caster:AddNewModifier(caster, self, "modifier_juggernaut_breathless_lunge_dash", {duration = distance/speed})
end

modifier_juggernaut_breathless_lunge_dash = class({})
LinkLuaModifier("modifier_juggernaut_breathless_lunge_dash", "heroes/hero_juggernaut/juggernaut_breathless_lunge", LUA_MODIFIER_MOTION_NONE)

function modifier_juggernaut_breathless_lunge_dash:CheckState()
	return {[MODIFIER_STATE_STUNNED] = true,
			[MODIFIER_STATE_DISARMED] = true,
			[MODIFIER_STATE_NO_UNIT_COLLISION] = true}
end

function modifier_juggernaut_breathless_lunge_dash:IsHidden()
	return true
end

if IsServer() then
	function modifier_juggernaut_breathless_lunge_dash:OnCreated()
		local parent = self:GetParent()
		self.startPos = parent:GetAbsOrigin()
		self.endPos = self:GetAbility():GetCursorPosition()
		self.distance = CalculateDistance(parent, self.endPos)
		self.direction = CalculateDirection( self.endPos, parent )
		self.speed = self:GetSpecialValueFor("jump_speed") * FrameTime()
		self.enemies_hit = {}
		self:StartMotionController()
	end

	function modifier_juggernaut_breathless_lunge_dash:OnDestroy()
		local parent = self:GetParent()
		local parentPos = parent:GetAbsOrigin()
		parent:SmoothFindClearSpace(self.endPos)
		parent:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_juggernaut_breathless_lunge_buff", {duration = self:GetSpecialValueFor("buff_duration")})
		self:StopMotionController()
	end

	function modifier_juggernaut_breathless_lunge_dash:DoControlledMotion()
		if self:GetParent():IsNull() then return end
		local parent = self:GetParent()
		local caster = self:GetCaster()
		self.distanceTraveled =  self.distanceTraveled or 0
		if parent:IsAlive() and self.distanceTraveled < self.distance then
			local oldPos = parent:GetAbsOrigin()
			local newPos = GetGroundPosition(oldPos, parent) + self.direction * self.speed
			parent:SetAbsOrigin( newPos )
			self.distanceTraveled = self.distanceTraveled + self.speed
			local nfx = ParticleManager:CreateParticle("particles/econ/items/juggernaut/bladekeeper_omnislash/_dc_juggernaut_omni_slash_trail.vpcf", PATTACH_ABSORIGIN, parent)
						ParticleManager:SetParticleControl(nfx, 0, oldPos)
						ParticleManager:SetParticleControl(nfx, 1, newPos)
						ParticleManager:ReleaseParticleIndex(nfx)

			for _, enemies in ipairs(caster:FindEnemyUnitsInLine(oldPos, newPos, parent:GetAttackRange())) do
				if not self.enemies_hit[enemies:entindex()] then
					caster:PerformGenericAttack(enemies)

					if self:GetSpecialValueFor("bleed") ~= 0 then
						enemies:AddNewModifier(caster, self:GetAbility(), "modifier_juggernaut_breathless_lunge_bleed", {duration =  self:GetSpecialValueFor("bleed_duration")})
					end

					if self:GetSpecialValueFor("disarms") ~= 0 then
						enemies:Disarm(self:GetAbility(), caster, self:GetSpecialValueFor("disarm_duration"))
					end

					self.enemies_hit[enemies:entindex()] = true
					return
				end
			end
		else
			self:Destroy()
			return nil
		end
	end
end


modifier_juggernaut_breathless_lunge_buff = class({})
LinkLuaModifier("modifier_juggernaut_breathless_lunge_buff", "heroes/hero_juggernaut/juggernaut_breathless_lunge", LUA_MODIFIER_MOTION_NONE)

function modifier_juggernaut_breathless_lunge_buff:OnCreated()
	self:OnRefresh()
end

function modifier_juggernaut_breathless_lunge_buff:OnRefresh()
	self.aspd = self:GetSpecialValueFor("aspd")
end

function modifier_juggernaut_breathless_lunge_buff:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}
end

function modifier_juggernaut_breathless_lunge_buff:GetModifierAttackSpeedBonus_Constant()
	return self.aspd
end

modifier_juggernaut_breathless_lunge_bleed = class({})
LinkLuaModifier("modifier_juggernaut_breathless_lunge_bleed", "heroes/hero_juggernaut/juggernaut_breathless_lunge", LUA_MODIFIER_MOTION_NONE)

function modifier_juggernaut_breathless_lunge_bleed:IsDebuff()
	return true
end

function modifier_juggernaut_breathless_lunge_bleed:IsPurgable()
	return true
end

function modifier_juggernaut_breathless_lunge_bleed:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_juggernaut_breathless_lunge_bleed:OnCreated()
	self.bleed_dmg = self:GetSpecialValueFor("bleed") / 100
	self:StartIntervalThink(1)
end

function modifier_juggernaut_breathless_lunge_bleed:OnIntervalThink()
	if not IsServer() then return end
	local maxHP = self:GetParent():GetMaxHealth()
	local dmg = maxHP * self.bleed_dmg

	ParticleManager:FireParticle("particles/units/heroes/hero_ringmaster/ringmaster_dagger_target_bleed_splurt.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	self:GetAbility():DealDamage(self:GetCaster(), self:GetParent(), dmg, {damageType = DAMAGE_TYPE_PHYSICAL})
end