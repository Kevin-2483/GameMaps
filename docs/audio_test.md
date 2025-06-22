# 音频播放器测试文档

## 基本音频嵌入

这是一个简单的音频文件：

![音频示例](demo.mp3)

## 带参数的音频嵌入

这是一个带有标题和艺术家信息的音频：

![title:我的音乐,artist:音乐家,album:专辑名称](music.mp3)

## 自动播放音频

这个音频会自动播放：

![autoplay](autoplay_demo.mp3)

## 循环播放音频

这个音频会循环播放：

![loop](loop_demo.mp3)

## HTML音频标签

你也可以使用HTML音频标签：

<audio src="example.mp3" controls title="HTML音频" artist="HTML艺术家"></audio>

<audio src="auto_example.wav" controls autoplay title="自动播放音频"></audio>

## 多种音频格式支持

- MP3: ![MP3音频](demo.mp3)
- WAV: ![WAV音频](demo.wav) 
- OGG: ![OGG音频](demo.ogg)
- AAC: ![AAC音频](demo.aac)
- M4A: ![M4A音频](demo.m4a)
- FLAC: ![FLAC音频](demo.flac)

## 网络音频

从网络加载的音频：

![网络音频](https://example.com/audio.mp3)

## VFS音频

从虚拟文件系统加载的音频：

![VFS音频](indexeddb://demo/audio/sample.mp3)
