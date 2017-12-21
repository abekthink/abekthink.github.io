---
title:  "使用JWT保证服务间通信的安全"
date:   2017-12-17 20:18:00 +0800
categories: backend
tags: ["JWT", "JSON Web Token", "Authentication Server"]
---
本文主要讲下JWT(JSON Web Token)的基本原理，以及为什么使用它，如何使用它。


## 什么是JWT
先看看JWT的定义：

A JSON Web Token (JWT) is a [JSON object](https://www.w3schools.com/js/js_json_objects.asp) that is defined in [RFC 7519](https://tools.ietf.org/html/rfc7519) as a safe way to represent a set of information between two parties. The token is composed of a header, a payload, and a signature.
{: .notice--info}

翻译过来就是说：JWT是一种基于RFC 7519标准的JSON对象，主要是为了双方通信的安全而制定的。它包含头部（header），载荷（payload）和签名（signature）三部分。


## 为什么使用JWT
说到这里，就要说下传统的基于session的用户认证方式以及基于token的区别了。

### 基于session的用户认证方式
大家都知道，http是一种无状态的协议，用户登录成功后如果下次再次访问还需要再次认证，或者下次访问时携带相关的认证信息也是可以的。
session认证就是后面这种实现方式：当用户登录成功后，由服务端为用户生成相应的认证信息存储在服务端，并在请求响应返回前，将认证信息写入响应的cookie内；这样，用户下一次请求时携带之前cookie的认证信息即可，服务端在收到请求后，对cookie里的信息与服务端的session进行比对认证，验证通过后即可进行后续处理。

这种方式的缺点是：
- 如果客户端不能支持cookie功能，接入会非常困难。
- 服务端存储了用户的session信息，这些信息随着用户量的增大，服务端的空间开销都会不断增加。
- 服务器的session信息是需要独立存储的，如果数据分散存放在各个服务器，那么还要考虑用户是在哪台服务器登录了，难于扩展和维护。

### 基于token的用户认证方式
基于token的用户认证是一种服务端无状态的认证方式，服务端无需存储用户的认证信息或者会话信息，并且任何服务器拿到token都能进行用户认证。

主要流程大致如下：
- 用户使用密码登录或者第三方登录。
- 服务器收到用户的登录信息进行身份认证；通过身份验证后，服务器生成token，并将其返回。
- 客户端收到token后存储在本地，并在后续的请求中均携带该token。
- 服务器收到后续的用户请求时，用请求的token进行用户认证，验证通过后即可进行后续处理。

这种认证方式相对简单，而且可扩展性很强，无需考虑服务器的单点问题等。我这里选用了JWT作为token的生成策略。

<figure>
  <img src="{{ '/assets/images/jwt-auth.png' }}" alt="How an application uses JWT to verify the authenticity of a user.">
</figure>


## JWT生成与验证

### JWT格式

刚才已经提到，JWT包含三个组件：头部，载荷和签名。其格式大致如下：
```
header.payload.signature
```

这里举一个比较真实的例子，如下：
```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1aWQiOiIzMmNkOGI4M2RjZTk0MDBjOGNjOWRiNmVkNjdhZjBkOSIsImlzcyI6ImFiZWt0aGluay5naXRodWIuaW8iLCJleHAiOjE1MTM3NjA1MjksImlhdCI6MTUxMzI2MDUyOSwiYXVkIjoic29tZW9uZSIsInN1YiI6ImFiZWt0aGluay5naXRodWIuaW8ifQ.O0laKQkICjLO5V4gY_LWqADdEtjCgqM_deFHduqBMTk
```


### header
header主要包含着token是如何加密生成的信息，是一个类似如下格式的JSON对象：
```javascript
{
    "typ": "JWT",
    "alg": "HS256"
}
```
这里，typ指定了这个对象是一个JWT对象，alg指明了用于生成JWT签名组件用到的算法。在这个例子中，我们用到了`HMAC-SHA256`算法（只要提供一个secret即可进行加密的算法）。


### payload
payload也是一个JSON对象，它主要包含了一些用户的有效信息，例如：
```javascript
{
  "uid": "32cd8b83dce9400c8cc9db6ed67af0d9",
  "iss": "abekthink.github.io",
  "exp": 1513760529,
  "iat": 1513260529,
  "aud": "someone",
  "sub": "abekthink.github.io"
}

```

标准中的保留字如下：

变量名 | 英文全写 | 备注
----- | ------- | ----
iss | Issuer | 该JWT的发布者
sub | Subject | 该JWT面向的主体或者用户
aud | Audience | 接收该JWT的用户
exp | Expiration Time | 过期时间（单位为秒）
nbf | Not Before | 开始时间（单位为秒），在该时间之前无效
iat | Issued At | 发布时间（单位为秒）
jti | JWT ID | JWT唯一标识，区分不同发布者的统一的标识

字段的具体说明可以参考[RFC 7519](https://tools.ietf.org/html/rfc7519#section-4.1.1)。

**备注：** header和payload部分，均采用base64加密。所以，任何人均可以解密出来，建议不要放用户敏感信息。
{: .notice--warning}


### signature
最后一部分是签名信息，它由header、payload以及secret三部分生成而来。

首先，将header和payload分别用base64url加密，然后两段加密后的字符串用`.`连接起来；之后，将拼接后的字符串，用secret进行hash加密得到最终签名的部分，加密的算法就是之前header里alg指定的算法。这里用一段伪代码来表示签名的生成过程：
```javascript
// signature algorithm
data = base64urlEncode(header) + "." + base64urlEncode(payload)
signature = Hash(data, secret);
```


### JWT生成
将加密后的header、payload和signature三部分用`.`连接起来，即最后的JWT。
```javascript
// header(after base64url)
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9

// payload(after base64url)
eyJ1aWQiOiIzMmNkOGI4M2RjZTk0MDBjOGNjOWRiNmVkNjdhZjBkOSIsImlzcyI6ImFiZWt0aGluay5naXRodWIuaW8iLCJleHAiOjE1MTM3NjA1MjksImlhdCI6MTUxMzI2MDUyOSwiYXVkIjoic29tZW9uZSIsInN1YiI6ImFiZWt0aGluay5naXRodWIuaW8ifQ

// signature
O0laKQkICjLO5V4gY_LWqADdEtjCgqM_deFHduqBMTk

// final jwt
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1aWQiOiIzMmNkOGI4M2RjZTk0MDBjOGNjOWRiNmVkNjdhZjBkOSIsImlzcyI6ImFiZWt0aGluay5naXRodWIuaW8iLCJleHAiOjE1MTM3NjA1MjksImlhdCI6MTUxMzI2MDUyOSwiYXVkIjoic29tZW9uZSIsInN1YiI6ImFiZWt0aGluay5naXRodWIuaW8ifQ.O0laKQkICjLO5V4gY_LWqADdEtjCgqM_deFHduqBMTk
```

**备注：** 这里hash算法用的是HS256（即`HMAC-SHA256`），所以它只需要一个secret即可以完成JWT的生成和验证，该secret仅保存在服务端，必须保密；如果想要安全系数更高，建议采用使用公钥私钥的RS256（即`RSA-SHA256`）算法。
{: .notice--warning}


### JWT验证
前面已经详细地介绍了JWT是如何生成的，这里主要说下，当用户发来一个JWT，服务端如何进行验证。

服务端收到JWT，主要的验证流程如下：
- 先验证签名是否一致，即通过header和payload，再加上服务器的secret再次生成签名，看是否与JWT的第三部分一致。如果不一致说明token被篡改，应该拒绝该请求。
- 验证iss、sub、aud是否与之前生成token的相应配置一致。
- 验证nbf和exp是否在合理的有效期内。

第一步服务端必须进行验证；后面的两部分可依据自己的应用场景进行选择性处理。


## 注意事项
这里再次提醒下大家要注意的几点：
- JWT生成过程中不要放用户的敏感信息，因为很容易泄露。
- 出于安全考虑，建议对iss、sub、aud、nbf和exp字段均进行验证。
- 别重复造轮子，现在有很多现成的[JWT开源库](https://jwt.io/)，包括c、python、java、nodejs、javascript、ruby、go等各种主流语言的版本。


## 参考文档
- [RFC 7519标准](https://tools.ietf.org/html/rfc7519)
- [5步轻松理解JWT](https://medium.com/vandium-software/5-easy-steps-to-understanding-json-web-tokens-jwt-1164c0adfcec)
- [JWT开源库](https://jwt.io/)
