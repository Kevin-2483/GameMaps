# Worker内部函数功能文档

## 概述

为了提升脚本执行性能，我们将一些常用函数从跨线程调用改为Worker内部直接执行。这样可以避免不必要的消息传递开销，特别是对于数学函数和延迟操作。

## 新增的内部函数

### 数学函数（无跨线程开销）

以下数学函数现在在Worker线程内部直接执行，不需要与主线程通信：

```hetu
// 基础数学函数
external fun sin    // sin(x) - 正弦函数
external fun cos    // cos(x) - 余弦函数  
external fun tan    // tan(x) - 正切函数
external fun sqrt   // sqrt(x) - 平方根
external fun pow    // pow(x, y) - 幂运算
external fun abs    // abs(x) - 绝对值
external fun random // random() - 随机数 0-1

// 比较函数
external fun min    // min(a, b) - 最小值
external fun max    // max(a, b) - 最大值

// 取整函数
external fun floor  // floor(x) - 向下取整
external fun ceil   // ceil(x) - 向上取整
external fun round  // round(x) - 四舍五入
```

### 延迟函数（新增）

```hetu
// 基础延迟函数
external fun delay      // delay(milliseconds) - 延迟指定毫秒，返回null
external fun delayThen  // delayThen(milliseconds, value) - 延迟后返回指定值
```

### 工具函数

```hetu
external fun now     // now() - 获取当前时间戳
external fun typeof  // typeof(value) - 获取值的类型字符串
```

## 使用示例

### 数学计算示例

```hetu
external fun log
external fun sin
external fun cos
external fun pow
external fun random
external fun min
external fun max

log('=== 数学函数测试 ===')

// 三角函数
var angle = 1.5708  // π/2
var sinResult = sin(angle)
var cosResult = cos(angle)

log('sin(π/2) = ${sinResult}')  // 接近 1
log('cos(π/2) = ${cosResult}')  // 接近 0

// 幂运算
var power = pow(2, 3)
log('2^3 = ${power}')  // 8

// 随机数和比较
var rand1 = random()
var rand2 = random()
var minVal = min(rand1, rand2)
var maxVal = max(rand1, rand2)

log('随机数1: ${rand1}')
log('随机数2: ${rand2}')
log('最小值: ${minVal}')
log('最大值: ${maxVal}')
```

### 延迟函数示例

```hetu
external fun log
external fun delay
external fun delayThen
external fun now

log('=== 延迟函数测试 ===')

var startTime = now()
log('开始时间: ${startTime}')

// 基础延迟
log('延迟1秒...')
delay(1000)

var midTime = now()
log('延迟后时间: ${midTime}, 实际延迟: ${midTime - startTime}ms')

// 带返回值的延迟
log('延迟500ms并返回值...')
var result = delayThen(500, 'Hello after delay!')
log('延迟结果: ${result}')

var endTime = now()
log('结束时间: ${endTime}, 总用时: ${endTime - startTime}ms')
```

### 类型检查示例

```hetu
external fun log
external fun typeof

log('=== 类型检查测试 ===')

var str = 'Hello'
var num = 42
var decimal = 3.14
var bool = true
var arr = [1, 2, 3]
var obj = {'key': 'value'}

log('字符串类型: ${typeof(str)}')      // string
log('整数类型: ${typeof(num)}')        // int
log('小数类型: ${typeof(decimal)}')    // double
log('布尔类型: ${typeof(bool)}')       // boolean
log('数组类型: ${typeof(arr)}')        // array
log('对象类型: ${typeof(obj)}')        // object
log('null类型: ${typeof(null)}')       // null
```

## 性能优势

### 之前（跨线程调用）
1. Worker线程发送函数调用消息到主线程
2. 主线程处理数学计算
3. 主线程发送结果回Worker线程
4. Worker线程接收结果并继续执行

**每次调用约需要几毫秒的消息传递开销**

### 现在（内部函数）
1. Worker线程直接执行数学计算
2. 立即得到结果并继续执行

**每次调用仅需微秒级别的执行时间**

## 日志输出

内部函数的执行会产生详细的日志：

```
[Worker] Available internal functions: [sin, cos, tan, sqrt, pow, abs, random, min, max, floor, ceil, round, delay, delayThen, now, typeof]
[Worker] 调用内部函数: sin, 参数: [1.5708]
[Worker] 内部函数 sin 执行完成，用时 0ms
[Worker] 调用内部函数: delay, 参数: [1000]
[Worker] 内部函数 delay 执行完成，用时 1002ms
```

## 注意事项

1. **延迟函数是异步的**：使用`delay`和`delayThen`时，脚本会暂停执行指定的时间
2. **参数验证**：延迟函数会自动将负数参数设置为0
3. **类型安全**：数学函数会自动进行类型转换
4. **性能优化**：内部函数避免了跨线程通信开销，特别适合密集计算场景

## 兼容性

这些内部函数与现有的外部函数系统完全兼容：
- 如果函数名匹配内部函数，优先使用内部实现
- 如果函数名不匹配，则使用传统的跨线程调用
- 现有脚本无需修改即可享受性能提升
