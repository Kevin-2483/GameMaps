# HTML渲染测试文档

这是一个测试文档，用于验证VFS Markdown渲染器的HTML渲染功能。

## 基础HTML标签测试

### 文本格式化
- <b>粗体文本</b>
- <i>斜体文本</i>
- <u>下划线文本</u>
- <s>删除线文本</s>
- <mark>高亮文本</mark>
- <small>小号文本</small>
- <sub>下标</sub>和<sup>上标</sup>

### 段落和分割
<p>这是一个HTML段落标签。</p>

<div>这是一个div容器标签。</div>

<hr>

### 链接测试
<a href="https://flutter.dev">Flutter官网</a>

<a href="indexeddb://testdb/testcollection/test.md">VFS内部链接测试</a>

### 列表测试
<ul>
  <li>无序列表项1</li>
  <li>无序列表项2
    <ul>
      <li>嵌套项1</li>
      <li>嵌套项2</li>
    </ul>
  </li>
  <li>无序列表项3</li>
</ul>

<ol>
  <li>有序列表项1</li>
  <li>有序列表项2</li>
  <li>有序列表项3</li>
</ol>

### 表格测试
<table border="1">
  <thead>
    <tr>
      <th>姓名</th>
      <th>年龄</th>
      <th>城市</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>张三</td>
      <td>25</td>
      <td>北京</td>
    </tr>
    <tr>
      <td>李四</td>
      <td>30</td>
      <td>上海</td>
    </tr>
  </tbody>
</table>

### 引用块
<blockquote>
这是一个HTML引用块。可以包含多行文本和其他HTML元素。
</blockquote>

### 代码块
<pre><code>
function hello() {
    console.log("Hello, World!");
}
</code></pre>

行内代码：<code>const x = 42;</code>

### 详情折叠
<details>
  <summary>点击展开详情</summary>
  <p>这是隐藏的详细内容。</p>
  <ul>
    <li>详情项1</li>
    <li>详情项2</li>
  </ul>
</details>

### 图片测试
<img src="https://flutter.dev/assets/images/shared/brand/flutter/logo/flutter-lockup.png" alt="Flutter Logo" width="200">

### 混合内容测试
<div style="border: 1px solid #ccc; padding: 10px; margin: 10px 0;">
  <h4>混合HTML和Markdown</h4>
  <p>这个div包含了：</p>
  
  **Markdown粗体** 和 <b>HTML粗体</b>
  
  - Markdown列表项
  - <li>HTML列表项</li>
  
  <a href="#top">HTML链接</a> 和 [Markdown链接](https://dart.dev)
</div>

## 特殊字符和实体测试
- &lt; 小于号
- &gt; 大于号  
- &amp; 和号
- &quot; 引号
- &#8364; 欧元符号

## 嵌套标签测试
<div>
  <p>外层段落 <span>内层span <b>粗体嵌套 <i>斜体嵌套</i></b></span> 结束</p>
</div>

---

**说明：**
- 启用HTML渲染时，上述HTML标签应该正确显示
- 禁用HTML渲染时，HTML标签会显示为纯文本
- 可以通过工具栏的HTML按钮切换渲染模式
- 状态栏会显示HTML内容的统计信息
