# LaTeX 数学公式测试文档

这是一个测试 LaTeX 数学公式渲染的 Markdown 文档。

## 行内公式

这里有一些行内公式：
- 著名的质能方程：$E = mc^2$
- 勾股定理：$a^2 + b^2 = c^2$
- 欧拉公式：$e^{i\pi} + 1 = 0$
- 二次方程的解：$x = \frac{-b \pm \sqrt{b^2 - 4ac}}{2a}$

## 块级公式

下面是一些块级公式：

### 积分公式
$$\int_{-\infty}^{\infty} e^{-x^2} dx = \sqrt{\pi}$$

### 矩阵
$$\begin{pmatrix}
a & b \\
c & d
\end{pmatrix}$$

### 求和公式
$$\sum_{n=1}^{\infty} \frac{1}{n^2} = \frac{\pi^2}{6}$$

### 分数和根号
$$\frac{1}{\sqrt{2\pi\sigma^2}} e^{-\frac{(x-\mu)^2}{2\sigma^2}}$$

### 极限
$$\lim_{x \to \infty} \left(1 + \frac{1}{x}\right)^x = e$$

## 复杂公式

### 薛定谔方程
$$i\hbar\frac{\partial}{\partial t}\Psi(\mathbf{r},t) = \hat{H}\Psi(\mathbf{r},t)$$

### 麦克斯韦方程组
$$\nabla \cdot \mathbf{E} = \frac{\rho}{\epsilon_0}$$
$$\nabla \cdot \mathbf{B} = 0$$
$$\nabla \times \mathbf{E} = -\frac{\partial \mathbf{B}}{\partial t}$$
$$\nabla \times \mathbf{B} = \mu_0\mathbf{J} + \mu_0\epsilon_0\frac{\partial \mathbf{E}}{\partial t}$$

## 混合内容

这段文字包含行内公式 $\alpha + \beta = \gamma$ 和一些**粗体**文本，以及*斜体*文本。

下面是一个块级公式：

$$f(x) = \begin{cases}
x^2 & \text{if } x \geq 0 \\
-x^2 & \text{if } x < 0
\end{cases}$$

## 特殊符号

希腊字母：$\alpha, \beta, \gamma, \delta, \epsilon, \zeta, \eta, \theta, \iota, \kappa, \lambda, \mu, \nu, \xi, \pi, \rho, \sigma, \tau, \upsilon, \phi, \chi, \psi, \omega$

运算符：$\pm, \mp, \times, \div, \cdot, \ast, \star, \circ, \bullet$

关系符：$<, >, \leq, \geq, \neq, \approx, \equiv, \sim, \simeq, \cong$

箭头：$\leftarrow, \rightarrow, \leftrightarrow, \Leftarrow, \Rightarrow, \Leftrightarrow$

## 测试结束

这个文档应该能够测试 LaTeX 渲染功能的各个方面。如果 LaTeX 渲染正常工作，所有的数学公式都应该被正确渲染。
