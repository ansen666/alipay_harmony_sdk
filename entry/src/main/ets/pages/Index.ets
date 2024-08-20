import { Pay } from '@cashier_alipay/cashiersdk'
import { PayInfo } from '../module/PayInfo'
import { OrderInfoUtil } from '../util/OrderInfoUtil'
import { BusinessError } from '@kit.BasicServicesKit'

@Entry
@Component
struct Index {

    build() {
        Column() {
            Button("开启支付宝支付")
                .fontSize(30)
                .fontWeight(FontWeight.Bold).onClick(event=>{
                this.onAlipay()
            }).margin({
                top:100,left:50,right:50
            })
        }
        .height('100%')
        .width('100%')
    }

    onAlipay(){
        ///这个支付信息对象的所有值都应该服务器返回
        let obj = new PayInfo();//支付信息
        obj.appId = "1111111111111";
        obj.orderId = "1111111111"
        obj.productName = "1年VIP"
        obj.amount = 10
        obj.notifyUrl = 'https://www.huawei.com'
        obj.rsaPrivate = "MIICXQIBAAKBgQC+L0rfjLl3neHleNMOsYTW8r0QXZ5RVb2p/vvY3fJNNugvJ7lo4+fdBz+LN4mDxTz4MTOhi5e2yeAqx+v3nKpNmPzC5LmDjhHZURhwbqFtIpZD51mOfno2c3MDwlrsVi6mTypbNu4uaQzw/TOpwufSLWF7k6p2pLoVmmqJzQiD0QIDAQABAoGAakB1risquv9D4zX7hCv9MTFwGyKSfpJOYhkIjwKAik7wrNeeqFEbisqv35FpjGq3Q1oJpGkem4pxaLVEyZOHONefZ9MGVChT/MNH5b0FJYWl392RZy8KCdq376Vt4gKVlABvaV1DkapL+nLh7LMo/bENudARsxD55IGObMU19lkCQQDwHmzWPMHfc3kdY6AqiLrOss+MVIAhQqZOHhDe0aW2gZtwiWeYK1wB/fRxJ5esk1sScOWgzvCN/oGJLhU3kipHAkEAysNoSdG2oWADxlIt4W9kUiiiqNgimHGMHPwp4JMxupHMTm7D9XtGUIiDijZxunHv3kvktNfWj3Yji0661zHVJwJBAM8TDf077F4NsVc9AXVs8N0sq3xzqwQD/HPFzfq6hdR8tVY5yRMb4X7+SX4EDPORKKsgnYcur5lk8MUi7r072iUCQQC8xQvUne+fcdpRyrR4StJlQvucogwjTKMbYRBDygXkIlTJOIorgudFlrKP/HwJDoY4uQNl8gQJb/1LdrKwIe7FAkBl0TNtfodGrDXBHwBgtN/t3pyi+sz7OpJdUklKE7zMSBuLd1E3O4JMzvWP9wEE7JDb+brjgK4/cxxUHUTkk592"

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
    }
}