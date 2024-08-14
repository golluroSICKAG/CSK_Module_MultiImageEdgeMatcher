-- Block namespace
local BLOCK_NAMESPACE = 'MultiImageEdgeMatcher_FC.Process'
local nameOfModule = 'CSK_MultiImageEdgeMatcher'

--*************************************************************
--*************************************************************

-- Required to keep track of already allocated resource
local instanceTable = {}

local function process(handle, imageSource)

  local instance = Container.get(handle, 'Instance')

  -- Check if amount of instances is valid
  -- if not: add multiple additional instances
  while true do
    local amount = CSK_MultiImageEdgeMatcher.getInstancesAmount()
    if amount < instance then
      CSK_MultiImageEdgeMatcher.addInstance()
    else
      CSK_MultiImageEdgeMatcher.setSelectedInstance(instance)
      CSK_MultiImageEdgeMatcher.setRegisterEvent(imageSource)
      break
    end
  end

  return 'CSK_MultiImageEdgeMatcher.OnNewAlignedImage' .. tostring(instance), 'CSK_MultiImageEdgeMatcher.OnNewTransformation' .. tostring(instance)
end
Script.serveFunction(BLOCK_NAMESPACE .. '.process', process)

--*************************************************************
--*************************************************************

local function create(instance)

  -- Check if same instance is already configured
  if instance < 1 or nil ~= instanceTable[instance] then
    _G.logger:warning(nameOfModule .. ': Instance invalid or already in use, please choose another one')
    return nil
  else
    -- Otherwise create handle and store the restriced resource
    local handle = Container.create()
    instanceTable[instance] = instance
    Container.add(handle, 'Instance', instance)
    Container.add(handle, "CB_Function", "")
    return handle
  end
end
Script.serveFunction(BLOCK_NAMESPACE .. '.create', create)

--- Function to reset instances if FlowConfig was cleared
local function handleOnClearOldFlow()
  Script.releaseObject(instanceTable)
  instanceTable = {}
end
Script.register('CSK_FlowConfig.OnClearOldFlow', handleOnClearOldFlow)
