---@diagnostic disable: undefined-global, redundant-parameter, missing-parameter

--***************************************************************
-- Inside of this script, you will find the necessary functions,
-- variables and events to communicate with the MultiImageEdgeMatcher_Model and _Instances
--***************************************************************

--**************************************************************************
--************************ Start Global Scope ******************************
--**************************************************************************
local nameOfModule = 'CSK_MultiImageEdgeMatcher'

local funcs = {}

-- Timer to update UI via events after page was loaded
local tmrMultiImageEdgeMatcher = Timer.create()
tmrMultiImageEdgeMatcher:setExpirationTime(300)
tmrMultiImageEdgeMatcher:setPeriodic(false)

local multiImageEdgeMatcher_Model -- Reference to model handle
local multiImageEdgeMatcher_Instances -- Reference to instances handle
local selectedInstance = 1 -- Which instance is currently selected
local helperFuncs = require('ImageProcessing/MultiImageEdgeMatcher/helper/funcs')

local roiEditorActive = false -- Setting of ROI is currently active

-- ************************ UI Events Start ********************************
-- Only to prevent WARNING messages, but these are only examples/placeholders for dynamically created events/functions
----------------------------------------------------------------
local function emptyFunction()
end
Script.serveFunction("CSK_MultiImageEdgeMatcher.processInstanceNUM", emptyFunction)
Script.serveEvent("CSK_MultiImageEdgeMatcher.OnNewValueToForwardNUM", "MultiImageEdgeMatcher_OnNewValueToForwardNUM")
Script.serveEvent("CSK_MultiImageEdgeMatcher.OnNewValueUpdateNUM", "MultiImageEdgeMatcher_OnNewValueUpdateNUM")
Script.serveEvent('CSK_MultiImageEdgeMatcher.OnNewAlignedImageNUM', 'MultiImageEdgeMatcher_OnNewAlignedImageNUM')

Script.serveEvent('CSK_MultiImageEdgeMatcher.OnNewStatusFoundMatchesNUM', 'MultiImageEdgeMatcher_OnNewStatusFoundMatchesNUM')
Script.serveEvent('CSK_MultiImageEdgeMatcher.OnNewStatusMatchScoreResultNUM', 'MultiImageEdgeMatcher_OnNewStatusMatchScoreResultNUM')
----------------------------------------------------------------

-- Real events
--------------------------------------------------

Script.serveEvent('CSK_MultiImageEdgeMatcher.OnNewStatusRegisteredEvent', 'MultiImageEdgeMatcher_OnNewStatusRegisteredEvent')
Script.serveEvent('CSK_MultiImageEdgeMatcher.OnNewViewerID', 'MultiImageEdgeMatcher_OnNewViewerID')
Script.serveEvent("CSK_MultiImageEdgeMatcher.OnNewStatusShowImage", "MultiImageEdgeMatcher_OnNewStatusShowImage")
Script.serveEvent("CSK_MultiImageEdgeMatcher.OnROIEditorActive", "MultiImageEdgeMatcher_OnROIEditorActive")

Script.serveEvent('CSK_MultiImageEdgeMatcher.OnNewStatusEdgeThreshold', 'MultiImageEdgeMatcher_OnNewStatusEdgeThreshold')
Script.serveEvent('CSK_MultiImageEdgeMatcher.OnNewStatusMinimalScore', 'MultiImageEdgeMatcher_OnNewStatusMinimalScore')
Script.serveEvent('CSK_MultiImageEdgeMatcher.OnNewStatusDownsampleFactor', 'MultiImageEdgeMatcher_OnNewStatusDownsampleFactor')
Script.serveEvent('CSK_MultiImageEdgeMatcher.OnNewStatusMaxMatches', 'MultiImageEdgeMatcher_OnNewStatusMaxMatches')

Script.serveEvent('CSK_MultiImageEdgeMatcher.OnNewStatusFoundMatches', 'MultiImageEdgeMatcher_OnNewStatusFoundMatches')
Script.serveEvent('CSK_MultiImageEdgeMatcher.OnNewStatusMatchScoreResult', 'MultiImageEdgeMatcher_OnNewStatusMatchScoreResult')

Script.serveEvent("CSK_MultiImageEdgeMatcher.OnNewStatusLoadParameterOnReboot", "MultiImageEdgeMatcher_OnNewStatusLoadParameterOnReboot")
Script.serveEvent("CSK_MultiImageEdgeMatcher.OnPersistentDataModuleAvailable", "MultiImageEdgeMatcher_OnPersistentDataModuleAvailable")
Script.serveEvent("CSK_MultiImageEdgeMatcher.OnNewParameterName", "MultiImageEdgeMatcher_OnNewParameterName")

Script.serveEvent("CSK_MultiImageEdgeMatcher.OnNewInstanceList", "MultiImageEdgeMatcher_OnNewInstanceList")
Script.serveEvent("CSK_MultiImageEdgeMatcher.OnNewProcessingParameter", "MultiImageEdgeMatcher_OnNewProcessingParameter")
Script.serveEvent("CSK_MultiImageEdgeMatcher.OnNewSelectedInstance", "MultiImageEdgeMatcher_OnNewSelectedInstance")
Script.serveEvent("CSK_MultiImageEdgeMatcher.OnDataLoadedOnReboot", "MultiImageEdgeMatcher_OnDataLoadedOnReboot")

Script.serveEvent("CSK_MultiImageEdgeMatcher.OnUserLevelOperatorActive", "MultiImageEdgeMatcher_OnUserLevelOperatorActive")
Script.serveEvent("CSK_MultiImageEdgeMatcher.OnUserLevelMaintenanceActive", "MultiImageEdgeMatcher_OnUserLevelMaintenanceActive")
Script.serveEvent("CSK_MultiImageEdgeMatcher.OnUserLevelServiceActive", "MultiImageEdgeMatcher_OnUserLevelServiceActive")
Script.serveEvent("CSK_MultiImageEdgeMatcher.OnUserLevelAdminActive", "MultiImageEdgeMatcher_OnUserLevelAdminActive")

-- ************************ UI Events End **********************************

--[[
--- Some internal code docu for local used function
local function functionName()
  -- Do something

end
]]

--**************************************************************************
--********************** End Global Scope **********************************
--**************************************************************************
--**********************Start Function Scope *******************************
--**************************************************************************

-- Functions to forward logged in user roles via CSK_UserManagement module (if available)
-- ***********************************************
--- Function to react on status change of Operator user level
---@param status boolean Status if Operator level is active
local function handleOnUserLevelOperatorActive(status)
  Script.notifyEvent("MultiImageEdgeMatcher_OnUserLevelOperatorActive", status)
end

--- Function to react on status change of Maintenance user level
---@param status boolean Status if Maintenance level is active
local function handleOnUserLevelMaintenanceActive(status)
  Script.notifyEvent("MultiImageEdgeMatcher_OnUserLevelMaintenanceActive", status)
end

--- Function to react on status change of Service user level
---@param status boolean Status if Service level is active
local function handleOnUserLevelServiceActive(status)
  Script.notifyEvent("MultiImageEdgeMatcher_OnUserLevelServiceActive", status)
end

--- Function to react on status change of Admin user level
---@param status boolean Status if Admin level is active
local function handleOnUserLevelAdminActive(status)
  Script.notifyEvent("MultiImageEdgeMatcher_OnUserLevelAdminActive", status)
end
-- ***********************************************

--- Function to forward data updates from instance threads to Controller part of module
---@param eventname string Eventname to use to forward value
---@param value auto Value to forward
local function handleOnNewValueToForward(eventname, value)
  Script.notifyEvent(eventname, value)
end

--- Optionally: Only use if needed for extra internal objects -  see also Model
--- Function to sync paramters between instance threads and Controller part of module
---@param instance int Instance new value is coming from
---@param parameter string Name of the paramter to update/sync
---@param value auto Value to update
---@param selectedObject int? Optionally if internal parameter should be used for internal objects
local function handleOnNewValueUpdate(instance, parameter, value, selectedObject)
    if parameter == 'matcher' then
      local newMatcher = Object.deserialize(value, 'JSON')
      multiImageEdgeMatcher_Instances[instance].parameters.matcher = newMatcher
    end
end

--- Function to get access to the multiImageEdgeMatcher_Model object
---@param handle handle Handle of multiImageEdgeMatcher_Model object
local function setMultiImageEdgeMatcher_Model_Handle(handle)
  multiImageEdgeMatcher_Model = handle
  Script.releaseObject(handle)
end
funcs.setMultiImageEdgeMatcher_Model_Handle = setMultiImageEdgeMatcher_Model_Handle

--- Function to get access to the multiImageEdgeMatcher_Instances object
---@param handle handle Handle of multiImageEdgeMatcher_Instances object
local function setMultiImageEdgeMatcher_Instances_Handle(handle)
  multiImageEdgeMatcher_Instances = handle
  if multiImageEdgeMatcher_Instances[selectedInstance].userManagementModuleAvailable then
    -- Register on events of CSK_UserManagement module if available
    Script.register('CSK_UserManagement.OnUserLevelOperatorActive', handleOnUserLevelOperatorActive)
    Script.register('CSK_UserManagement.OnUserLevelMaintenanceActive', handleOnUserLevelMaintenanceActive)
    Script.register('CSK_UserManagement.OnUserLevelServiceActive', handleOnUserLevelServiceActive)
    Script.register('CSK_UserManagement.OnUserLevelAdminActive', handleOnUserLevelAdminActive)
  end
  Script.releaseObject(handle)

  for i = 1, #multiImageEdgeMatcher_Instances do
    Script.register("CSK_MultiImageEdgeMatcher.OnNewValueToForward" .. tostring(i) , handleOnNewValueToForward)
  end

  for i = 1, #multiImageEdgeMatcher_Instances do
    Script.register("CSK_MultiImageEdgeMatcher.OnNewValueUpdate" .. tostring(i) , handleOnNewValueUpdate)
  end

end
funcs.setMultiImageEdgeMatcher_Instances_Handle = setMultiImageEdgeMatcher_Instances_Handle

--- Function to update user levels
local function updateUserLevel()
  if multiImageEdgeMatcher_Instances[selectedInstance].userManagementModuleAvailable then
    -- Trigger CSK_UserManagement module to provide events regarding user role
    CSK_UserManagement.pageCalled()
  else
    -- If CSK_UserManagement is not active, show everything
    Script.notifyEvent("MultiImageEdgeMatcher_OnUserLevelAdminActive", true)
    Script.notifyEvent("MultiImageEdgeMatcher_OnUserLevelMaintenanceActive", true)
    Script.notifyEvent("MultiImageEdgeMatcher_OnUserLevelServiceActive", true)
    Script.notifyEvent("MultiImageEdgeMatcher_OnUserLevelOperatorActive", true)
  end
end

--- Function to send all relevant values to UI on resume
local function handleOnExpiredTmrMultiImageEdgeMatcher()
  -- Script.notifyEvent("MultiImageEdgeMatcher_OnNewEvent", false)

  updateUserLevel()

  Script.notifyEvent('MultiImageEdgeMatcher_OnNewSelectedInstance', selectedInstance)
  Script.notifyEvent("MultiImageEdgeMatcher_OnNewInstanceList", helperFuncs.createStringListBySize(#multiImageEdgeMatcher_Instances))

  Script.notifyEvent('MultiImageEdgeMatcher_OnNewStatusRegisteredEvent', multiImageEdgeMatcher_Instances[selectedInstance].parameters.registeredEvent)
  Script.notifyEvent('MultiImageEdgeMatcher_OnNewViewerID', 'multiImageEdgeMatcherViewer' .. tostring(selectedInstance))
  Script.notifyEvent('MultiImageEdgeMatcher_OnNewStatusShowImage', multiImageEdgeMatcher_Instances[selectedInstance].parameters.showImage)
  Script.notifyEvent('MultiImageEdgeMatcher_OnROIEditorActive', roiEditorActive)

  Script.notifyEvent('MultiImageEdgeMatcher_OnNewStatusEdgeThreshold', multiImageEdgeMatcher_Instances[selectedInstance].parameters.edgeThreshold)
  Script.notifyEvent('MultiImageEdgeMatcher_OnNewStatusMinimalScore', multiImageEdgeMatcher_Instances[selectedInstance].parameters.minScore)
  Script.notifyEvent('MultiImageEdgeMatcher_OnNewStatusDownsampleFactor', multiImageEdgeMatcher_Instances[selectedInstance].parameters.downsampleFactor)
  Script.notifyEvent('MultiImageEdgeMatcher_OnNewStatusMaxMatches', multiImageEdgeMatcher_Instances[selectedInstance].parameters.maxMatches)

  Script.notifyEvent("MultiImageEdgeMatcher_OnNewStatusFoundMatches", '0')
  Script.notifyEvent("MultiImageEdgeMatcher_OnNewStatusMatchScoreResult", '0.0')

  Script.notifyEvent("MultiImageEdgeMatcher_OnNewStatusLoadParameterOnReboot", multiImageEdgeMatcher_Instances[selectedInstance].parameterLoadOnReboot)
  Script.notifyEvent("MultiImageEdgeMatcher_OnPersistentDataModuleAvailable", multiImageEdgeMatcher_Instances[selectedInstance].persistentModuleAvailable)
  Script.notifyEvent("MultiImageEdgeMatcher_OnNewParameterName", multiImageEdgeMatcher_Instances[selectedInstance].parametersName)

  -- ...
end
Timer.register(tmrMultiImageEdgeMatcher, "OnExpired", handleOnExpiredTmrMultiImageEdgeMatcher)

-- ********************* UI Setting / Submit Functions Start ********************

local function pageCalled()
  updateUserLevel() -- try to hide user specific content asap
  tmrMultiImageEdgeMatcher:start()
  return ''
end
Script.serveFunction("CSK_MultiImageEdgeMatcher.pageCalled", pageCalled)

local function setSelectedInstance(instance)
  roiEditorActive = false
  Script.notifyEvent('MultiImageEdgeMatcher_OnNewProcessingParameter', selectedInstance, 'chancelEditors', true)


  selectedInstance = instance
  _G.logger:info(nameOfModule .. ": New selected instance = " .. tostring(selectedInstance))
  multiImageEdgeMatcher_Instances[selectedInstance].activeInUI = true
  Script.notifyEvent('MultiImageEdgeMatcher_OnNewProcessingParameter', selectedInstance, 'activeInUI', true)
  tmrMultiImageEdgeMatcher:start()
end
Script.serveFunction("CSK_MultiImageEdgeMatcher.setSelectedInstance", setSelectedInstance)

local function getInstancesAmount ()
  return #multiImageEdgeMatcher_Instances
end
Script.serveFunction("CSK_MultiImageEdgeMatcher.getInstancesAmount", getInstancesAmount)

local function addInstance()
  _G.logger:info(nameOfModule .. ": Add instance")
  table.insert(multiImageEdgeMatcher_Instances, multiImageEdgeMatcher_Model.create(#multiImageEdgeMatcher_Instances+1))
  Script.deregister("CSK_MultiImageEdgeMatcher.OnNewValueToForward" .. tostring(#multiImageEdgeMatcher_Instances) , handleOnNewValueToForward)
  Script.register("CSK_MultiImageEdgeMatcher.OnNewValueToForward" .. tostring(#multiImageEdgeMatcher_Instances) , handleOnNewValueToForward)
  handleOnExpiredTmrMultiImageEdgeMatcher()
end
Script.serveFunction('CSK_MultiImageEdgeMatcher.addInstance', addInstance)

local function resetInstances()
  _G.logger:info(nameOfModule .. ": Reset instances.")
  setSelectedInstance(1)
  local totalAmount = #multiImageEdgeMatcher_Instances
  while totalAmount > 1 do
    Script.releaseObject(multiImageEdgeMatcher_Instances[totalAmount])
    multiImageEdgeMatcher_Instances[totalAmount] =  nil
    totalAmount = totalAmount - 1
  end
  handleOnExpiredTmrMultiImageEdgeMatcher()
end
Script.serveFunction('CSK_MultiImageEdgeMatcher.resetInstances', resetInstances)

local function setRegisterEvent(event)
  multiImageEdgeMatcher_Instances[selectedInstance].parameters.registeredEvent = event
  Script.notifyEvent('MultiImageEdgeMatcher_OnNewProcessingParameter', selectedInstance, 'registeredEvent', event)
end
Script.serveFunction("CSK_MultiImageEdgeMatcher.setRegisterEvent", setRegisterEvent)

local function setShowImage(status)
  _G.logger:info(nameOfModule .. ": Set show image: " .. tostring(status))
  multiImageEdgeMatcher_Instances[selectedInstance].parameters.showImage = status
  Script.notifyEvent('MultiImageEdgeMatcher_OnNewProcessingParameter', selectedInstance, 'showImage', status)
end
Script.serveFunction("CSK_MultiImageEdgeMatcher.setShowImage", setShowImage)

--- Function to share process relevant configuration with processing threads
local function updateProcessingParameters()
  Script.notifyEvent('MultiImageEdgeMatcher_OnNewProcessingParameter', selectedInstance, 'activeInUI', true)
  Script.notifyEvent('MultiImageEdgeMatcher_OnNewProcessingParameter', selectedInstance, 'showImage', multiImageEdgeMatcher_Instances[selectedInstance].parameters.showImage)

  Script.notifyEvent('MultiImageEdgeMatcher_OnNewProcessingParameter', selectedInstance, 'edgeThreshold', multiImageEdgeMatcher_Instances[selectedInstance].parameters.edgeThreshold)
  Script.notifyEvent('MultiImageEdgeMatcher_OnNewProcessingParameter', selectedInstance, 'downsampleFactor', multiImageEdgeMatcher_Instances[selectedInstance].parameters.downsampleFactor)
  Script.notifyEvent('MultiImageEdgeMatcher_OnNewProcessingParameter', selectedInstance, 'minScore', multiImageEdgeMatcher_Instances[selectedInstance].parameters.minScore)
  Script.notifyEvent('MultiImageEdgeMatcher_OnNewProcessingParameter', selectedInstance, 'maxMatches', multiImageEdgeMatcher_Instances[selectedInstance].parameters.maxMatches)
  Script.notifyEvent('MultiImageEdgeMatcher_OnNewProcessingParameter', selectedInstance, 'matcher', multiImageEdgeMatcher_Instances[selectedInstance].parameters.matcher)

  Script.notifyEvent('MultiImageEdgeMatcher_OnNewProcessingParameter', selectedInstance, 'registeredEvent', multiImageEdgeMatcher_Instances[selectedInstance].parameters.registeredEvent)

  -- optionally for internal objects...
  --[[
  -- Send config to instances
  local params = helperFuncs.convertTable2Container(multiImageEdgeMatcher_Instances[selectedInstance].parameters.internalObject)
  Container.add(data, 'internalObject', params, 'OBJECT')
  Script.notifyEvent('MultiImageEdgeMatcher_OnNewProcessingParameter', selectedInstance, 'FullSetup', data)
  ]]

end

local function setTeachMode(status)
  _G.logger:info(nameOfModule .. ": Set teach mode: " .. tostring(status))
  roiEditorActive = status
  Script.notifyEvent("MultiImageEdgeMatcher_OnROIEditorActive", status)
  Script.notifyEvent('MultiImageEdgeMatcher_OnNewProcessingParameter', selectedInstance, 'roiEditorActive', status)
end
Script.serveFunction("CSK_MultiImageEdgeMatcher.setTeachMode", setTeachMode)

local function setEdgeThreshold(threshold)
  _G.logger:info(nameOfModule .. ": Set edge threshold to: " .. tostring(threshold))
  multiImageEdgeMatcher_Instances[selectedInstance].parameters.edgeThreshold = threshold
  Script.notifyEvent('MultiImageEdgeMatcher_OnNewProcessingParameter', selectedInstance, 'edgeThreshold', threshold)
end
Script.serveFunction('CSK_MultiImageEdgeMatcher.setEdgeThreshold', setEdgeThreshold)

local function setMinimumValidScore(minScore)
  _G.logger:info(nameOfModule .. ": Set minimal score to: " .. tostring(minScore))
  multiImageEdgeMatcher_Instances[selectedInstance].parameters.minScore = minScore
  Script.notifyEvent('MultiImageEdgeMatcher_OnNewProcessingParameter', selectedInstance, 'minScore', minScore)
end
Script.serveFunction('CSK_MultiImageEdgeMatcher.setMinimumValidScore', setMinimumValidScore)

local function setDownsampleFactor(factor)
  _G.logger:info(nameOfModule .. ": Set downsample factor to: " .. tostring(factor))
  multiImageEdgeMatcher_Instances[selectedInstance].parameters.downsampleFactor = factor
  Script.notifyEvent('MultiImageEdgeMatcher_OnNewProcessingParameter', selectedInstance, 'downsampleFactor', factor)
end
Script.serveFunction('CSK_MultiImageEdgeMatcher.setDownsampleFactor', setDownsampleFactor)

local function setMaximumMatches(max)
  _G.logger:info(nameOfModule .. ": Set maximum amount of matches to search for: " .. tostring(max))
  multiImageEdgeMatcher_Instances[selectedInstance].parameters.maxMatches = max
  Script.notifyEvent('MultiImageEdgeMatcher_OnNewProcessingParameter', selectedInstance, 'maxMatches', max)
end
Script.serveFunction('CSK_MultiImageEdgeMatcher.setMaximumMatches', setMaximumMatches)

-- *****************************************************************
-- Following function can be adapted for CSK_PersistentData module usage
-- *****************************************************************

local function setParameterName(name)
  _G.logger:info(nameOfModule .. ": Set parameter name = " .. tostring(name))
  multiImageEdgeMatcher_Instances[selectedInstance].parametersName = name
end
Script.serveFunction("CSK_MultiImageEdgeMatcher.setParameterName", setParameterName)

local function sendParameters()
  if multiImageEdgeMatcher_Instances[selectedInstance].persistentModuleAvailable then
    CSK_PersistentData.addParameter(helperFuncs.convertTable2Container(multiImageEdgeMatcher_Instances[selectedInstance].parameters), multiImageEdgeMatcher_Instances[selectedInstance].parametersName)

    -- Check if CSK_PersistentData version is >= 3.0.0
    if tonumber(string.sub(CSK_PersistentData.getVersion(), 1, 1)) >= 3 then
      CSK_PersistentData.setModuleParameterName(nameOfModule, multiImageEdgeMatcher_Instances[selectedInstance].parametersName, multiImageEdgeMatcher_Instances[selectedInstance].parameterLoadOnReboot, tostring(selectedInstance), #multiImageEdgeMatcher_Instances)
    else
      CSK_PersistentData.setModuleParameterName(nameOfModule, multiImageEdgeMatcher_Instances[selectedInstance].parametersName, multiImageEdgeMatcher_Instances[selectedInstance].parameterLoadOnReboot, tostring(selectedInstance))
    end
    _G.logger:info(nameOfModule .. ": Send MultiImageEdgeMatcher parameters with name '" .. multiImageEdgeMatcher_Instances[selectedInstance].parametersName .. "' to CSK_PersistentData module.")
    CSK_PersistentData.saveData()
  else
    _G.logger:warning(nameOfModule .. ": CSK_PersistentData module not available.")
  end
end
Script.serveFunction("CSK_MultiImageEdgeMatcher.sendParameters", sendParameters)

local function loadParameters()
  if multiImageEdgeMatcher_Instances[selectedInstance].persistentModuleAvailable then
    local data = CSK_PersistentData.getParameter(multiImageEdgeMatcher_Instances[selectedInstance].parametersName)
    if data then
      _G.logger:info(nameOfModule .. ": Loaded parameters for multiImageEdgeMatcherObject " .. tostring(selectedInstance) .. " from CSK_PersistentData module.")

      multiImageEdgeMatcher_Instances[selectedInstance].parameters = helperFuncs.convertContainer2Table(data)
      local serMatcher = Object.serialize(multiImageEdgeMatcher_Instances[selectedInstance].parameters.matcher, 'JSON')
      local newMatcher = Object.deserialize(serMatcher, 'JSON')
      multiImageEdgeMatcher_Instances[selectedInstance].parameters.matcher = newMatcher

      -- If something needs to be configured/activated with new loaded data
      updateProcessingParameters()
      CSK_MultiImageEdgeMatcher.pageCalled()
    else
      _G.logger:warning(nameOfModule .. ": Loading parameters from CSK_PersistentData module did not work.")
    end
  else
    _G.logger:warning(nameOfModule .. ": CSK_PersistentData module not available.")
  end
  tmrMultiImageEdgeMatcher:start()
end
Script.serveFunction("CSK_MultiImageEdgeMatcher.loadParameters", loadParameters)

local function setLoadOnReboot(status)
  multiImageEdgeMatcher_Instances[selectedInstance].parameterLoadOnReboot = status
  _G.logger:info(nameOfModule .. ": Set new status to load setting on reboot: " .. tostring(status))
end
Script.serveFunction("CSK_MultiImageEdgeMatcher.setLoadOnReboot", setLoadOnReboot)

--- Function to react on initial load of persistent parameters
local function handleOnInitialDataLoaded()

  _G.logger:info(nameOfModule .. ': Try to initially load parameter from CSK_PersistentData module.')
  if string.sub(CSK_PersistentData.getVersion(), 1, 1) == '1' then

    _G.logger:warning(nameOfModule .. ': CSK_PersistentData module is too old and will not work. Please update CSK_PersistentData module.')

    for j = 1, #multiImageEdgeMatcher_Instances do
      multiImageEdgeMatcher_Instances[j].persistentModuleAvailable = false
    end
  else
    -- Check if CSK_PersistentData version is >= 3.0.0
    if tonumber(string.sub(CSK_PersistentData.getVersion(), 1, 1)) >= 3 then
      local parameterName, loadOnReboot, totalInstances = CSK_PersistentData.getModuleParameterName(nameOfModule, '1')
      -- Check for amount if instances to create
      if totalInstances then
        local c = 2
        while c <= totalInstances do
          addInstance()
          c = c+1
        end
      end
    end

    for i = 1, #multiImageEdgeMatcher_Instances do
      local parameterName, loadOnReboot = CSK_PersistentData.getModuleParameterName(nameOfModule, tostring(i))

      if parameterName then
        multiImageEdgeMatcher_Instances[i].parametersName = parameterName
        multiImageEdgeMatcher_Instances[i].parameterLoadOnReboot = loadOnReboot
      end

      if multiImageEdgeMatcher_Instances[i].parameterLoadOnReboot then
        setSelectedInstance(i)
        loadParameters()
      end
    end
    Script.notifyEvent('MultiImageEdgeMatcher_OnDataLoadedOnReboot')
  end
end
Script.register("CSK_PersistentData.OnInitialDataLoaded", handleOnInitialDataLoaded)

return funcs

--**************************************************************************
--**********************End Function Scope *********************************
--**************************************************************************

