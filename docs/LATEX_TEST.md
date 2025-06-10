# LaTeX 渲染测试文档

这个文档用于测试 VFS Markdown 渲染器中的 LaTeX 数学公式渲染功能。

## 行内数学公式

这是一个简单的行内公式：$x = \frac{-b \pm \sqrt{b^2 - 4ac}}{2a}$

另一个行内公式：$E = mc^2$

## 块级数学公式

下面是一个复杂的积分公式：

$$\int_{-\infty}^{\infty} e^{-x^2} dx = \sqrt{\pi}$$

矩阵示例：

$$\begin{pmatrix}
a & b \\
c & d
\end{pmatrix}$$

## 复杂公式

泰勒级数展开：

$$f(x) = f(a) + f'(a)(x-a) + \frac{f''(a)}{2!}(x-a)^2 + \frac{f'''(a)}{3!}(x-a)^3 + \ldots$$

求和公式：

$$\sum_{n=1}^{\infty} \frac{1}{n^2} = \frac{\pi^2}{6}$$

## 混合内容

在普通文本中，我们可以使用行内公式 $\alpha + \beta = \gamma$ 来展示数学关系。

然后展示一个重要的定理：

$$\lim_{n \to \infty} \left(1 + \frac{1}{n}\right)^n = e$$

## 希腊字母和符号

常用的希腊字母：$\alpha, \beta, \gamma, \delta, \epsilon, \zeta, \eta, \theta$

数学符号：$\leq, \geq, \neq, \approx, \infty, \partial, \nabla$

## 分数和根式

分数：$\frac{a}{b}, \frac{x^2 + y^2}{z^2}$

根式：$\sqrt{2}, \sqrt[3]{8}, \sqrt[n]{x}$

## 上标和下标

上标：$x^2, e^{i\pi}, 2^{n+1}$

下标：$x_1, a_{i,j}, \sum_{i=1}^{n}$

组合：$x_1^2 + x_2^2 = r^2$
