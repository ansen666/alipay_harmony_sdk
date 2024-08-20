import { SignUtils } from './SignUtils';
import { util } from '@kit.ArkTS';
import { PayInfo } from '../module/PayInfo';

export class OrderInfoUtil{
    static async getOrderInfo(payInfo:PayInfo): Promise<string> {
        const keyValues = OrderInfoUtil.buildOrderParamMap(payInfo);
        let orderParam = OrderInfoUtil.buildOrderParam(keyValues);
        // console.log("订单参数："+orderParam)
        let sign = await OrderInfoUtil.getSign(keyValues,payInfo);
        return orderParam + '&sign=' + sign;
    }

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

    static buildOrderParam(keyValues: Map<string, string>): string {
        let param = '';
        keyValues.forEach((value, key) => {
            param += key + '=' + encodeURIComponent(value) + '&';
        });
        param = param.substring(0, param.length - 1);
        return param;
    }

    static async getSign(keyValues: Map<string, string>,payInfo:PayInfo): Promise<string> {
        let mapEntries = Array.from(keyValues.keys());
        mapEntries.sort((a, b) => {
            return a[0].localeCompare(b[0]);
        });
        let sortedKeyValues = new Map<string, string>();
        mapEntries.forEach(entry => {
            sortedKeyValues.set(entry[0], entry[1]);
        });
        let param = '';
        keyValues.forEach((value, key) => {
            param += key + '=' + value + '&';
        });
        param = param.substring(0, param.length - 1);
        let oriSign = await SignUtils.sign(param, payInfo.rsaPrivate);
        return encodeURIComponent(oriSign);
    }
}