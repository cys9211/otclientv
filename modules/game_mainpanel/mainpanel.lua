local Icons = {}
Icons[PlayerStates.Poison] = {
    tooltip = tr('You are poisoned'),
    path = '/images/game/states/poisoned',
    id = 'condition_poisoned'
}
Icons[PlayerStates.Burn] = {
    tooltip = tr('You are burning'),
    path = '/images/game/states/burning',
    id = 'condition_burning'
}
Icons[PlayerStates.Energy] = {
    tooltip = tr('You are electrified'),
    path = '/images/game/states/electrified',
    id = 'condition_electrified'
}
Icons[PlayerStates.Drunk] = {
    tooltip = tr('You are drunk'),
    path = '/images/game/states/drunk',
    id = 'condition_drunk'
}
Icons[PlayerStates.ManaShield] = {
    tooltip = tr('You are protected by a magic shield'),
    path = '/images/game/states/magic_shield',
    id = 'condition_magic_shield'
}
Icons[PlayerStates.Paralyze] = {
    tooltip = tr('You are paralysed'),
    path = '/images/game/states/slowed',
    id = 'condition_slowed'
}
Icons[PlayerStates.Haste] = {
    tooltip = tr('You are hasted'),
    path = '/images/game/states/haste',
    id = 'condition_haste'
}
Icons[PlayerStates.Swords] = {
    tooltip = tr('You may not logout during a fight'),
    path = '/images/game/states/logout_block',
    id = 'condition_logout_block'
}
Icons[PlayerStates.Drowning] = {
    tooltip = tr('You are drowning'),
    path = '/images/game/states/drowning',
    id = 'condition_drowning'
}
Icons[PlayerStates.Freezing] = {
    tooltip = tr('You are freezing'),
    path = '/images/game/states/freezing',
    id = 'condition_freezing'
}
Icons[PlayerStates.Dazzled] = {
    tooltip = tr('You are dazzled'),
    path = '/images/game/states/dazzled',
    id = 'condition_dazzled'
}
Icons[PlayerStates.Cursed] = {
    tooltip = tr('You are cursed'),
    path = '/images/game/states/cursed',
    id = 'condition_cursed'
}
Icons[PlayerStates.PartyBuff] = {
    tooltip = tr('You are strengthened'),
    path = '/images/game/states/strengthened',
    id = 'condition_strengthened'
}
Icons[PlayerStates.PzBlock] = {
    tooltip = tr('You may not logout or enter a protection zone'),
    path = '/images/game/states/protection_zone_block',
    id = 'condition_protection_zone_block'
}
Icons[PlayerStates.Pz] = {
    tooltip = tr('You are within a protection zone'),
    path = '/images/game/states/protection_zone',
    id = 'condition_protection_zone'
}
Icons[PlayerStates.Bleeding] = {
    tooltip = tr('You are bleeding'),
    path = '/images/game/states/bleeding',
    id = 'condition_bleeding'
}
Icons[PlayerStates.Hungry] = {
    tooltip = tr('You are hungry'),
    path = '/images/game/states/hungry',
    id = 'condition_hungry'
}

function init()
    mapController:init()
    healthManaController:init()
    inventoryController:init()
    optionsController:init()
end

function terminate()
    mapController:terminate()
    inventoryController:terminate()
    healthManaController:terminate()
    optionsController:terminate()
end

local optionsAmount = 0
local specialsAmount = 0
function reloadMainPanelSizes()
    local main = modules.game_interface.getMainRightPanel()
    local rightPanel = modules.game_interface.getRightPanel()

    if not (main) or not (rightPanel) then
        return
    end

    local height = 4
    for _, panel in ipairs(main:getChildren()) do
        if panel.panelHeight ~= nil then
            if panel:isVisible() then
                panel:setHeight(panel.panelHeight)
                height = height + panel.panelHeight

                if panel:getId() == 'mainoptionspanel' and panel:isOn() then
                    local currentOptionsAmount = math.ceil(optionsAmount / 5)
                    local currentSpecialsAmount = math.ceil(specialsAmount / 2)
                    local buttonsHeight = (math.max(currentOptionsAmount, currentSpecialsAmount) * 28) + 3
                    panel.onPanel.options:setHeight(buttonsHeight)
                    panel.onPanel.specials:setHeight(buttonsHeight)
                    panel:setHeight(panel:getHeight() + buttonsHeight)
                    height = height + buttonsHeight
                end
            else
                panel:setHeight(0)
            end
        end
    end

    main:setHeight(height)
    rightPanel:fitAll()
end

-- @ Options
local optionsShrink = false
local function refreshOptionsSizes()
    if optionsShrink then
        optionsController.ui:setOn(false)
        optionsController.ui.onPanel:hide()
        optionsController.ui.offPanel:show()
    else
        optionsController.ui:setOn(true)
        optionsController.ui.onPanel:show()
        optionsController.ui.offPanel:hide()
    end
    reloadMainPanelSizes()
end

local function createButton(id, description, image, callback, special, front)
    local panel
    if special then
        panel = optionsController.ui.onPanel.specials
        specialsAmount = specialsAmount + 1
    else
        panel = optionsController.ui.onPanel.options
        optionsAmount = optionsAmount + 1
    end

    local button = panel:getChildById(id)
    if not button then
        button = g_ui.createWidget('MainToggleButton')
        if front then
            panel:insertChild(1, button)
        else
            panel:addChild(button)
        end
    end

    button:setId(id)
    button:setTooltip(description)
    button:setSize('20 20')
    button:setImageSource(image)
    button:setImageClip('0 0 20 20')
    button.onMouseRelease = function(widget, mousePos, mouseButton)
        if widget:containsPoint(mousePos) and mouseButton ~= MouseMidButton then
            callback()
            return true
        end
    end

    refreshOptionsSizes()
    return button
end

optionsController = Controller:new()
optionsController:setUI('mainoptionspanel', modules.game_interface.getMainRightPanel())

function optionsController:onInit()
end

function optionsController:onTerminate()
end

function optionsController:onGameStart()
    optionsShrink = g_settings.getBoolean('mainpanel_shrink_options')
    refreshOptionsSizes()
    modules.game_interface.setupOptionsMainButton()
    modules.client_options.setupOptionsMainButton()
end

function optionsController:onGameEnd()
end

function changeOptionsSize()
    optionsShrink = not optionsShrink
    g_settings.set('mainpanel_shrink_options', optionsShrink)
    refreshOptionsSizes()
end

function addToggleButton(id, description, image, callback, front)
    return createButton(id, description, image, callback, false, front)
end

function addSpecialToggleButton(id, description, image, callback, front)
    return createButton(id, description, image, callback, true, front)
end
-- @ End of Options

-- @ Health/Mana
local function healthManaEvent()
    local player = g_game.getLocalPlayer()
    if not player then
        return
    end

    healthManaController.ui.health.text:setText(player:getHealth())
    healthManaController.ui.health.current:setWidth(math.max(12, math.ceil(
        (healthManaController.ui.health.total:getWidth() * player:getHealth()) / player:getMaxHealth())))

    healthManaController.ui.mana.text:setText(player:getMana())
    healthManaController.ui.mana.current:setWidth(math.max(12, math.ceil(
        (healthManaController.ui.mana.total:getWidth() * player:getMana()) / player:getMaxMana())))
end

healthManaController = Controller:new()
healthManaController:setUI('mainhealthmanapanel', modules.game_interface.getMainRightPanel())

local healthManaControllerEvents = healthManaController:addEvent(LocalPlayer, {
    onHealthChange = healthManaEvent,
    onManaChange = healthManaEvent
})

function healthManaController:onInit()
end

function healthManaController:onTerminate()
end

function healthManaController:onGameStart()
    healthManaControllerEvents:connect()
    healthManaControllerEvents:execute('onHealthChange')
    healthManaControllerEvents:execute('onManaChange')
end

function healthManaController:onGameEnd()
    healthManaControllerEvents:disconnect()
end
-- @ End of Health/Mana

-- @ Inventory
local inventoryShrink = false
local function getInventoryUi()
    if inventoryShrink then
        return inventoryController.ui.offPanel
    end

    return inventoryController.ui.onPanel
end

local function walkEvent()
    if modules.client_options.getOption('autoChaseOverride') then
        if g_game.isAttacking() and g_game.getChaseMode() == ChaseOpponent then
            selectPosture('stand', true)
        end
    end
end

local function combatEvent()
    if g_game.getChaseMode() == ChaseOpponent then
        selectPosture('follow', true)
    else
        selectPosture('stand', true)
    end

    if g_game.getFightMode() == FightOffensive then
        selectCombat('attack', true)
    elseif g_game.getFightMode() == FightBalanced then
        selectCombat('balanced', true)
    elseif g_game.getFightMode() == FightDefensive then
        selectCombat('defense', true)
    end

    selectPvp(g_game.getPVPMode() == PVPRedFist, true)
end

local function inventoryEvent(player, slot, item, oldItem)
    if inventoryShrink then
        return
    end

    local ui = getInventoryUi()
    local slotPanel
    local toggler
    if slot == InventorySlotHead then
        slotPanel = ui.helmet
        toggler = slotPanel.helmet
    elseif slot == InventorySlotNeck then
        slotPanel = ui.amulet
        toggler = slotPanel.amulet
    elseif slot == InventorySlotBack then
        slotPanel = ui.backpack
        toggler = slotPanel.backpack
    elseif slot == InventorySlotBody then
        slotPanel = ui.armor
        toggler = slotPanel.armor
    elseif slot == InventorySlotRight then
        slotPanel = ui.shield
        toggler = slotPanel.shield
    elseif slot == InventorySlotLeft then
        slotPanel = ui.sword
        toggler = slotPanel.sword
    elseif slot == InventorySlotLeg then
        slotPanel = ui.legs
        toggler = slotPanel.legs
    elseif slot == InventorySlotFeet then
        slotPanel = ui.boots
        toggler = slotPanel.boots
    elseif slot == InventorySlotFinger then
        slotPanel = ui.ring
        toggler = slotPanel.ring
    elseif slot == InventorySlotAmmo then
        slotPanel = ui.tools
        toggler = slotPanel.tools
    end

    if not slotPanel then
        return
    end

    slotPanel.item:setItem(item)
    toggler:setEnabled(not item)
    slotPanel.item:setWidth(34)
    slotPanel.item:setHeight(34)
end

local function onSoulChange(localPlayer, soul)
    local ui = getInventoryUi()

    if not localPlayer then
        return
    end
    if not soul then
        return
    end

    ui.soulPanel.soul:setText(soul)

end

local function onFreeCapacityChange(player, freeCapacity)
    if not player then
        return
    end

    if not freeCapacity then
        return
    end
    if freeCapacity > 99 then
        freeCapacity = math.floor(freeCapacity * 10) / 10
    end
    if freeCapacity > 999 then
        freeCapacity = math.floor(freeCapacity)
    end
    if freeCapacity > 99999 then
        freeCapacity = math.min(9999, math.floor(freeCapacity / 1000)) .. "k"
    end
    local ui = getInventoryUi()
    ui.capacityPanel.capacity:setText(freeCapacity)

end
local function loadIcon(bitChanged)
    local icon = g_ui.createWidget('ConditionWidget', getInventoryUi().icons)
    icon:setId(Icons[bitChanged].id)
    icon:setImageSource(Icons[bitChanged].path)
    icon:setTooltip(Icons[bitChanged].tooltip)

    return icon
end

local function toggleIcon(bitChanged)
    local content = getInventoryUi().icons

    local icon = content:getChildById(Icons[bitChanged].id)

    if icon then
        icon:destroy()
    else
        icon = loadIcon(bitChanged)
        icon:setParent(content)
    end
end

local function onStatesChange(localPlayer, now, old)
    if now == old then
        return
    end

    local bitsChanged = bit.bxor(now, old)
    for i = 1, 32 do
        local pow = math.pow(2, i - 1)
        if pow > bitsChanged then
            break
        end
        local bitChanged = bit.band(bitsChanged, pow)
        if bitChanged ~= 0 then
            toggleIcon(bitChanged)
        end
    end
end
local function refreshInventory_panel()
    if inventoryShrink then
        return
    end

    local player = g_game.getLocalPlayer()
    for i = InventorySlotFirst, InventorySlotPurse do
        if g_game.isOnline() then
            inventoryEvent(player, i, player:getInventoryItem(i))
        else
            inventoryEvent(player, i, nil)
        end
    end
    if player and g_game.isOnline() then
        onSoulChange(player, player:getSoul())
        onFreeCapacityChange(player, player:getFreeCapacity())
        onStatesChange(player, player:getStates(), 0)

    end
end
local function refreshInventorySizes()
    if inventoryShrink then
        inventoryController.ui:setOn(false)
        inventoryController.ui.onPanel:hide()
        inventoryController.ui.offPanel:show()
    else
        inventoryController.ui:setOn(true)
        inventoryController.ui.onPanel:show()
        inventoryController.ui.offPanel:hide()
        refreshInventory_panel()
    end
    combatEvent()
    walkEvent()
    reloadMainPanelSizes()
end

inventoryController = Controller:new()
inventoryController:setUI('maininventorypanel', modules.game_interface.getMainRightPanel())

local inventoryControllerEvents = inventoryController:addEvent(LocalPlayer, {
    onWalk = walkEvent,
    onAutoWalk = walkEvent,
    onFightModeChange = combatEvent,
    onChaseModeChange = combatEvent,
    onSafeFightChange = combatEvent,
    onPVPModeChange = combatEvent,
    onInventoryChange = inventoryEvent,
    onSoulChange = onSoulChange,
    onFreeCapacityChange = onFreeCapacityChange,
    onStatesChange = onStatesChange
})

function inventoryController:onInit()
    refreshInventory_panel()

end

function inventoryController:onTerminate()
    --- important

end

function inventoryController:onGameStart()
    inventoryControllerEvents:connect()
    inventoryControllerEvents:execute('onWalk')
    inventoryControllerEvents:execute('onAutoWalk')
    inventoryControllerEvents:execute('onFightModeChange')
    inventoryControllerEvents:execute('onChaseModeChange')
    inventoryControllerEvents:execute('onSafeFightChange')
    inventoryControllerEvents:execute('onPVPModeChange')
    inventoryControllerEvents:execute('onInventoryChange')
    inventoryControllerEvents:execute('onSoulChange')
    inventoryControllerEvents:execute('onFreeCapacityChange')
    inventoryControllerEvents:execute('onStatesChange')
    inventoryShrink = g_settings.getBoolean('mainpanel_shrink_inventory')
    refreshInventorySizes()
    refreshInventory_panel()
end

function inventoryController:onGameEnd()
    inventoryControllerEvents:disconnect()

end

function selectPosture(key, ignoreUpdate)
    local ui = getInventoryUi()
    if key == 'stand' then
        ui.standPosture:setEnabled(false)
        ui.followPosture:setEnabled(true)
        if not ignoreUpdate then
            g_game.setChaseMode(DontChase)
        end
    elseif key == 'follow' then
        ui.standPosture:setEnabled(true)
        ui.followPosture:setEnabled(false)
        if not ignoreUpdate then
            g_game.setChaseMode(ChaseOpponent)
        end
    end
end

function selectCombat(combat, ignoreUpdate)
    local ui = getInventoryUi()
    if combat == 'attack' then
        ui.attack:setEnabled(false)
        ui.balanced:setEnabled(true)
        ui.defense:setEnabled(true)
        if not ignoreUpdate then
            g_game.setFightMode(FightOffensive)
        end
    elseif combat == 'balanced' then
        ui.attack:setEnabled(true)
        ui.balanced:setEnabled(false)
        ui.defense:setEnabled(true)
        if not ignoreUpdate then
            g_game.setFightMode(FightBalanced)
        end
    elseif combat == 'defense' then
        ui.attack:setEnabled(true)
        ui.balanced:setEnabled(true)
        ui.defense:setEnabled(false)
        if not ignoreUpdate then
            g_game.setFightMode(FightDefensive)
        end
    end
end

function selectPvp(pvp, ignoreUpdate)
    local ui = getInventoryUi()
    if pvp then
        ui.pvp:setImageClip(
            ui.pvp.imageClipCheckedX .. ' ' .. ui.pvp.imageClipCheckedY .. ' ' .. ui.pvp.imageClipWidth .. ' 20')
        if not ignoreUpdate then
            g_game.setPVPMode(PVPRedFist)
        end
    else
        ui.pvp:setImageClip(ui.pvp.imageClipUncheckedX .. ' ' .. ui.pvp.imageClipUncheckedY .. ' ' ..
                                ui.pvp.imageClipWidth .. ' 20')
        if not ignoreUpdate then
            g_game.setPVPMode(PVPWhiteHand)
        end
    end
end

function changeInventorySize()
    inventoryShrink = not inventoryShrink
    g_settings.set('mainpanel_shrink_inventory', inventoryShrink)
    refreshInventorySizes()
    reloadMainPanelSizes()
end
-- @ End of Inventory

-- @ Minimap
local otmm = true
local oldPos = nil
local fullscreenWidget
local virtualFloor = 7
local dayTimeEvent
local currentDayTime = {
    h = 12,
    m = 0
}

local function refreshVirtualFloors()
    mapController.ui.layersPanel.layersMark:setMarginTop(((virtualFloor + 1) * 4) - 3)
    mapController.ui.layersPanel.automapLayers:setImageClip((virtualFloor * 14) .. ' 0 14 67')
end
local function onPositionChange()
    local player = g_game.getLocalPlayer()
    if not player then
        return
    end

    local pos = player:getPosition()
    if not pos then
        return
    end

    local minimapWidget = mapController.ui.minimapBorder.minimap
    if not (minimapWidget) or minimapWidget:isDragging() then
        return
    end

    if not minimapWidget.fullMapView then
        minimapWidget:setCameraPosition(pos)
    end

    minimapWidget:setCrossPosition(pos)

    virtualFloor = pos.z
    refreshVirtualFloors()
end

mapController = Controller:new()
mapController:setUI('mainmappanel', modules.game_interface.getMainRightPanel())

local mapControllerEvents = mapController:addEvent(LocalPlayer, {
    onPositionChange = onPositionChange
})

function onChangeWorldTime(hour, minute)
    currentDayTime = {
        h = hour,
        m = minute
    }

    if dayTimeEvent ~= nil then
        removeEvent(dayTimeEvent)
        dayTimeEvent = nil
    end

    dayTimeEvent = scheduleEvent(function()
        local nextH = currentDayTime.h
        local nextM = currentDayTime.m + 12
        if nextM >= 60 then
            nextH = nextH + 1
            nextM = nextM - 60
        end
        onChangeWorldTime(nextH, nextM)
    end, 30000)

    local position = math.floor((124 / (24 * 60)) * ((hour * 60) + minute))
    local mainWidth = 31
    local secondaryWidth = 0

    if (position + 31) >= 124 then
        secondaryWidth = ((position + 31) - 124) + 1
        mainWidth = 31 - secondaryWidth
    end

    mapController.ui.rosePanel.ambients.main:setWidth(mainWidth)
    mapController.ui.rosePanel.ambients.secondary:setWidth(secondaryWidth)

    if secondaryWidth == 0 then
        mapController.ui.rosePanel.ambients.secondary:hide()
    else
        mapController.ui.rosePanel.ambients.secondary:setImageClip('0 0 ' .. secondaryWidth .. ' 31')
        mapController.ui.rosePanel.ambients.secondary:show()
    end

    if mainWidth == 0 then
        mapController.ui.rosePanel.ambients.main:hide()
    else
        mapController.ui.rosePanel.ambients.main:setImageClip(position .. ' 0 ' .. mainWidth .. ' 31')
        mapController.ui.rosePanel.ambients.main:show()
    end
end

function mapController:onInit()
    mapControllerEvents:connect()
    mapControllerEvents:execute('onPositionChange')

    self.ui.minimapBorder.minimap:getChildById('floorUpButton'):hide()
    self.ui.minimapBorder.minimap:getChildById('floorDownButton'):hide()
    self.ui.minimapBorder.minimap:getChildById('zoomInButton'):hide()
    self.ui.minimapBorder.minimap:getChildById('zoomOutButton'):hide()
    self.ui.minimapBorder.minimap:getChildById('resetButton'):hide()

    connect(g_game, {
        onChangeWorldTime = onChangeWorldTime
    })
end

function mapController:onGameStart()
    -- Load Map
    g_minimap.clean()

    local minimapFile = '/minimap'
    local loadFnc = nil

    if otmm then
        minimapFile = minimapFile .. '.otmm'
        loadFnc = g_minimap.loadOtmm
    else
        minimapFile = minimapFile .. '_' .. g_game.getClientVersion() .. '.otcm'
        loadFnc = g_map.loadOtcm
    end

    if g_resources.fileExists(minimapFile) then
        loadFnc(minimapFile)
    end

    self.ui.minimapBorder.minimap:load()
end

function mapController:onGameEnd()
    -- Save Map
    if otmm then
        g_minimap.saveOtmm('/minimap.otmm')
    else
        g_map.saveOtcm('/minimap_' .. g_game.getClientVersion() .. '.otcm')
    end

    self.ui.minimapBorder.minimap:save()
end

function mapController:onTerminate()
    mapControllerEvents:disconnect()
end

function zoomIn()
    mapController.ui.minimapBorder.minimap:zoomIn()
end

function zoomOut()
    mapController.ui.minimapBorder.minimap:zoomOut()
end

function fullscreen()
    local minimapWidget = mapController.ui.minimapBorder.minimap
    if not minimapWidget then
        minimapWidget = fullscreenWidget
    end
    local zoom;

    if not minimapWidget then
        return
    end

    if minimapWidget.fullMapView then
        fullscreenWidget = nil
        minimapWidget:setParent(mapController.ui.minimapBorder)
        minimapWidget:fill('parent')
        mapController.ui:show(true)
        zoom = minimapWidget.zoomMinimap
        mapController:unbindKeyDown('Escape', fullscreen)
        minimapWidget.fullMapView = false
    else
        fullscreenWidget = minimapWidget
        mapController.ui:hide(true)
        minimapWidget:setParent(modules.game_interface.getRootPanel())
        minimapWidget:fill('parent')
        zoom = minimapWidget.zoomFullmap
        mapController:bindKeyDown('Escape', fullscreen)
        minimapWidget.fullMapView = true
    end

    local pos = oldPos or minimapWidget:getCameraPosition()
    oldPos = minimapWidget:getCameraPosition()
    minimapWidget:setZoom(zoom)
    minimapWidget:setCameraPosition(pos)
end

function upLayer()
    if virtualFloor == 0 then
        return
    end

    mapController.ui.minimapBorder.minimap:floorUp(1)
    virtualFloor = virtualFloor - 1
    refreshVirtualFloors()
end

function downLayer()
    if virtualFloor == 15 then
        return
    end

    mapController.ui.minimapBorder.minimap:floorDown(1)
    virtualFloor = virtualFloor + 1
    refreshVirtualFloors()
end

function onClickRoseButton(dir)
    if dir == 'north' then
        mapController.ui.minimapBorder.minimap:move(0, 1)
    elseif dir == 'north-east' then
        mapController.ui.minimapBorder.minimap:move(-1, 1)
    elseif dir == 'east' then
        mapController.ui.minimapBorder.minimap:move(-1, 0)
    elseif dir == 'south-east' then
        mapController.ui.minimapBorder.minimap:move(-1, -1)
    elseif dir == 'south' then
        mapController.ui.minimapBorder.minimap:move(0, -1)
    elseif dir == 'south-west' then
        mapController.ui.minimapBorder.minimap:move(1, -1)
    elseif dir == 'west' then
        mapController.ui.minimapBorder.minimap:move(1, 0)
    elseif dir == 'north-west' then
        mapController.ui.minimapBorder.minimap:move(1, 1)
    end
end

function resetMap()
    mapController.ui.minimapBorder.minimap:reset()
    local player = g_game.getLocalPlayer()
    if player then
        virtualFloor = player:getPosition().z
        refreshVirtualFloors()
    end
end


function getMiniMapUi()


    return mapController.ui.minimapBorder.minimap
end
-- @ End of Minimap
