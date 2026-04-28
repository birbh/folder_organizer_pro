# Downloads Folder Organizer Pro

> macOS only: this project uses AppleScript and Finder automation, so it is designed to run only on Mac.

Automatically organizes files in your Downloads folder into:
- Images: `jpg`, `jpeg`, `png`, `gif`, `bmp`, `svg`, `ico`, `webp`, `tiff`, `heic`
- Documents: `pdf`, `doc`, `docx`, `txt`, `xlsx`, `xls`, `ppt`, `pptx`, `rtf`, `odt`, `pages`, `numbers`, `keynote`
- Archives: `zip`, `dmg`, `pkg`, `rar`, `7z`, `tar`, `gz`
- Videos: `mp4`, `mov`, `avi`, `mkv`, `flv`, `wmv`, `webm`, `m4v`
- Music: `mp3`, `wav`, `aac`, `flac`, `m4a`, `opus`, `alac`, `ogg`
- Other: Any files that don't match the above categories

Also includes:
- Log file: `~/Desktop/OrganizerLog.txt`
- Cache file: `~/Library/Preferences/OrganizerCache.txt`

## About the App

**DownloadsFolderOrganizerPro.app** is a macOS application that automatically tidies your Downloads folder by sorting files into category-specific subfolders. Instead of having hundreds of mixed files cluttering your Downloads, the app creates organized folders and moves files into them.

### What it does:
- Scans your Downloads folder for files
- Creates category folders (Images, Documents, Archives, Videos, Music, Other) if they don't exist
- Moves files into the appropriate category folder based on file type
- Files with unrecognized extensions are moved to the "Other" folder
- Logs all actions so you know what was organized
- Caches processed files to avoid redundant moves on future runs

### Other Files Handler
The "Other" category captures any file with an unrecognized or non-standard file extension that doesn't match the predefined categories. Two specialized handlers manage these files:

- `moveOther()`: Used in batch mode without caching. Scans all files, identifies those with unknown extensions, and moves them to the "Other" folder.
- `moveOtherCached()`: Used in cache mode. Same behavior as moveOther, but also maintains cache entries for "Other" files to prevent re-processing on subsequent runs. Files already in cache are skipped automatically.

This ensures no files are left behind in Downloads, regardless of their file type or how obscure the extension.

### When to use it:
- Your Downloads folder is getting messy and hard to navigate
- You want a hands-off way to auto-organize files as they download
- You need to clean up an existing Downloads folder (run once, or keep it open)

### How to use it:
1. One-time cleanup: Open the app, let it run, and close it when done
2. Ongoing auto-organization: Open the app and leave it running—it automatically organizes every 5 minutes
3. Check results: Open `~/Desktop/OrganizerLog.txt` to see what files were moved and where

### Support & Customization:
If you want to modify file types or category names, edit `OrganizerBaseline.scpt` in Script Editor before running the app.

## important:::
## Quick Start

1. Open `DownloadsFolderOrganizerPro.app`.
2. The app runs and organizes your Downloads folder.
3. Keep it open if you want auto-runs every 5 minutes (stay-open mode).
4. Check `~/Desktop/OrganizerLog.txt` to see what was moved.

## If macOS says the app is "damaged" or won't open
Because this is a shared AppleScript app bundle and may not be notarized, macOS Gatekeeper can block it on other devices.

### 1) Remove quarantine flags (recommended first)

Run this in Terminal (replace the path with your real app path):

```bash
xattr -cr "/path/to/DownloadsFolderOrganizerPro.app"
```

eg:

```bash
xattr -cr "$HOME/Downloads/DownloadsFolderOrganizerPro.app"
```

Then try opening the app again.

### 2) Use Open Anyway if still blocked

1. Go to `System Settings` -> `Privacy & Security`.
2. In the Security section, find the blocked app message.
3. Click `Open Anyway`, then confirm.

### 3) One-time bypass from Finder

1. Right-click `DownloadsFolderOrganizerPro.app`.
2. Click `Open`.
3. Click `Open` again in the warning dialog.

### 4) Final fallback: run the script directly

If the app still fails to open, use Script Editor directly:

1. Open `OrganizerBaseline.scpt` in Script Editor.
2. Click the `Run` button.
3. Grant Finder/Desktop/Downloads permissions if prompted.

This runs the organizer logic even if the `.app` wrapper is blocked.

If needed, re-download or re-copy the `.app` bundle and run `xattr -cr` again.

## Demo




https://github.com/user-attachments/assets/7eeba8bf-f70d-458d-bd5f-1eb305d0dd08





## Developer/Test Modes

If you open `OrganizerBaseline.scpt`, there are three modes:
- `organizeBaseline`: slow baseline (file-by-file loop), includes Other files via destinationForFile
- `organizeBatchNoCache`: optimized batch moves, processes Other files via moveOther handler
- `organizeBatchWithCache`: batch + cache (default mode), processes Other files via moveOtherCached handler

Note: In all modes, the "Other" category captures any files with unrecognized extensions. In cache mode, Other files are tracked and skipped on future runs.

## Optimization Summary

### Optimization 1: Batch Apple Events
- Before: move files one by one inside a repeat loop.
- After: move grouped file lists per category.

### Optimization 2: Caching
- Before: every run re-processes the same files, including unrecognized file types.
- After: previously processed filenames (including Other files) are skipped using cache on subsequent runs.

## Results (Example)

| Mode | Runtime | Finder/Event Behavior | Memory (RSS) |
|---|---:|---|---:|
| Baseline (loop, no cache) | 8.4s | many per-file operations | 39 MB |
| Batch only | 3.1s | fewer grouped operations | 31 MB |
| Batch + cache (second run) | 0.9s | near-zero move operations | 24 MB |


## Performance Measurement (For Sidequest Evidence)

### 1) Runtime
Run each mode on the same test data set and record the time from dialog/log:
- `organizeBaseline`
- `organizeBatchNoCache`
- `organizeBatchWithCache` (run twice; record second run)

### 2) Apple Events Activity
Use Script Editor event log, or monitor Finder activity:

```bash
log stream --style compact --predicate 'process == "Finder"'
```

### 3) Memory Usage

```bash
ps -axo pid,comm,rss | grep -i "DownloadsFolderOrganizerPro\|OrganizerBaseline\|osascript"
```

`rss` is in KB. Divide by 1024 to get MB.

## Stay-Open Packaging 

1. Open `OrganizerBaseline.scpt` in Script Editor.
2. Click File -> Export.
3. Set File Format to `Application`.
4. Enable `Stay open after run handler`.
5. Save as `DownloadsFolderOrganizerPro.app`.

## Optional: Sign before sharing (maintainer)

If you distribute the app to other Macs, signing helps reduce launch warnings.

```bash
codesign --force --deep --sign - "/path/to/DownloadsFolderOrganizerPro.app"
```

Notes:
- `--sign -` uses ad-hoc signing (no paid certificate required).
- For best trust on external machines, use a Developer ID certificate and notarization.



Reference and credits: [Applescript examples](https://github.com/unforswearing/applescript)


