hoodwink_bushwhack_bh = class({})

function hoodwink_bushwhack_bh:GetAOERadius()
	return self:GetTalentSpecialValueFor("trap_radius")
end

function hoodwink_bushwhack_bh:OnSpellStart()
	local caster = self:GetCaster()
	local position = self:GetCursorPosition()
	
	local direction = CalculateDirection( position, caster )
	local distance = CalculateDistance( position, caster )
	
	local speed = self:GetTalentSpecialValueFor("projectile_speed")
	
	local dummy = caster:CreateDummy( position, distance / speed + 0.1 )
	self:FireTrackingProjectile("particles/units/heroes/hero_hoodwink/hoodwink_bushwhack_projectile.vpcf", dummy, speed, {}, DOTA_PROJECTILE_ATTACHMENT_ATTACK_1, false, true, 200)
	
	EmitSoundOn( "Hero_Hoodwink.Bushwhack.Cast", caster )
end

function hoodwink_bushwhack_bh:OnProjectileHit( target, position )
	local caster = self:GetCaster()
	if target then
		local radius = self:GetTalentSpecialValueFor("trap_radius")
		local damage = self:GetTalentSpecialValueFor("total_damage")
		local duration = self:GetTalentSpecialValueFor("debuff_duration")
		
		local nearestTrees = GridNav:GetAllTreesAroundPoint( position, radius, true )
		local enemies = caster:FindEnemyUnitsInRadius( position, radius )
		
		local talent1 = caster:HasTalent("special_bonus_unique_hoodwink_bushwhack_1")
		local talent1Duration = caster:FindTalentValue("special_bonus_unique_hoodwink_bushwhack_1", "value2") / 100
		local talent2 = caster:HasTalent("special_bonus_unique_hoodwink_bushwhack_1")
		local talent2Duration = caster:FindTalentValue("special_bonus_unique_hoodwink_bushwhack_2s", "duration")
		if #enemies > 0 then
			local treeFound = false
			local dragPos = position
			local checkDist = radius
			for _, tree in ipairs( nearestTrees ) do
				local treeDist = CalculateDistance( tree, position )
				if treeDist < checkDist then
					dragPos = tree:GetAbsOrigin()
					checkDist = treeDist
					treeFound = true
				end
			end
			if not treeFound and talent1 then
				for _, enemy in ipairs( enemies ) do
					local treeDist = CalculateDistance( enemy, position )
					if treeDist < checkDist then
						dragPos = enemy:GetAbsOrigin()
						checkDist = treeDist
						treeFound = true
					end
				end
			end
			if treeFound then
				for _, enemy in ipairs( enemies ) do
					self:DealDamage( caster, enemy, damage )
					enemy:ApplyKnockBack(dragPos, 0.5, 0.5, math.min( 0, -(CalculateDistance( enemy, dragPos) - 128) ), 0, caster, self, false)
					local stunDur = duration
					if talent1 and enemy:IsMinion() then
						stunDur = stunDur + stunDur * talent1Duration
					end
					self:Stun( enemy, stunDur )
					enemy:AddNewModifier( caster, self, "modifier_hoodwink_bushwhack_handler", { duration = stunDur, dragPosX = dragPos.x, dragPosY = dragPos.y, dragPosZ = dragPos.z } )
					if talent2 then
						enemy:AddNewModifier( caster, self, "modifier_hoodwink_bushwhack_timberlands_curse", { duration = stunDur + talent2Duration } )
					end
				end
			end
			ParticleManager:FireParticle( "particles/units/heroes/hero_hoodwink/hoodwink_bushwhack.vpcf", PATTACH_ABSORIGIN, target, {[0] = position, [1] = Vector( radius,1,1 )} )
		else
			ParticleManager:FireParticle( "particles/units/heroes/hero_hoodwink/hoodwink_bushwhack_fail.vpcf", PATTACH_ABSORIGIN, target, {[0] = position, [1] = Vector( radius,1,1 )} )
		end
		EmitSoundOn( "Hero_Hoodwink.Bushwhack.Impact", caster )
	end
end

modifier_hoodwink_bushwhack_handler = class({})
LinkLuaModifier( "modifier_hoodwink_bushwhack_handler", "heroes/hero_hoodwink/hoodwink_bushwhack_bh", LUA_MODIFIER_MOTION_NONE )

function modifier_hoodwink_bushwhack_handler:OnCreated(kv)
	self:OnRefresh()
	if IsServer() then
		local FX = ParticleManager:CreateParticle( "particles/units/heroes/hero_hoodwink/hoodwink_bushwhack_target.vpcf", PATTACH_ABSORIGIN, self:GetParent() )
		ParticleManager:SetParticleControl( FX, 15, Vector( kv.dragPosX, kv.dragPosY, kv.dragPosZ ) )
		self:AddEffect( FX )
		EmitSoundOn( "Hero_Hoodwink.Bushwhack.Target", self:GetParent() )
	end
end

function modifier_hoodwink_bushwhack_handler:OnRefresh()
	local caster = self:GetCaster()
	self.height = self:GetTalentSpecialValueFor("visual_height")
	self.rate = self:GetTalentSpecialValueFor("visual_height")
end

function modifier_hoodwink_bushwhack_handler:DeclareFunctions()
	return {MODIFIER_PROPERTY_VISUAL_Z_DELTA, MODIFIER_PROPERTY_OVERRIDE_ANIMATION, MODIFIER_PROPERTY_OVERRIDE_ANIMATION_RATE }
end

function modifier_hoodwink_bushwhack_handler:GetVisualZDelta( params )
	return self.height
end

function modifier_hoodwink_bushwhack_handler:GetOverrideAnimationRate( params )
	return self.rate
end


function modifier_hoodwink_bushwhack_handler:IsHidden()
	return true
end

modifier_hoodwink_bushwhack_timberlands_curse = class({})
LinkLuaModifier( "modifier_hoodwink_bushwhack_timberlands_curse", "heroes/hero_hoodwink/hoodwink_bushwhack_bh", LUA_MODIFIER_MOTION_NONE )

function modifier_hoodwink_bushwhack_timberlands_curse:OnCreated()
	self.armor = self:GetCaster():FindTalentValue("special_bonus_unique_hoodwink_bushwhack_2")
	self.lifesteal = self:GetCaster():FindTalentValue("special_bonus_unique_hoodwink_bushwhack_2", "value2")
	self:GetParent():HookInModifier( "GetModifierLifestealTargetBonus", self)
end

function modifier_hoodwink_bushwhack_timberlands_curse:OnDestroy()
	self:GetParent():HookOutModifier( "GetModifierLifestealTargetBonus", self)
end

function modifier_hoodwink_bushwhack_timberlands_curse:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end

function modifier_hoodwink_bushwhack_timberlands_curse:GetModifierPhysicalArmorBonus( params )
	return self.armor
end

function modifier_hoodwink_bushwhack_timberlands_curse:GetModifierLifestealTargetBonus( params )
	if params.attacker == self:GetCaster() then
		return self.lifesteal
	end
end
