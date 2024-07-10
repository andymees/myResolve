--[[ There's currently no failsafe method to programmatically identify a timline's corresponding media pool item,
so before running this script you should use the 'Find Current Timeline in Media Pool' menu function.
That will/should ensure the correct bin is open and thus the script finds the right media pool item.

For reference, the script simply looks in the 'current' bin and finds the media pool 'timeline' item with the timeline name.
Then, for each of the active timeline's timeline markers, the script adds a 'clip' marker to the media pool item. 

Note 1: if any clip marker already exists at any of the timeline marker offsets, the original clip marker is preserved.
Note 2: type 'Timeline' is a language specific variable, so you may need to localised for your language. 

Hope it's useful, Andy Mees]]


local function GetMatchingMediaPoolItem(tl)
    -- Get media pool item list for current bin
    items = project:GetMediaPool():GetCurrentFolder():GetClipList()
    -- iterate through list
    for item = 1, #items, 1 do
        -- find matching media pool item
        if tl:GetName() == items[item]:GetName()
            and items[item]:GetClipProperty()['Type'] == 'Timeline' then
            -- return the matching media pool item
            return items[item]
        end
    end
    -- if not found, exit the script
    os.exit()
end

resolve = Resolve()
project = resolve:GetProjectManager():GetCurrentProject()

if not project then
    print("No project is loaded")
    os.exit()
end

timeline = project:GetCurrentTimeline()

if not timeline then
    print("No timeline is active")
    os.exit()
end

-- Get first matching media pool item in current bin
mediapoolTimeline = GetMatchingMediaPoolItem(timeline)

-- Get timeline markers from the active timeline
timelineMarkers = timeline:GetMarkers()

-- Add those markers to the matching media pool item
for marker_offset, marker in pairs(timelineMarkers) do
    mediapoolTimeline:AddMarker(marker_offset, marker.color, marker.name, marker.note, marker.duration, marker.customData)
end
