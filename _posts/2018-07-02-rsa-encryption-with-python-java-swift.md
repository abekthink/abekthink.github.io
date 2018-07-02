---
title:  "RSA Encryption with Python&Java&Swift"
date:   2018-07-01 19:28:50 +0800
categories: "backend"
tags: ["rsa", "python", "java", "android", "swift"]
---

我们经常会遇到这样的需求：需要各端（Server/Android/iOS/Web等）通信时进行加密，防止请求被拦截或者篡改。

本文以实际项目中的真实加密场景说明下，如何对请求进行加密签名，防止数据被篡改。

## 需求
客户端（Android/iOS/Web等）向服务端发送请求，需要对请求中的参数进行加密签名。

## 设计
这里采用了通用的RSA加密签名验证算法，整个流程主要包括如下两部分：
1. 客户端：参数处理，生成签名（sign），向服务端发送带sign的请求。
2. 服务端：参数处理，用请求中的sign进行签名验证，如果不通过则返回参数验证失败；否则，进行后续处理，并将结果返回。

这里为了方便说明，这里举一个简单例子来说明客户端和服务端的处理流程：

### 客户端
假设，客户端请求中包含name、age和career三个参数，为了防止数据被篡改，我们将三个参数进行标准化的字符串排序。
比如请求中的参数为：
```
{
    "namge": "张三",
    "age": 25,
    "career": "后端研发工程师"
}
```

则将该结构体按照key排序后，生成相应字符串format_str，比如：
```
age=25&career=后端研发工程师&namge=张三
```

然后，在将以上字符串format_str进行RSA签名，生成相应的sign，比如：
```
mtttq1BIW2ENAc16sZspwGOdfh+Qu7idr8...
```

最终客户端，向后端请求的参数是：
```
{
    "namge": "张三",
    "age": 25,
    "career": "后端研发工程师",
    "sign": "mtttq1BIW2ENAc16sZspwGOdfh+Qu7idr8..."
}
```

### 服务端
服务端在接到请求后，如客户端一样生成相应的format_str（需要先将sign提取出来）：
```
age=25&career=后端研发工程师&namge=张三
```

然后，通过RSA验证算法，将format_str和请求中的sign参数进行验证，如果失败则是参数或者签名有误，服务端以此来判断参数是否有被篡改。


## 各语言加密方式
下面分别从Python、Java、Swift等主流语言，来分别说明各方是怎么加密和解密的。

### 说明
下面各语言代码示例都会用到公钥和私钥，这里简单声明下：
```
public_key = '''-----BEGIN PUBLIC KEY-----
MIGfMA0GCSqGSIb3...
-----END PUBLIC KEY-----
'''

private_key = '''-----BEGIN RSA PRIVATE KEY-----
MIICXAIBAAKBgQDu...
-----END RSA PRIVATE KEY-----
'''
```

备注：
1. 基于刚刚假设的场景，客户端需要保存私钥，以便进行签名；服务端需要保存公钥，以便进行验证。
2. 这里使用了PKCS1 PSS作为signature算法，SHA256为hash算法。
3. 另外，这里采用了加盐方式，咱设salt_len为11。

### Python
首先需要安装加密包依赖，使用`pip install pycrypto`命令即可。

导入依赖：
```
from Crypto.Signature import PKCS1_PSS
from Crypto.Hash import SHA256
from base64 import b64decode, b64encode
```

加密函数，用于生成sign：
```
def sign_with_pkcs1_pss(format_str):
    signer = PKCS1_PSS.new(private_key, saltLen=11)
    h = SHA256.new()
    h.update(format_str.encode())
    sign = b64encode(signer.sign(h)).decode("utf-8", "strict")
    reutrn sign
```

验证函数，用于验证参数是否正确：
```
def verify_with_pkcs1_pss(format_str, sign)
    verifier = PKCS1_PSS.new(public_key, saltLen=11)

    h = SHA256.new()
    h.update(format_str.encode())
    signature = b64decode(sign)
    if verifier.verify(h, signature):
        return True
    else:
        return False
```

备注：这里以python3环境举例。


### Java(Android)
Java代码，用下面这段代码即可：

```
package io.github.abekthink.rsa.demo;

import android.util.Base64;

import java.io.File;
import java.io.InputStreamReader;
import java.io.ByteArrayInputStream;
import java.security.AlgorithmParameters;
import java.security.KeyFactory;
import java.security.PrivateKey;
import java.security.PublicKey;
import java.security.Security;
import java.security.Signature;
import java.security.spec.MGF1ParameterSpec;
import java.security.spec.PKCS8EncodedKeySpec;
import java.security.spec.PSSParameterSpec;
import java.security.spec.X509EncodedKeySpec;

import org.bouncycastle.util.io.pem.PemObject;
import org.bouncycastle.util.io.pem.PemReader;
import org.bouncycastle.util.io.pem.PemWriter;
import org.bouncycastle.jce.provider.BouncyCastleProvider;

import org.apache.commons.codec.binary.Base64;

public class RSAAlgorithm {

    static {
        Security.addProvider(new BouncyCastleProvider());
    }

    public static PrivateKey getPrivateKey(String pemFormatKey) throws Exception {
        KeyFactory factory = KeyFactory.getInstance("RSA", "BC");

        PemReader pemReader = new PemReader(new InputStreamReader(
                new ByteArrayInputStream(pemFormatKey.getBytes("UTF-8"))));
        pemObject = pemReader.readPemObject();
        byte[] content = pemObject.getContent();
        PKCS8EncodedKeySpec privKeySpec = new PKCS8EncodedKeySpec(content);
        return factory.generatePrivate(privKeySpec);
    }


    public static String signPSS(String plainText, PrivateKey privateKey) throws Exception {
        Signature privateSignature = Signature.getInstance("SHA256withRSA/PSS");
        AlgorithmParameters pss = privateSignature.getParameters();
        PSSParameterSpec spec = new PSSParameterSpec("SHA-256", "MGF1",
                new MGF1ParameterSpec("SHA-256"), 11, 1);
        privateSignature.setParameter(spec);
        privateSignature.initSign(privateKey);
        privateSignature.update(plainText.getBytes(UTF_8));

        byte[] signature = privateSignature.sign();
        Base64.encode(signature,Base64.DEFAULT);
        return Base64.encodeBase64String(signature);
    }

    public static String generateSign(String formatStr) throws Exception {
        String prikey = "-----BEGIN RSA PRIVATE KEY-----\n" + "..." + "-----END RSA PRIVATE KEY-----";
        PrivateKey privateKey = getPrivateKeyFrom(prikey);
        String signature = signPSS(formatStr, privateKey);
    }

    public static PublicKey getPublicKey(String pemFormatKey) throws Exception {
        KeyFactory factory = KeyFactory.getInstance("RSA", "BC");

        PemReader pemReader = new PemReader(new InputStreamReader(
                new ByteArrayInputStream(public_key.getBytes("UTF-8"))));
        pemObject = pemReader.readPemObject();
        byte[] content = pemObject.getContent();
        X509EncodedKeySpec pubKeySpec = new X509EncodedKeySpec(content);
        return factory.generatePublic(pubKeySpec);
    }

    public static boolean verifyPSS(String plainText, String signature, String pomPubKey) throws Exception {
        PublicKey publicKey = getPublicKey(pomPubKey);
        Signature publicSignature = Signature.getInstance("SHA256withRSA/PSS");
        AlgorithmParameters pss = publicSignature.getParameters();
        PSSParameterSpec spec = new PSSParameterSpec("SHA-256", "MGF1",
                new MGF1ParameterSpec("SHA-256"), 11, 1);
        publicSignature.setParameter(spec);
        publicSignature.initVerify(publicKey);
        publicSignature.update(plainText.getBytes(UTF_8));

        byte[] signatureBytes = Base64.decodeBase64(signature);
        return publicSignature.verify(signatureBytes);
    }

    public static String verifySign(String formatStr, String sign) throws Exception {
        String pubkey = "-----BEGIN PUBLIC KEY-----\n" + "..." + "-----END PUBLIC KEY-----";
        return RSAAlgorithm.verifyPSS(formatStr, sign, pubkey)
    }
}

```

Android端：
1. 需要在gradle配置dependencies项中，增加如下依赖：
```
implementation('org.bouncycastle:bcprov-jdk15on:1.54')
implementation('commons-codec:commons-codec:1.2')
```

2. 同时，将上述代码中做出如下调整：
    将
        `KeyFactory factory = KeyFactory.getInstance("RSA", "BC");`
    修改为：
        `KeyFactory factory = KeyFactory.getInstance("RSA", new BouncyCastleProvider());`


### Swift
```
public struct RSA {

    public static func publicKey() -> Data {
        let publicKeyPEM = """
        -----BEGIN PUBLIC KEY-----
        ...
        -----END PUBLIC KEY-----
        """

        let publicKeyDER = try! SwKeyConvert.PublicKey.pemToPKCS1DER(publicKeyPEM)
        return publicKeyDER
    }

    public static func privateKey() -> Data {
        let privateKeyPEM = """
        -----BEGIN RSA PRIVATE KEY-----
        ...
        -----END RSA PRIVATE KEY-----
        """

        let privateKeyDER = try! SwKeyConvert.PrivateKey.pemToPKCS1DER(privateKeyPEM)
        return privateKeyDER
    }

    public static func sign(_ message: String) -> String? {
        guard let data = message.data(using: .utf8) else { return nil }
        let sign = try? CC.RSA.sign(data, derKey: privateKey(), padding: .pss,
                                    digest: .sha256, saltLen: 11)
        return sign?.base64EncodedString()
    }

//    public static func sign(_ parameters: [String: Any]) -> String? {
//        let message = parameters
//            .sorted(by: { $0.key < $1.key })
//            .map({ $0 + "=" + "\($1)" })
//            .joined(separator: "&")
//        guard let data = message.data(using: .utf8) else { return nil }
//        let sign = try? CC.RSA.sign(data, derKey: privateKey(), padding: .pss,
//                                    digest: .sha256, saltLen: 11)
//        return sign?.base64EncodedString()
//    }

    public static func verify(_ message: String, sign: Data) -> String? {
        guard let data = message.data(using: .utf8) else { return nil }
        let verified = try? CC.RSA.verify(testMessage, derKey: pubKey, padding: padding,
                                          digest: .sha256, saltLen: 11, signedData: sign!)

        return verified
    }
}
```


## 参考文档
- [Python RSA 代码库](https://github.com/dlitz/pycrypto)
- [Java RSA 参考代码](http://www.java2s.com/Tutorial/Java/0490__Security/RSASignatureGeneration.htm)
- [Swift RSA 代码库](https://github.com/soyersoyer/SwCrypt)
