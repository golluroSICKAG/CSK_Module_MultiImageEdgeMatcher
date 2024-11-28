--*****************************************************************
-- Here you will find all the required content to provide specific
-- features of this module via the 'CSK FlowConfig'.
--*****************************************************************

require('ImageProcessing.MultiImageEdgeMatcher.FlowConfig.MultiImageEdgeMatcher_ImageSource')
require('ImageProcessing.MultiImageEdgeMatcher.FlowConfig.MultiImageEdgeMatcher_OnNewImage')
require('ImageProcessing.MultiImageEdgeMatcher.FlowConfig.MultiImageEdgeMatcher_OnNewTransformation')
require('ImageProcessing.MultiImageEdgeMatcher.FlowConfig.MultiImageEdgeMatcher_Process')

-- Reference to the multiImageEdgeMatcher_Instances handle
local multiImageEdgeMatcher_Instances

--- Function to react if FlowConfig was updated
local function handleOnClearOldFlow()
  if _G.availableAPIs.default and _G.availableAPIs.specific then
    for i = 1, #multiImageEdgeMatcher_Instances do
      if multiImageEdgeMatcher_Instances[i].parameters.flowConfigPriority then
        CSK_MultiImageEdgeMatcher.clearFlowConfigRelevantConfiguration()
        break
      end
    end
  end
end
Script.register('CSK_FlowConfig.OnClearOldFlow', handleOnClearOldFlow)

--- Function to get access to the multiImageEdgeMatcher_Instances
---@param handle handle Handle of multiImageEdgeMatcher_Instances object
local function setMultiImageEdgeMatcher_Instances_Handle(handle)
  multiImageEdgeMatcher_Instances = handle
end
return setMultiImageEdgeMatcher_Instances_Handle