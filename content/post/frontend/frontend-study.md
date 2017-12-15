---
title: "前端入门"
author: "ox0spy"
tags: ["frontend"]
categories: ["frontend"]
---

# 前端学习

前端资料

- [Web 技术文档](https://developer.mozilla.org/zh-CN/docs/Web)

## HTML
- [Learn to Code HTML & CSS](http://learn.shayhowe.com/html-css/)

## JavaScript相关知识

### JavaScript入门

JavaScript入门教程

- JavaScript精髓
- [ECMAScript 6入门](http://es6.ruanyifeng.com/)

### JavaScript异步编程

- [NodeJs通过async/await处理异步](http://www.cnblogs.com/YikaJ/p/4996174.html)

#### 安全编码

- ESLint

#### 测试框架

- Mocha


### npm入门
- [npm模块管理器](http://javascript.ruanyifeng.com/nodejs/npm.html)
- [npm 模块安装机制简介](http://www.ruanyifeng.com/blog/2016/01/npm-install.html)

### JavaScript Source Map

source map 的作用在于可以在浏览器中的 开发者工具 中像调试源代码一样地调试转换(被编译器压缩)后的Javascript代码。
source map是一个记录代码转换前和转换后的位置信息文件，利用[Closure Compiler](https://developers.google.com/closure/compiler/)生成。

- [http://www.alloyteam.com/2014/01/source-map-version-3-introduction/]
- [JavaScript Source Map 详解](http://www.ruanyifeng.com/blog/2013/01/javascript_source_map.html)

### 转码器

#### Babel
Babel是一个广泛使用的转码器，可以将ES6代码转为ES5代码，从而在现有环境执行。

- [Babel 入门教程](http://www.ruanyifeng.com/blog/2016/01/babel.html)

### JavaScript module and bundle
- JavaScript模块化编程
 + [Javascript模块化编程（一）：模块的写法](http://www.ruanyifeng.com/blog/2012/10/javascript_module.html)
 + [Javascript模块化编程（二）：AMD规范](http://www.ruanyifeng.com/blog/2012/10/asynchronous_module_definition.html)
 + [Javascript模块化编程（三）：require.js的用法](http://www.ruanyifeng.com/blog/2012/11/require_js.html)
- [浏览器加载 CommonJS 模块的原理与实现](http://www.ruanyifeng.com/blog/2015/05/commonjs-in-browser.html)

注: 知识点: JavaScript模块化发展历史、CommonJS、AMD、Require.js

- 前端模块管理器
 + [前端模块管理器简介](http://www.ruanyifeng.com/blog/2014/09/package-management.html)
 + [webpack howto](https://github.com/petehunt/webpack-howto/blob/master/README-zh.md)
 + [webpack指南](https://webpack.toobug.net/zh-cn/)

注: 知识点: Bower、Browserify、Component、Duo、Webpack

### JSX

JSX 是一个看起来很像 XML 的 JavaScript 语法扩展。React 可以用来做简单的 JSX 句法转换。
JSX 把类 XML 的语法转成原生 JavaScript。

- [深入JSX](https://facebook.github.io/react/docs/jsx-in-depth-zh-CN.html)

## CSS

### CSS入门
- [CSS 开发者指南](https://developer.mozilla.org/zh-CN/docs/Web/Guide/CSS)
- [CSS盒模型]
- [学习CSS布局](http://zh.learnlayout.com/)
- [Debugging CSS](https://developer.mozilla.org/en-US/docs/Learn/CSS/Introduction_to_CSS/Debugging_CSS)

### CSS预处理
可以用CSS开发网页样式，但是没法用它编程。也就是说，CSS基本上是设计师的工具，不是程序员的工具。在程序员眼里，CSS是一件很麻烦的东西。它没有变量，也没有条件语句，只是一行行单纯的描述，写起来相当费事。
SASS加入编程元素，这被叫做"[CSS预处理器](http://www.catswhocode.com/blog/8-css-preprocessors-to-speed-up-development-time)"（css preprocessor）。它的基本思想是，用一种专门的编程语言，进行网页样式设计，然后再编译成正常的CSS文件。
各种"CSS预处理器"之中，我自己最喜欢[SASS](http://sass-lang.com/)，觉得它有很多优点，打算以后都用它来写CSS。下面是我整理的用法总结，供自己开发时参考，相信对其他人也有用。

- [SASS用法指南](http://www.ruanyifeng.com/blog/2012/06/sass.html)
- [Compass用法指南](http://www.ruanyifeng.com/blog/2012/11/compass)

### CSS Modules
为了让 CSS 也能适用软件工程方法，程序员想了各种办法，让它变得像一门编程语言。从最早的Less、SASS，到后来的 PostCSS，再到最近的 CSS in JS，都是为了解决这个问题。
CSS Modules 有所不同。它不是将 CSS 改造成编程语言，而是功能很单纯，只加入了局部作用域和模块依赖，这恰恰是网页组件最急需的功能。
- [CSS Modules 用法教程](http://www.ruanyifeng.com/blog/2016/06/css_modules.html)

## 框架

### Bootstrap (偏CSS?)

### Vue.js
- [Vue.js 官方教程](https://vuejs.org.cn/guide/)
- [Vue.js keepfool 教程](https://github.com/keepfool/vue-tutorials)

### React

- [React 技术栈系列教程](http://www.ruanyifeng.com/blog/2016/09/react-technology-stack.html)

## 架构

- [软件架构入门](http://www.ruanyifeng.com/blog/2016/09/software-architecture.html)

### 安全