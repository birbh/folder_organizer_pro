-- usage guide
-- 1. baseline test: uncomment organizeBaseline in on run and comment the other lines.
-- 2. batch test: uncomment organizeBatchNoCache in on run.
-- 3. best repeat-run test: leave organizeBatchWithCache enabled.
-- 4. for stay-open behavior, export as an application and keep stay open after run handler enabled.

property runEverySeconds : 300

on run
	-- present a simple UI: dropdown to select mode, then a Run button
	set modes to {"organizeBaseline", "organizeBatchNoCache", "organizeBatchWithCache"}
	set defaultMode to "organizeBatchWithCache"
	set userChoice to (choose from list modes ¬¨
		with prompt ¬¨
		"Select organizer mode:" default items {defaultMode})
	if userChoice is false then return runEverySeconds
	set chosenMode to item 1 of userChoice
	
	set resp to display dialog "Run organizer in mode: " & chosenMode buttons {"Run", "Cancel"} default button "Run"
	if button returned of resp is "Cancel" then return runEverySeconds
	
	set targetFolder to (path to downloads folder) as alias
	if chosenMode is "organizeBaseline" then
		set resultRecord to my organizeBaseline(targetFolder)
	else if chosenMode is "organizeBatchNoCache" then
		set resultRecord to my organizeBatchNoCache(targetFolder)
	else
		set resultRecord to my organizeBatchWithCache(targetFolder)
	end if
	
	display dialog "Organizer run complete." & return & ¬¨
		"Moved: " & (movedCount of resultRecord) & return & ¬¨
		"Runtime: " & (elapsedSeconds of resultRecord) & " seconds" buttons {"OK"} default button "OK"
	return runEverySeconds
end run

on idle
	set resultRecord to my runOrganizerOnce()
	if (movedCount of resultRecord) > 0 then
		display notification "Moved " & (movedCount of resultRecord) & " files in " & (elapsedSeconds of resultRecord) & "s" with title "Downloads Folder Organizer Pro"
	end if
	return runEverySeconds
end idle

on runOrganizerOnce()
	set targetFolder to (path to downloads folder) as alias
	-- default mode: cached batch run for ship-ready stay-open behavior use organizeBatchNoCache for non-cached batch test, and organizeBaseline for slow baseline test.
	return my organizeBatchWithCache(targetFolder)
end runOrganizerOnce

on organizeBaseline(targetFolderAlias)
	set startTime to (current date)
	set movedCount to 0
	
	tell application "Finder"
		set targetFolder to targetFolderAlias as alias
		
		--subfolders
		my ensureFolderExists(targetFolder, "Music")
		my ensureFolderExists(targetFolder, "Videos")
		my ensureFolderExists(targetFolder, "Images")
		my ensureFolderExists(targetFolder, "Documents")
		my ensureFolderExists(targetFolder, "Archives")
		my ensureFolderExists(targetFolder, "Other")
		
		set allItems to every file of targetFolder
		repeat with oneFile in allItems
			set fileName to (name of oneFile) as text
			set destinationFolderName to my destinationForFile(fileName)
			
			if destinationFolderName is not "" then
				set destinationFolderRef to my folderRefForName(targetFolder, destinationFolderName)
				move oneFile to destinationFolderRef with replacing
				set movedCount to movedCount + 1
				my appendLog("Moved: " & fileName & " -> " & destinationFolderName)
			end if
		end repeat
	end tell
	set elapsedSeconds to ((current date) - startTime)
	my appendLog("BASELINE finished | moved=" & movedCount & " | runtime=" & elapsedSeconds & "s")
	return {movedCount:movedCount, elapsedSeconds:elapsedSeconds}
end organizeBaseline

on destinationForFile(fileName)
	ignoring case
		if fileName ends with ".jpg" or fileName ends with ".jpeg" or fileName ends with ".png" or fileName ends with ".gif" or fileName ends with ".bmp" or fileName ends with ".svg" or fileName ends with ".ico" or fileName ends with ".webp" or fileName ends with ".tiff" or fileName ends with ".heic" then
			return "Images"
		else if fileName ends with ".pdf" or fileName ends with ".doc" or fileName ends with ".txt" or fileName ends with ".docx" or fileName ends with ".xlsx" or fileName ends with ".xls" or fileName ends with ".ppt" or fileName ends with ".pptx" or fileName ends with ".rtf" or fileName ends with ".odt" or fileName ends with ".pages" or fileName ends with ".numbers" or fileName ends with ".keynote" then
			return "Documents"
		else if fileName ends with ".zip" or fileName ends with ".dmg" or fileName ends with ".pkg" or fileName ends with ".rar" or fileName ends with ".7z" or fileName ends with ".tar" or fileName ends with ".gz" then
			return "Archives"
		else if fileName ends with ".mp4" or fileName ends with ".mov" or fileName ends with ".avi" or fileName ends with ".mkv" or fileName ends with ".flv" or fileName ends with ".wmv" or fileName ends with ".webm" or fileName ends with ".m4v" then
			return "Videos"
		else if fileName ends with ".mp3" or fileName ends with ".wav" or fileName ends with ".aac" or fileName ends with ".flac" or fileName ends with ".m4a" or fileName ends with ".opus" or fileName ends with ".alac" or fileName ends with ".ogg" then
			return "Music"
		end if
	end ignoring
	return "Other"
end destinationForFile
on ensureFolderExists(parentFolder, folderName)
	tell application "Finder"
		if not (exists folder folderName of parentFolder) then
			make new folder at parentFolder with properties {name:folderName}
			my appendLog("Created folder:" & folderName)
		end if
	end tell
end ensureFolderExists

on folderRefForName(targetFolder, folderName)
	tell application "Finder"
		if folderName is "Images" then return folder "Images" of targetFolder
		if folderName is "Documents" then return folder "Documents" of targetFolder
		if folderName is "Archives" then return folder "Archives" of targetFolder
		if folderName is "Videos" then return folder "Videos" of targetFolder
		if folderName is "Music" then return folder "Music" of targetFolder
		if folderName is "Other" then return folder "Other" of targetFolder
	end tell
	error "Unknown destination folder: " & folderName
end folderRefForName


on appendLog(logMessage)
	set timestamp to do shell script "date '+%Y-%m-%d %H:%M:%S'"
	set logPath to (POSIX path of (path to desktop folder)) & "OrganizerLog.txt"
	do shell script "printf %s\\\\n " & quoted form of ("[" & timestamp & "] " & logMessage) & " >> " & quoted form of logPath
	
end appendLog



on organizeBatchNoCache(targetFolderAlias)
	set startTime to (current date)
	set movedCount to 0
	
	tell application "Finder"
		set targetFolder to targetFolderAlias as alias
		
		my ensureFolderExists(targetFolder, "Music")
		my ensureFolderExists(targetFolder, "Videos")
		my ensureFolderExists(targetFolder, "Images")
		my ensureFolderExists(targetFolder, "Documents")
		my ensureFolderExists(targetFolder, "Archives")
		my ensureFolderExists(targetFolder, "Other")
		
		set movedCount to movedCount + (my moveBatch(targetFolder, {"jpg", "jpeg", "png", "gif", "bmp", "svg", "ico", "webp", "tiff", "heic"}, "Images"))
		set movedCount to movedCount + (my moveBatch(targetFolder, {"pdf", "doc", "docx", "txt", "xlsx", "xls", "ppt", "pptx", "rtf", "odt", "pages", "numbers", "keynote"}, "Documents"))
		set movedCount to movedCount + (my moveBatch(targetFolder, {"zip", "dmg", "pkg", "rar", "7z", "tar", "gz"}, "Archives"))
		set movedCount to movedCount + (my moveBatch(targetFolder, {"mp4", "mov", "avi", "mkv", "flv", "wmv", "webm", "m4v"}, "Videos"))
		set movedCount to movedCount + (my moveBatch(targetFolder, {"mp3", "aac", "wav", "flac", "m4a", "opus", "alac", "ogg"}, "Music"))
		set movedCount to movedCount + (my moveOther(targetFolder, "Other"))
		
	end tell
	
	set elapsedSeconds to ((current date) - startTime)
	my appendLog("BATCH finished | moved=" & movedCount & " | runtime=" & elapsedSeconds & "s")
	return {movedCount:movedCount, elapsedSeconds:elapsedSeconds}
	
end organizeBatchNoCache

on organizeBatchWithCache(targetFolderAlias)
	set startTime to (current date)
	set movedCount to 0
	set processedCache to my loadCache()
	
	tell application "Finder"
		set targetFolder to targetFolderAlias as alias
		
		my ensureFolderExists(targetFolder, "Music")
		my ensureFolderExists(targetFolder, "Videos")
		my ensureFolderExists(targetFolder, "Images")
		my ensureFolderExists(targetFolder, "Documents")
		my ensureFolderExists(targetFolder, "Archives")
		my ensureFolderExists(targetFolder, "Other")
		
		set stepResult to my moveBatchCached(targetFolder, {"jpg", "jpeg", "png", "gif", "bmp", "svg", "ico", "webp", "tiff", "heic"}, "Images", processedCache)
		set movedCount to movedCount + (countMoved of stepResult)
		set processedCache to updatedCache of stepResult
		
		set stepResult to my moveBatchCached(targetFolder, {"pdf", "doc", "docx", "txt", "xlsx", "xls", "ppt", "pptx", "rtf", "odt", "pages", "numbers", "keynote"}, "Documents", processedCache)
		set movedCount to movedCount + (countMoved of stepResult)
		set processedCache to updatedCache of stepResult
		
		set stepResult to my moveBatchCached(targetFolder, {"zip", "dmg", "pkg", "rar", "7z", "tar", "gz"}, "Archives", processedCache)
		set movedCount to movedCount + (countMoved of stepResult)
		set processedCache to updatedCache of stepResult
		
		set stepResult to my moveBatchCached(targetFolder, {"mp4", "mov", "avi", "mkv", "flv", "wmv", "webm", "m4v"}, "Videos", processedCache)
		set movedCount to movedCount + (countMoved of stepResult)
		set processedCache to updatedCache of stepResult
		
		set stepResult to my moveBatchCached(targetFolder, {"mp3", "aac", "wav", "flac", "m4a", "opus", "alac", "ogg"}, "Music", processedCache)
		set movedCount to movedCount + (countMoved of stepResult)
		set processedCache to updatedCache of stepResult
		
		set stepResult to my moveOtherCached(targetFolder, "Other", processedCache)
		set movedCount to movedCount + (countMoved of stepResult)
		set processedCache to updatedCache of stepResult
	end tell
	
	my saveCache(processedCache)
	
	set elapsedSeconds to ((current date) - startTime)
	my appendLog("CACHE+BATCH finished | moved=" & movedCount & " | runtime=" & elapsedSeconds & "s")
	return {movedCount:movedCount, elapsedSeconds:elapsedSeconds}
end organizeBatchWithCache

on moveBatch(targetFolder, extList, destinationFolderName)
	tell application "Finder"
		set matchedFiles to {}
		repeat with oneExt in extList
			set matchedFiles to matchedFiles & (every file of targetFolder whose name extension is (contents of oneExt))
		end repeat
		
		if (count of matchedFiles) > 0 then
			set destinationFolderRef to my folderRefForName(targetFolder, destinationFolderName)
			move matchedFiles to destinationFolderRef with replacing
		end if
		
		return count of matchedFiles
	end tell
end moveBatch

on moveBatchCached(targetFolder, extList, destinationFolderName, processedCache)
	tell application "Finder"
		set matchedFiles to {}
		set filesToMove to {}
		set namesToCache to {}
		
		repeat with oneExt in extList
			set matchedFiles to matchedFiles & (every file of targetFolder whose name extension is (contents of oneExt))
		end repeat
		
		repeat with oneFile in matchedFiles
			set fileName to name of oneFile as text
			if my listContains(processedCache, fileName) is false then
				set end of filesToMove to oneFile
				set end of namesToCache to fileName
			end if
		end repeat
		
		if (count of filesToMove) > 0 then
			set destinationFolderRef to my folderRefForName(targetFolder, destinationFolderName)
			move filesToMove to destinationFolderRef with replacing
			repeat with cachedName in namesToCache
				set end of processedCache to (contents of cachedName)
			end repeat
			my appendLog("Cached batch moved " & (count of filesToMove) & " files -> " & destinationFolderName)
		end if
		
		return {countMoved:(count of filesToMove), updatedCache:processedCache}
	end tell
end moveBatchCached

on listContains(theList, targetText)
	repeat with x in theList
		if (contents of x) is targetText then return true
	end repeat
	return false
end listContains

on loadCache()
	set cachePath to (POSIX path of (path to library folder from user domain)) & "Preferences/OrganizerCache.txt"
	do shell script "mkdir -p " & quoted form of ((POSIX path of (path to library folder from user domain)) & "Preferences")
	do shell script "touch " & quoted form of cachePath
	
	set cacheText to do shell script "cat " & quoted form of cachePath
	if cacheText is "" then return {}
	return paragraphs of cacheText
end loadCache

on saveCache(cacheList)
	set cachePath to (POSIX path of (path to library folder from user domain)) & "Preferences/OrganizerCache.txt"
	set oldTIDs to AppleScript's text item delimiters
	set AppleScript's text item delimiters to linefeed
	set cacheText to cacheList as text
	set AppleScript's text item delimiters to oldTIDs
	
	do shell script "printf %s " & quoted form of cacheText & " > " & quoted form of cachePath
end saveCache
on moveOther(targetFolder, destinationFolderName)
	tell application "Finder"
		set knownExtensions to {"jpg", "jpeg", "png", "gif", "bmp", "svg", "ico", "webp", "tiff", "heic", "pdf", "doc", "docx", "txt", "xlsx", "xls", "ppt", "pptx", "rtf", "odt", "pages", "numbers", "keynote", "zip", "dmg", "pkg", "rar", "7z", "tar", "gz", "mp4", "mov", "avi", "mkv", "flv", "wmv", "webm", "m4v", "mp3", "aac", "wav", "flac", "m4a", "opus", "alac", "ogg"}
		set allFiles to every file of targetFolder
		set filesToMove to {}
		
		repeat with oneFile in allFiles
			set fileName to name of oneFile as text
			set fileExt to name extension of oneFile as text
			set isKnown to false
			
			repeat with knownExt in knownExtensions
				if fileExt is (contents of knownExt) then
					set isKnown to true
					exit repeat
				end if
			end repeat
			
			if isKnown is false and fileExt is not "" then
				set end of filesToMove to oneFile
			end if
		end repeat
		
		if (count of filesToMove) > 0 then
			set destinationFolderRef to my folderRefForName(targetFolder, destinationFolderName)
			move filesToMove to destinationFolderRef with replacing
			my appendLog("Moved " & (count of filesToMove) & " Other files -> " & destinationFolderName)
		end if
		
		return count of filesToMove
	end tell
end moveOther
on moveOtherCached(targetFolder, destinationFolderName, processedCache)
	tell application "Finder"
		set knownExtensions to {"jpg", "jpeg", "png", "gif", "bmp", "svg", "ico", "webp", "tiff", "heic", "pdf", "doc", "docx", "txt", "xlsx", "xls", "ppt", "pptx", "rtf", "odt", "pages", "numbers", "keynote", "zip", "dmg", "pkg", "rar", "7z", "tar", "gz", "mp4", "mov", "avi", "mkv", "flv", "wmv", "webm", "m4v", "mp3", "aac", "wav", "flac", "m4a", "opus", "alac", "ogg"}
		set allFiles to every file of targetFolder
		set filesToMove to {}
		set namesToCache to {}
		
		repeat with oneFile in allFiles
			set fileName to name of oneFile as text
			set fileExt to name extension of oneFile as text
			set isKnown to false
			
			repeat with knownExt in knownExtensions
				if fileExt is (contents of knownExt) then
					set isKnown to true
					exit repeat
				end if
			end repeat
			
			if isKnown is false and fileExt is not "" then
				if my listContains(processedCache, fileName) is false then
					set end of filesToMove to oneFile
					set end of namesToCache to fileName
				end if
			end if
		end repeat
		
		if (count of filesToMove) > 0 then
			set destinationFolderRef to my folderRefForName(targetFolder, destinationFolderName)
			move filesToMove to destinationFolderRef with replacing
			repeat with cachedName in namesToCache
				set end of processedCache to (contents of cachedName)
			end repeat
			my appendLog("Cached batch moved " & (count of filesToMove) & " Other files -> " & destinationFolderName)
		end if
		
		return {countMoved:(count of filesToMove), updatedCache:processedCache}
	end tell
end moveOtherCached





- implemented a new gui mode selector with 3 optimization modes
- added "other" folder for unrecognized file types
- created moveother() and moveothercached() handlers
- updated all 3 organizer modes to handle "other" files
- compiled both scripts (main + app)

this will be my final devlog and there will be no updates on this project on flavortownn....
thanks to all



flavortown, goodbye on april 30. this has been a bittersweet moment. thanks for hosting the optimization sidequest and pushing me to build something that works.

downloads folder organizer pro shipped with:

-  batch operations optimization (groups file moves)
- caching system (skips already-processed files)
- "other" folder handler (captures all unrecognized files)
- gui mode selector (baseline, batch, cached)
- logging and persistence
