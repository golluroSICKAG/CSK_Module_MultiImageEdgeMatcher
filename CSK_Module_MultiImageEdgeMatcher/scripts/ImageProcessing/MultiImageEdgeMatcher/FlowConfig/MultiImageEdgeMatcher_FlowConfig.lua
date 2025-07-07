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
    CSK_MultiImageEdgeMatcher.clearFlowConfigRelevantConfiguration()
  end
end
Script.register('CSK_FlowConfig.OnClearOldFlow', handleOnClearOldFlow)
