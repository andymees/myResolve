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
for marker_frame, marker in pairs(timelineMarkers) do
    mediapoolTimeline:AddMarker(marker_frame, marker.color, marker.name, marker.note, marker.duration, marker.customData)
end
