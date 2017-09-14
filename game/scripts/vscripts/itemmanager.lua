ItemManager = class({})

ItemTypes = {
["ITEM_TYPE_WEAPON"] = 1,
["ITEM_TYPE_ARMOR"] = 2,
["ITEM_TYPE_OFFHAND"] = 3,
["ITEM_TYPE_TRINKET"] = 4,
["ITEM_TYPE_RELIC"] = 5,
}

function ItemManager:constructor(owner, itemTable)
	self.owner = data.owner
	self.owner.ItemManagerEntity = self
	self.currentArmor = 0
	self.currentWeapon = 0
	self.currentOther = 0
	self.itemTable = itemTable
	self.armorTable = {}
	self.weaponTable = {}
	self.otherTable = {}
	
	for itemType, itemTable in pairs(itemTable) do -- stupid tonumber shit
		if itemType == "Armor" then
			for level, item in pairs(itemTable) do
				self.armorTable[tonumber(level)] == item
			end
		elseif itemType == "Weapon" then
			for level, item in pairs(itemTable) do
				self.weaponTable[tonumber(level)] == item
			end
		elseif itemType == "Other" then
			for level, item in pairs(itemTable) do
				self.otherTable[tonumber(level)] == item
			end
		end
	end
	
	self.trinketTable = {}
end

function ItemManager:GetOwner()
	return self.owner
end

function ItemManager:GetEquippedArmor()
	return self.equippedArmor
end

function ItemManager:GetArmorLevel()
	return self.currentArmor or 0
end

function ItemManager:UpgradeArmor()
	if self.currentArmor < #self.armorTable then
		if self:GetEquippedArmor() then
			self:GetOwner():RemoveItem(self.armorTable[self:GetEquippedArmor() )
		end
		self.currentArmor = self.currentArmor + 1
		self.equippedArmor = self:GetOwner():AddItemByName(self.armorTable[self.currentArmor])
	else
		return "Armor is maxed"
	end
end

function ItemManager:GetEquippedWeapon()
	return self.equippedWeapon
end

function ItemManager:GetWeaponLevel()
	return self.currentWeapon or 0
end

function ItemManager:UpgradeWeapon()
	if self.currentWeapon < #self.weaponTable then
		if self:GetEquippedWeapon() then
			self:GetOwner():RemoveItem(self.weaponTable[self:GetEquippedWeapon() )
		end
		self.currentWeapon = self.currentWeapon + 1
		self.equippedWeapon = self:GetOwner():AddItemByName(self.weaponTable[self.currentWeapon])
	else
		return "Weapon is maxed"
	end
end

function ItemManager:GetEquippedOther()
	return self.equippedOther
end

function ItemManager:GetOtherLevel()
	return self.currentOther or 0
end

function ItemManager:UpgradeOther()
	if self.currentOther < #self.otherTable then
		if self:GetEquippedOther() then
			self:GetOwner():RemoveItem(self.otherTable[self:GetEquippedOther() )
		end
		self.currentOther = self.currentOther + 1
		self.equippedArmor = self:GetOwner():AddItemByName(self.otherTable[self.currentOther])
	else
		return "Other is maxed"
	end
end

function ItemManager:Destroy()
	self.passive:Destroy()
	UTIL_Remove(self)
end