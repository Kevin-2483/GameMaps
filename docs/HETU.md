# Hetu脚本语言语法特征和注意事项

## 简介

Hetu是一个专为Flutter打造的轻量型嵌入式脚本语言，用纯Dart编写。它的设计目标是为Flutter应用提供动态化能力，包括热更新、脚本框架等功能。

## 语法特征

### 1. 基本语法风格

- **现代语言风格**：语法类似TypeScript/Kotlin/Swift
- **句末分号可选**：支持自动分号插入
- **类型注解**：类似TypeScript，写在变量名后面（目前主要用于注解，运行时仍为动态类型）

```hetu
var name = 'John'  // 分号可选
var age: int = 25  // 类型注解
```

### 2. 变量声明

```hetu
var name = 'value'          // 可变变量
final count = 42            // 不可变变量
const PI = 3.14159          // 编译时常量
late var delayed            // 延迟初始化
```

**关键字说明：**
- `var`：声明可变变量
- `final`：声明不可变变量（运行时确定值）
- `const`：声明编译时常量
- `late`：延迟初始化，在首次使用时才初始化

### 3. 函数定义

**⚠️ 重要**：函数定义必须使用关键字前缀：`fun`、`get`、`set`、`construct`

```hetu
// 基本函数
fun greeting(name: str) -> str {
    return 'Hello, ${name}!'
}

// 单行函数（箭头函数）
fun square(x) => x * x

// 带默认参数
fun greet(name: str = 'World') -> str {
    return 'Hello, ${name}!'
}

// 可变参数
fun sum(...numbers) {
    var total = 0
    for (var num in numbers) {
        total += num
    }
    return total
}

// getter/setter
get fullName => '${firstName} ${lastName}'
set fullName(value) {
    var parts = value.split(' ')
    firstName = parts[0]
    lastName = parts[1]
}
```

### 4. 数据结构

#### 对象字面量
```hetu
var person = {
    name: 'John',
    age: 30,
    greeting: () {
        print('Hello, I am ${this.name}!')
    }
}

// 访问属性
print(person.name)
person.greeting()
```

#### 列表
```hetu
var numbers = [1, 2, 3, 4, 5]
var mixed = [1, 'hello', true, null]

// 列表操作
numbers.add(6)
print(numbers.length)
print(numbers[0])  // 索引访问
```

#### 映射（Map）
```hetu
var colors = {
    'red': '#FF0000',
    'green': '#00FF00',
    'blue': '#0000FF'
}

print(colors['red'])
colors['yellow'] = '#FFFF00'
```

#### 字符串插值
```hetu
var name = 'World'
var message = 'Hello, ${name}!'
var complex = 'Next number is ${i + 1}'
var multiline = '''
This is a
multiline string
with ${variable} interpolation
'''
```

### 5. 控制流

#### 条件语句
```hetu
// if-else
if (condition) {
    // code
} else if (anotherCondition) {
    // code
} else {
    // code
}

// 三元操作符
var result = condition ? 'true value' : 'false value'
```

#### when语句（类似switch）
```hetu
when (value) {
    1 -> print('One')
    2 -> print('Two')
    3, 4, 5 -> print('Three to Five')  // 多个值
    else -> print('Other')
}

// 可以返回值
var result = when (grade) {
    'A' -> 'Excellent'
    'B' -> 'Good'
    'C' -> 'Average'
    else -> 'Need Improvement'
}
```

#### 循环
```hetu
// for循环
for (var i = 0; i < 10; ++i) {
    print(i)
}

// for-in循环
for (var item in list) {
    print(item)
}

// while循环
while (condition) {
    // code
    if (breakCondition) break
    if (skipCondition) continue
}

// do-while循环
do {
    // code
} while (condition)

// 无限循环
for (;;) {
    // code
    if (exitCondition) break
}
```

### 6. 面向对象编程

#### 类定义
```hetu
class Person {
    var name: str
    var age: int
    static var species = 'Homo sapiens'
    
    // 构造函数
    construct(name: str, age: int) {
        this.name = name
        this.age = age
    }
    
    // 命名构造函数
    construct withName(name: str) {
        this.name = name
        this.age = 0
    }
    
    // 实例方法
    fun greeting() {
        print('Hello, I am ${this.name}')
    }
    
    // 静态方法
    static fun getSpecies() -> str {
        return species
    }
    
    // getter和setter
    get isAdult => age >= 18
    set displayName(value) {
        name = value
    }
}

// 使用类
var person = Person('John', 25)
var namedPerson = Person.withName('Jane')
person.greeting()
print(Person.getSpecies())
```

#### 继承
```hetu
class Student extends Person {
    var grade: str
    var school: str
    
    construct(name: str, age: int, grade: str, school: str) {
        super(name, age)  // 调用父类构造函数
        this.grade = grade
        this.school = school
    }
    
    // 重写方法
    override fun greeting() {
        print('Hi, I am ${this.name}, grade ${this.grade} at ${this.school}')
    }
    
    // 新方法
    fun study(subject: str) {
        print('${this.name} is studying ${subject}')
    }
}
```

#### 抽象类和接口
```hetu
abstract class Animal {
    var name: str
    
    construct(name: str) {
        this.name = name
    }
    
    // 抽象方法
    abstract fun makeSound()
    
    // 具体方法
    fun sleep() {
        print('${name} is sleeping')
    }
}

class Dog extends Animal {
    construct(name: str) {
        super(name)
    }
    
    override fun makeSound() {
        print('${name} says: Woof!')
    }
}
```

### 7. 原型链编程
```hetu
// 类似JavaScript的原型链
var animalPrototype = {
    makeSound: fun() {
        print('${this.name} makes a sound')
    },
    
    sleep: fun() {
        print('${this.name} is sleeping')
    }
}

var dog = {
    name: 'Buddy',
    breed: 'Golden Retriever'
}

// 设置原型
dog.prototype = animalPrototype
dog.makeSound()  // 调用原型方法
```

### 8. 结构体（Struct）
```hetu
struct Point {
    var x: float
    var y: float
    
    fun distance(other: Point) -> float {
        var dx = this.x - other.x
        var dy = this.y - other.y
        return Math.sqrt(dx * dx + dy * dy)
    }
}

var p1 = Point(x: 0, y: 0)
var p2 = Point(x: 3, y: 4)
print(p1.distance(p2))  // 输出: 5.0
```

### 9. 外部绑定

#### 外部函数
```hetu
// 外部函数声明
external fun dartFunction
external fun httpGet
external fun showDialog

// 使用外部函数
var result = dartFunction('parameter')
var response = httpGet('https://api.example.com')
showDialog('Hello from Hetu!')
```

#### 外部类
```hetu
// 外部类声明  
external class DartClass
external class HttpClient
external class DateTime

// 使用外部类
var client = HttpClient()
var now = DateTime.now()
```

### 10. 模块系统

#### 导入和导出
```hetu
// 导出（在模块文件中）
export var publicVar = 'value'
export const PUBLIC_CONSTANT = 42

export fun publicFunction() {
    return 'Hello from module'
}

export class PublicClass {
    var value: str
    construct(value: str) {
        this.value = value
    }
}

// 导入（在使用文件中）
import 'path/to/module.ht'
import * from 'utils.ht'
import { symbol1, symbol2 } from 'module.ht'
import { longSymbolName as shortName } from 'module.ht'
```

### 11. 错误处理

```hetu
// try-catch-finally
try {
    // 可能出错的代码
    var result = riskyOperation()
    return result
} catch (error) {
    // 错误处理
    print('Error occurred: ${error}')
    return null
} finally {
    // 清理代码（总是执行）
    cleanup()
}

// 抛出异常
fun validate(value) {
    if (value == null) {
        throw 'Value cannot be null'
    }
    if (value < 0) {
        throw Error('Value must be positive')
    }
}

// 断言
assert(value > 0, 'Value must be positive')
```

### 12. 高级特性

#### 泛型（有限支持）
```hetu
// 类型参数
fun identity<T>(value: T) -> T {
    return value
}

// 使用
var number = identity<int>(42)
var text = identity<str>('hello')
```

#### 操作符重载
```hetu
class Vector {
    var x: float
    var y: float
    
    construct(x: float, y: float) {
        this.x = x
        this.y = y
    }
    
    // 操作符重载
    fun +(other: Vector) -> Vector {
        return Vector(this.x + other.x, this.y + other.y)
    }
    
    fun toString() -> str {
        return 'Vector(${x}, ${y})'
    }
}

var v1 = Vector(1, 2)
var v2 = Vector(3, 4)
var sum = v1 + v2  // 使用重载的+操作符
```

## 注意事项

### 1. 语法约定

- ✅ **函数定义必须使用关键字**：`fun`、`get`、`set`、`construct`
- ✅ **分号可选**：支持自动分号插入，但建议保持一致性
- ✅ **类型注解是可选的**：主要用于文档和IDE提示
- ⚠️ **大小写敏感**：变量名和函数名区分大小写

### 2. 类型系统

- ⚠️ **动态类型**：尽管有类型注解，运行时仍为动态类型
- ⚠️ **类型检查**：静态类型检查功能尚未完全实现
- ⚠️ **null安全**：支持`?`操作符但不如Dart严格
- ⚠️ **类型转换**：需要注意隐式类型转换可能导致的问题

```hetu
// 类型相关的注意事项
var number: int = '123'  // 运行时可能出错
var nullable: str? = null
print(nullable?.length)  // 安全访问

// 类型检查
if (value is str) {
    print(value.length)
}
```

### 3. 异步编程限制

- ❌ **不支持await**：虽然定义了关键字但未实现
- ❌ **不支持async函数**：相关代码被注释
- ✅ **支持Future.then()**：可以处理异步操作

```hetu
// 正确的异步处理方式
external fun fetchData

fetchData().then((result) {
    print('Data received: ${result}')
    return processData(result)
}).then((processed) {
    print('Data processed: ${processed}')
})

// 错误：不支持await
// var result = await fetchData()  // 这样不行！
```

### 4. 作用域和闭包

- ✅ **支持闭包**：函数可以捕获外部变量
- ✅ **词法作用域**：变量查找遵循词法作用域规则
- ⚠️ **变量提升**：与JavaScript不同，遵循声明顺序
- ⚠️ **this绑定**：在不同上下文中this的绑定可能不同

```hetu
// 闭包示例
fun createCounter() {
    var count = 0
    return fun() {
        count += 1
        return count
    }
}

var counter = createCounter()
print(counter())  // 1
print(counter())  // 2
```

### 5. 性能考虑

- ⚠️ **解释执行**：性能不如编译型语言
- ⚠️ **动态类型开销**：运行时类型检查有性能成本
- ✅ **字节码编译**：支持编译为字节码提高执行效率
- ⚠️ **内存管理**：注意避免内存泄漏，特别是闭包引用

### 6. 外部绑定注意事项

```dart
// Dart端绑定示例
final hetu = Hetu();
hetu.init(externalFunctions: {
    'dartFunction': (String param) => 'Hello from Dart: $param',
    'asyncFunction': () => Future.delayed(
        Duration(seconds: 1), 
        () => 'Async result'
    ),
});
```

```hetu
// Hetu端使用
external fun dartFunction
external fun asyncFunction

var result = dartFunction('test')
asyncFunction().then((value) => print(value))
```

**绑定注意事项：**
- 确保参数类型匹配
- 处理null值和异常
- 异步函数返回Future对象
- 复杂对象可能需要特殊处理

### 7. 调试建议

- **使用VS Code插件**：获得语法高亮和基本IntelliSense
- **利用REPL模式**：快速测试代码片段
- **注意运行时错误**：动态类型可能导致运行时错误
- **日志调试**：使用print语句进行调试
- **错误处理**：合理使用try-catch处理异常

### 8. 最佳实践

#### 代码风格
```hetu
// 推荐：保持一致的代码风格
fun calculateArea(width: float, height: float) -> float {
    return width * height
}

// 推荐：使用有意义的变量名
var userAccountBalance = 1000
var isUserLoggedIn = true

// 推荐：合理使用类型注解
fun processUserData(userData: Map) -> bool {
    // 处理用户数据
    return true
}
```

#### 错误处理
```hetu
// 推荐：主动处理错误
fun safeParseInt(value: str) -> int? {
    try {
        return int.parse(value)
    } catch (error) {
        print('Parse error: ${error}')
        return null
    }
}

// 推荐：使用断言检查前置条件
fun divide(a: float, b: float) -> float {
    assert(b != 0, 'Division by zero')
    return a / b
}
```

#### 模块化设计
```hetu
// 推荐：合理组织模块
// utils.ht
export fun formatDate(timestamp: int) -> str {
    // 格式化日期
}

export class Logger {
    static fun info(message: str) {
        print('[INFO] ${message}')
    }
}

// main.ht
import { formatDate, Logger } from 'utils.ht'

Logger.info('Application started')
var dateStr = formatDate(1234567890)
```

## 常见陷阱

### 1. 函数定义忘记关键字
```hetu
// 错误：忘记fun关键字
greeting() {  // 这样不行！
    print('Hello')
}

// 正确：使用fun关键字
fun greeting() {
    print('Hello')
}
```

### 2. this绑定问题
```hetu
var obj = {
    name: 'Object',
    greet: fun() {
        print('Hello, ${this.name}')
    }
}

var greetFunc = obj.greet
greetFunc()  // this可能未正确绑定
```

### 3. 异步处理错误
```hetu
// 错误：尝试使用await
// var result = await asyncFunction()

// 正确：使用then
asyncFunction().then((result) {
    // 处理结果
})
```

### 4. 类型假设
```hetu
// 危险：假设类型
fun processNumber(value) {
    return value * 2  // 如果value不是数字会出错
}

// 安全：检查类型
fun processNumber(value) {
    if (value is num) {
        return value * 2
    } else {
        throw 'Expected number, got ${typeof(value)}'
    }
}
```

## 总结

Hetu脚本语言是一个功能丰富的嵌入式脚本语言，语法现代简洁，特别适合Flutter应用的动态化需求。虽然某些高级特性（如完整的async/await支持）尚未实现，但基本的编程范式都得到了良好支持。

**主要优势：**
- 语法简洁现代，易于学习
- 与Dart/Flutter深度集成
- 支持多种编程范式
- 轻量级，适合嵌入

**使用建议：**
- 适合动态配置和热更新场景
- 适合简单的业务逻辑脚本
- 不适合计算密集型任务
- 注意异步编程的限制

通过理解这些语法特征和注意事项，你可以更好地使用Hetu脚本语言来为你的Flutter应用添加动态化能力。

## 实际调试示例

### Future脚本问题分析

以下是一个常见的Future脚本问题示例及其修正：

#### ❌ 问题脚本
```hetu
// 简单的Future测试脚本 - 使用正确的Hetu语法
external fun log(message);
external fun sin(x);
external fun random();
external fun getLayers();

log("=== 简单Future测试开始 ===");

// 测试1: 简单的数学函数调用
log("1. 测试sin函数");
sin(1.5708).then(function(result) {
    log("sin(π/2) = " + result.toString());
    
    // 测试2: 随机数生成
    log("2. 测试随机数生成");
    random().then(function(num) {
        log("随机数: " + num.toString());
        
        // 测试3: 数据访问
        log("3. 测试数据访问");
        getLayers().then(function(layers) {
            log("图层数量: " + layers.length.toString());
            
            log("=== 所有测试完成 ===");
            log("Future.then() 机制工作正常！");
        });
    });
});

log("脚本开始执行，等待异步结果...");
```

#### 🐛 主要问题

1. **`function`关键字错误**：Hetu使用`fun`而不是`function`
2. **字符串拼接语法**：应使用字符串插值`${}`而不是`+`拼接
3. **函数定义语法**：匿名函数语法不正确
4. **外部函数假设**：假设`sin`、`random`等返回Future，但实际可能不是

#### ✅ 修正后的脚本

```hetu
// 修正后的Future测试脚本
external fun log
external fun sin
external fun random
external fun getLayers

log('=== 简单Future测试开始 ===')

// 测试1: 简单的数学函数调用
log('1. 测试sin函数')
var sinResult = sin(1.5708)

// 检查是否为Future
if (sinResult is Future) {
    sinResult.then((result) {
        log('sin(π/2) = ${result.toString()}')
        
        // 测试2: 随机数生成  
        log('2. 测试随机数生成')
        var randomResult = random()
        
        if (randomResult is Future) {
            randomResult.then((num) {
                log('随机数: ${num.toString()}')
                
                // 测试3: 数据访问
                log('3. 测试数据访问')
                getLayers().then((layers) {
                    log('图层数量: ${layers.length.toString()}')
                    log('=== 所有测试完成 ===')
                    log('Future.then() 机制工作正常！')
                })
            })
        } else {
            log('随机数: ${randomResult.toString()}')
        }
    })
} else {
    log('sin(π/2) = ${sinResult.toString()}')
}

log('脚本开始执行，等待异步结果...')
```

#### 🔧 进一步优化版本

```hetu
// 最佳实践版本
external fun log
external fun sin  
external fun random
external fun getLayers

fun logMessage(message: str) {
    log(message)
}

fun handleFutureOrValue(value, callback) {
    if (value is Future) {
        value.then(callback)
    } else {
        callback(value)
    }
}

fun runTests() {
    logMessage('=== 简单Future测试开始 ===')
    
    // 测试1: 数学函数
    logMessage('1. 测试sin函数')
    var sinResult = sin(1.5708)
    
    handleFutureOrValue(sinResult, (result) {
        logMessage('sin(π/2) = ${result}')
        
        // 测试2: 随机数
        logMessage('2. 测试随机数生成')  
        var randomResult = random()
        
        handleFutureOrValue(randomResult, (num) {
            logMessage('随机数: ${num}')
            
            // 测试3: 数据访问
            logMessage('3. 测试数据访问')
            var layersResult = getLayers()
            
            handleFutureOrValue(layersResult, (layers) {
                if (layers != null && layers.length != null) {
                    logMessage('图层数量: ${layers.length}')
                } else {
                    logMessage('无法获取图层信息')
                }
                logMessage('=== 所有测试完成 ===')
            })
        })
    })
}

// 启动测试
runTests()
logMessage('脚本开始执行，等待异步结果...')
```

#### 📝 修正要点总结

1. **函数关键字**：
   - ❌ `function(result) { ... }`
   - ✅ `(result) { ... }` 或 `fun(result) { ... }`

2. **字符串处理**：
   - ❌ `"sin(π/2) = " + result.toString()`
   - ✅ `'sin(π/2) = ${result}'`

3. **外部函数声明**：
   - ❌ `external fun log(message);` (有分号)
   - ✅ `external fun log` (无分号和参数)

4. **错误处理**：
   - 添加类型检查
   - 添加null检查
   - 提供默认处理逻辑

5. **代码组织**：
   - 使用辅助函数
   - 避免深度嵌套
   - 提高可读性

#### 🚀 对应的Dart绑定示例

```dart
import 'dart:math' as math;
import 'package:hetu_script/hetu_script.dart';

void main() {
  final hetu = Hetu();
  
  hetu.init(externalFunctions: {
    'log': (String message) => print(message),
    'sin': (double x) => math.sin(x),  // 同步函数
    'random': () => math.Random().nextDouble(),  // 同步函数
    'getLayers': () => Future.delayed(  // 异步函数
      Duration(milliseconds: 100),
      () => ['layer1', 'layer2', 'layer3']
    ),
  });
  
  // 运行修正后的脚本
  hetu.eval('''
    // 这里放入修正后的Hetu脚本
  ''');
}
```

这个示例展示了如何正确处理混合的同步和异步外部函数，以及如何编写健壮的Hetu脚本代码。
