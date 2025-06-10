# 视频测试文档

这是一个测试视频支持的 Markdown 文档。

## HTML 视频标签

<video src="https://www.w3schools.com/html/mov_bbb.mp4" controls width="400">
  您的浏览器不支持视频标签。
</video>

## Markdown 风格视频引用

![视频描述](https://www.w3schools.com/html/mov_bbb.mp4)

这是一个 .mp4 视频文件的引用。

## 本地视频（VFS协议）

![本地视频](indexeddb://test/videos/sample.mp4)

## 其他格式的视频

<video controls>
  <source src="https://www.w3schools.com/html/movie.mp4" type="video/mp4">
  <source src="https://www.w3schools.com/html/movie.ogg" type="video/ogg">
  您的浏览器不支持视频标签。
</video>

## 混合内容

这是一些文本内容，包含：

- 普通图片：![图片](https://via.placeholder.com/300x200)
- 视频文件：![视频](https://sample-videos.com/zip/10/mp4/SampleVideo_720x480_1mb.mp4)
- 更多文本内容

## 特殊情况

空的视频标签：
<video></video>

无效的视频引用：
![无效视频](not-a-video.txt)

## 总结

这个文档包含多种视频内容类型：
1. HTML video 标签（2个）
2. Markdown 图片语法引用的视频文件（3个）
3. 普通图片（1个）

总共应该检测到5个视频。
