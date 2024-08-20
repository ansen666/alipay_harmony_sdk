App适配鸿蒙Next，开始做支付功能了，目前来说只有支付宝支持鸿蒙Next，微信还没上架，但是支付宝官方的文档跟Demo都很老，下载官方的Demo用最新版的DevEco-Studio导入都不成功。

后面在OpenHarmony三方库中心仓找到了最新的代码：
> https://ohpm.openharmony.cn/#/cn/detail/@cashier_alipay%2Fcashiersdk

官方Demo地址：
> https://alidocs.dingtalk.com/i/nodes/qnYMoO1rWxrkmoj2IOpZR6yaJ47Z3je9?iframeQuery=utm_source%3Dportal%26utm_medium%3Dportal_recent&rnd=0.2928087218087806

### 代码实现
首先依赖支付宝SDK，打开终端，cd到项目文件夹，输入命令，如果ohpm没有加入环境变量的话需要手动加一下:
```
ohpm i @cashier_alipay/cashiersdk
```

把OrderInfoUtil跟SignUtils文件复制到你的项目中来，当点击界面上的支付按钮时，先请求服务器，获取支付信息，然后调用new Pay().pay(orderInfo, true)进行支付。PayInfo对象所有信息都应该服务器返回。
```
///这个支付信息对象的所有值都应该服务器返回
let obj = new PayInfo();//支付信息
obj.appId = "1111111111111";
obj.orderId = "1111111111"
obj.productName = "1年VIP"
obj.amount = 10
obj.notifyUrl = 'https://www.huawei.com'
obj.rsaPrivate = "MIICXQIBAA"

OrderInfoUtil.getOrderInfo(obj).then(orderInfo=>{
    // orderInfo 由服务端生成
    // 第二个参数 控制是否展示支付宝loading
    new Pay().pay(orderInfo, true).then((result) => {
        let message =
            `resultStatus: ${result.get('resultStatus')} memo: ${result.get('memo')} result: ${result.get('result')}`;
        console.log("支付结果："+message);

        if (result.get('resultStatus') == '9000') { //支付成功
            console.log("支付成功");
        }else{
            console.log("支付失败");
        }
    }).catch((error: BusinessError) => {
        console.log(error.message);
    });
})
```

**效果图**

![image](https://github.com/ansen666/alipay_harmony_sdk/blob/main/jietu.gif?raw=true)

### 注意事项
官方的Demo是没有notify_url这个参数的，但是我发现不加上notify_url的话，支付成功不会回调我们的业务服务器，于是我对比安卓的代码给加上的，还有notify_url必须要加在method参数后面，因为计算签名的时候参数key是需要排序的。

如果复制我的OrderInfoUtil类是已经修改过的，如果复制官方Demo中的OrderInfoUtil类需要注意一下。
```
/**
 * 生成订单参数Map，这个Key一定要排序，例如b开头的key一定要写在c开头的key前面
 * @param payInfo
 * @returns
 */
static buildOrderParamMap(payInfo:PayInfo): Map<string, string> {
    const keyValues = new Map<string, string>()
    keyValues.set('app_id', payInfo.appId);

    // 商户网站唯一订单号
    let orderId =payInfo.orderId;
    if(orderId == undefined || orderId==''){
        orderId = util.generateRandomUUID(true);
    }

    // 不能包含中文，否则加密会有问题。。。。。。。。。。。。
    keyValues.set('biz_content', "{\"timeout_express\":\"30m\",\"product_code\":\"QUICK_MSECURITY_PAY\",\"total_amount\":\""+
    payInfo.amount+"\",\"subject\":\""+payInfo.productName+"\",\"body\":\""+
    payInfo.productName+"\",\"out_trade_no\":\"" + orderId +  "\"}");
    keyValues.set('charset', 'utf-8');
    keyValues.set('method', 'alipay.trade.app.pay');
    keyValues.set('notify_url',payInfo.notifyUrl);//支付成功后，支付宝会访问这个通知URL
    keyValues.set('sign_type', 'RSA2');
    keyValues.set('timestamp', '2016-07-29 16:55:53');
    keyValues.set('version', '1.0');
    return keyValues;
}
```

如果您想第一时间看我的后期文章，扫码关注公众号

          安辉编程笔记 - 开发技术分享
                 扫描二维码加关注
![安辉编程笔记](https://img-blog.csdn.net/20170920171642568)
