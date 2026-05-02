<!-- GitAds-Verify: FBIAOUN75OFZB4WVVV26CZAKZAWVGRVE -->
## GitAds Sponsored
[![Sponsored by GitAds](https://gitads.dev/v1/ad-serve?source=munna-soft/youtube-live-streamer@github)](https://gitads.dev/v1/ad-track?source=munna-soft/youtube-live-streamer@github)

# 🎬 YouTube Live Streamer – Munna MasterMind

Stream any local video file to YouTube Live directly from your Windows PC without OBS or complex software. Automatically loops smaller videos, supports multiple resolutions, and auto‑downloads all needed dependencies.

![Made with love by Munna MasterMind](https://img.shields.io/badge/Made%20with-%E2%9D%A4%20by%20Munna%20MasterMind-red)
![Platform](https://img.shields.io/badge/Platform-Windows%2010%2F11-blue)

## ✨ Features

- **One‑click dependency setup** – downloads `ffmpeg`, `ffprobe` & `ffplay` automatically.
- **OBS‑like streaming** – no external tools, just a batch file + YouTube stream key.
- **Unlimited or timed streams** – run forever or specify exact duration (HH:MM or minutes).
- **Resolution scaling** – keep original size or convert to 720p / 1080p / 2K / 4K with proper padding.
- **Automatic looping** – smaller videos loop seamlessly without any manual editing.
- **Adaptive bitrate** – ideal settings chosen based on your selected resolution.
- **Lightweight & portable** – just a few MB after setup.

## 📦 Requirements

- **Windows 10 / 11** (64‑bit recommended)
- **YouTube channel** with live streaming enabled (obtain a **stream key** from YouTube Studio)
- **Internet connection** (for dependency download & streaming)

> **All other tools are automatically installed by the script.**  
> You don't need to manually install FFmpeg or anything else.

## 🚀 Quick Start

1. **Download the script** (`YouTube_Live_Streamer.bat`) and place it in an empty folder.
2. **Put your video file** inside the `input_video` folder (created automatically on first run).  
   Supported formats: `.mp4`, `.mov`, `.mkv`, `.webm`, `.avi`.
3. **Run the batch file** and choose option `1` to install FFmpeg.
4. After installation, select `2` → **Start Live Stream**.
5. Follow the interactive prompts:
   - Choose your video
   - Paste your **YouTube Stream Key**
   - Select duration (`0` = unlimited, `1` = manual input)
   - Choose resolution
6. The stream starts immediately – press `Ctrl+C` to stop an unlimited stream.

## 📘 Detailed Usage

### Step 1 – Setup Dependencies (only once)
The script downloads the latest **FFmpeg** build and extracts it into a `FFmpeg` folder next to the script.

### Step 2 – Start Streaming
- **Video selection** – all compatible videos from `input_video` are listed.
- **Stream Key** – obtain it from [YouTube Studio → Go Live](https://studio.youtube.com/channel/UC/livestreaming).
- **Duration**  
  `0` = stream until you manually stop it.  
  `1` = enter a time (e.g. `5` for 5 minutes, `1:30` for 1h30m, `24:00` for 24 hours).
- **Resolution**  
  `1` keeps the original video size (bitrate auto‑adjusted).  
  `2–5` scale and pad the video to standard dimensions.

The script then prepares a short, optimised version of your video and sends it to YouTube in a loop.

## ⚙️ How It Works (Technical)

1. **Dependency check** – ensures `ffmpeg.exe` and `ffprobe.exe` are present.
2. **Pre‑processing** – a short merged clip is created with the selected resolution using `libx264` (ultrafast preset).  
   If the video has no audio, a silent audio track is not added.
3. **Streaming loop** – the pre‑processed clip is fed to FFmpeg with:
   - `-stream_loop -1` → infinite looping
   - `-re` → real‑time reading
   - `-c:v libx264 -preset veryfast` → fast, quality encoding
   - Adaptive video bitrate / maxrate / bufsize
   - AAC audio @ 128kbps
   - FLV container sent to `rtmp://a.rtmp.youtube.com/live2/`
4. If a duration is set, `-t HH:MM:SS` is added; otherwise stream runs until interrupted.

## 🎛️ Bitrate Table (Automatic)

| Resolution      | Video Bitrate | Max Bitrate | Buffer Size |
|-----------------|---------------|-------------|-------------|
| ≤ 720p          | 2500 kbps     | 2500 kbps   | 5000 kbps   |
| 720p – 1080p    | 4500 kbps     | 4500 kbps   | 9000 kbps   |
| 1080p – 1440p   | 8000 kbps     | 8000 kbps   | 16000 kbps  |
| > 1440p (4K)    | 15000 kbps    | 15000 kbps  | 30000 kbps  |

You can tweak these values inside the script in the resolution selection block.

## ❓ Troubleshooting

| Problem | Solution |
|--------|----------|
| `ffmpeg.exe not found` | Run **option 1** to download FFmpeg. |
| No videos in `input_video` | Place a supported video file in the `input_video` folder. |
| `Connection refused` / `RTMP` error | Check your stream key; ensure you are using the correct server URL (`live2`). |
| Stream lags or stutters | Reduce resolution (choose 720p) or lower the bitrate manually. |
| "Invalid choice" after resolution selection | Make sure you are using the **latest version** of the script from this repository. |

## 👨‍💻 Credits

- **Author**: [Munns MasterMind](https://facebook.com/The.Munna)  
- **GitHub**: [Munna-Soft](https://github.com/Munna-Soft)
- **Portfolio**: [Portfolio](https://munna-soft.github.io/Portfolio)

<code> If this project helps you, please ⭐ **star the repository** — it keeps me motivated 💙 </code>

### Built With
- [FFmpeg](https://ffmpeg.org/) – video & audio powerhouse
- Batch scripting – pure Windows magic

## 📄 License

This project is open source and provided **as‑is** for personal use.  
Feel free to modify, share, and improve. Credit to the original author is appreciated.

**🎥 Happy streaming!**

<!-- GitAds-Verify: FBIAOUN75OFZB4WVVV26CZAKZAWVGRVE -->
## GitAds Sponsored
[![Sponsored by GitAds](https://gitads.dev/v1/ad-serve?source=munna-soft/youtube-live-streamer@github)](https://gitads.dev/v1/ad-track?source=munna-soft/youtube-live-streamer@github)