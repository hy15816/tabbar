//
//  BLEOperation.m
//  HYTabBar
//
//  Created by AEF-RD-1 on 15/9/23.
//  Copyright (c) 2015年 com.hyIm. All rights reserved.
//

#import "BLEOperation.h"

@interface BLEOperation ()
{
    NSString *cString;      //特征
    NSString *sString;      //服务
    NSInteger connCount;    //连接次数
    BOOL bUIMayShow;
    BOOL isAcceptData;
}
@property (strong,nonatomic) CBCentralManager *manager;     //
@property (strong,nonatomic) NSMutableArray *peripheralArray;
@property (strong,nonatomic) CBPeripheral *currPeripheral;  //当前连接的外设
@property (strong,nonatomic) NSDictionary *currCarDict;     //当前连接的车(车牌，id)
@property (strong,nonatomic) CBCharacteristic *currCharacteristic;  //当前特征
@end

@implementation BLEOperation

@synthesize manager;
@synthesize currPeripheral;
@synthesize currCarDict;
@synthesize peripheralArray;
@synthesize currCharacteristic;

static BLEOperation *BLEOP =nil;

+ (BLEOperation *)share{
    @synchronized(self)
    {
        if (BLEOP == nil) {
            BLEOP = [[self alloc]init];
            BLEOP.currPeripheral=nil;
            BLEOP.manager=nil;
            BLEOP.delegatePeripheralProperValue=nil;
            BLEOP.currCarDict = nil;
        }
    }
    return BLEOP;
}

#pragma mark -- CBCentralManagerDelegate
//中心设备状态
- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    /**
     CBCentralManagerStateUnknown = 0,
     CBCentralManagerStateResetting,
     CBCentralManagerStateUnsupported,
     CBCentralManagerStateUnauthorized,
     CBCentralManagerStatePoweredOff,
     CBCentralManagerStatePoweredOn,
     */
    NSString *message;
    switch (central.state) {
        case CBCentralManagerStateUnknown:
            message = @"未知蓝牙";
            break;
        case CBCentralManagerStateResetting:
            message = @"正在重启蓝牙";
            break;
        case CBCentralManagerStateUnsupported:
            message = @"设备不支持蓝牙";
            break;
        case CBCentralManagerStateUnauthorized:
            message = @"蓝牙未经授权";
            break;
        case CBCentralManagerStatePoweredOff:
            message = @"蓝牙已关闭";
            break;
        default:
            break;
    }
#warning ========= this is a notes
    //检查当前类是否符合协议 (conformsToProtocol:)
    //检查对象是否实现了此协议的方法，是则调用，否则不调用，防止程序崩溃(respondsToSelector:)
    if (central.state == CBCentralManagerStatePoweredOn) {
        return;
    }
    if ([self.delegate respondsToSelector:@selector(didUpdateCMState:)]) {
        [self.delegate didUpdateCMState:message];
    }
    
    NSLog(@"bleop central.state :%@",message);
}

//?
- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary *)dict{
    NSLog(@"bleop willRestoreState:%@",dict);
}

//
- (void)centralManager:(CBCentralManager *)central didRetrieveConnectedPeripherals:(NSArray *)peripherals{
    NSLog(@"bleop didRetrieveConnectedPeripherals:%@",peripherals);
}

//扫描到外设回调
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
    NSLog(@"bleop didDiscoverPeripheral peripheral.name=%@, UUID=%@",peripheral.name, peripheral.identifier.UUIDString);

    NSString * kCBAdvDataLocalNameString =[NSString stringWithFormat:@"%@",[advertisementData  objectForKey:@"kCBAdvDataLocalName"]];
    if(kCBAdvDataLocalNameString.length < 9) {
        NSLog(@"bleop didDiscoverPeripheral: kCBAdvDataLocalNameString < 9, %@ ",kCBAdvDataLocalNameString);
        
    }else{
        if(_allCarArray!=nil){
            NSDictionary *dict=nil;
            
            for(int i=0; i<_allCarArray.count; i++){
                dict = [_allCarArray objectAtIndex:i];
                //NSLog(@"bleObj.m, centralManager,didDiscoverPeripheral] dict:%@",dict);
                NSString* nsLocalCarNum=[NSString stringWithFormat:@"TAS%@", [[dict objectForKey:@"License_plate_number"] substringFromIndex:1]];//取出车牌
                NSString* nsAdvCarNum=[NSString stringWithFormat:@"%@", [kCBAdvDataLocalNameString substringToIndex:9]]; //扫描的车牌TASXXXXXX
                
                if([self rc:nsLocalCarNum scanCp:nsAdvCarNum]){
                    NSLog(@"bleop didDiscoverPeripheral nsLocalCarNum==nsAdvCarNum, bUIMayShow=%d", bUIMayShow);
                    //cpString=[dict objectForKey:@"License_plate_number"];//获取车牌
                    currCarDict = dict;
                    currPeripheral=peripheral;
                    currPeripheral.delegate=self;
                    [self connectPeripheral];
                    //if(bUIMayShow) [self.delegate didConnectWithCar:dict]; //pop up ui opening... //fixfix1, 20150920
                    
                    break;
                }
            }//for-end
        }
    }

}

//容错判断
-(BOOL)rc:(NSString *)selfCp scanCp:(NSString *)scanCp{
    BOOL flag;
    int count = 0;
    NSMutableArray *arr1 = [[NSMutableArray alloc]init];
    NSMutableArray *arr2 = [[NSMutableArray alloc]init];
    
    for (int i=0; i<9; i++) {
        NSString *str1 = [selfCp substringWithRange:NSMakeRange(i, 1)];
        NSString *str2 = [scanCp substringWithRange:NSMakeRange(i, 1)];
        [arr1 addObject:str1];
        [arr2 addObject:str2];
    }
    for (int i=0; i<9; i++) {
        if ([arr1[i] isEqual:arr2[i]]) {
            count++;
        }
    }
    if(count>=7){
        flag = YES;
        return flag;
    }else{
        flag = NO;
        return flag;
    }
}

//连接成功
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    NSLog(@"bleop 连接成功:%@",peripheral.name);
    [manager stopScan];
    [currPeripheral discoverServices:nil];
}

//连接失败
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@"bleop 连接失败:%@",error.localizedDescription);
}

//断开外设(需是已经连接上的断开)
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@"bleop 断开连接:%@ err:%@",peripheral.name,error.localizedDescription);
    if (error) {
        if ([self.delegatePeripheralProperValue respondsToSelector:@selector(didDisConnection)]) {
            [self.delegatePeripheralProperValue didDisConnection];
        }
    }
    
}

#pragma mark -- CBPeripheralDelegate
//发现服务
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{

    if (!error) {
        //NSLog(@"bleop didDiscoverServices peripheral.services.count=%lu", (unsigned long)peripheral.services.count);
        for (CBService *s in peripheral.services){
            NSLog(@"bleop 发现服务：%@",s.UUID);
            NSString *sevString =[NSString stringWithFormat:@"%s",[self CBUUIDToString:s.UUID]];
            if ([sevString isEqualToString:sString]) {
                [peripheral discoverCharacteristics:nil forService:s];
            }
        }
    }else {
        NSLog(@"@ 服务发现不成功 ");
    }
}

//发现服务下的特征
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    if (!error) {
        //NSLog(@"bleop didDiscoverCharacteristicsForService service:%s",[self CBUUIDToString:service.UUID]);
        for(int i=0;i<service.characteristics.count;i++) {
            CBPeripheral *perip =peripheral;
            CBCharacteristic *chc =[service.characteristics objectAtIndex:i];
            NSString *ss=[NSString stringWithFormat:@"%s",[self CBUUIDToString:chc.UUID]];
            NSLog(@"bleop 发现特征：%@",ss);
            if ([ss isEqualToString:cString]) {
                currCharacteristic = chc;
                [self sends];//发送数据
                [self performSelector:@selector(acceptValue) withObject:nil afterDelay:3];
                
            }
            [perip setNotifyValue:YES forCharacteristic:chc];
        }
    }else{
        NSLog(@"特征发现不成功");
        
    }

}
//若3秒后没接收到数据，重新发一条
-(void)acceptValue{
    if (isAcceptData == NO) {
        [self sends];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self acceptValue];
    });
}
-(const char *) CBUUIDToString:(CBUUID *) UUID {
    return [[UUID.data description] cStringUsingEncoding:NSStringEncodingConversionAllowLossy];
}

//往特征值写入数据回调
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    
    if(error){
        NSLog(@"bleop didWriteValueForCharacteristic error: %@", error.localizedDescription);
    }
    
}
//外设特征值更新
-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    NSString *dataString = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
    NSLog(@"bleop didUpdateValueForCharacteristic string:%@",dataString);
    NSLog(@"bleop didUpdateValueForCharacteristic  data :%@",characteristic.value);

    UInt8 xval[20];
    NSInteger getlenth=[characteristic.value length];
    if (getlenth>0) {
        isAcceptData = YES;
    }
    [characteristic.value getBytes:&xval length:getlenth];
    
    NSMutableString *string=[NSMutableString string];
    for(int i=0; i<getlenth; i++) [string appendFormat:@"%02x",xval[i]];
    
    NSString *errString;
    if ([[string substringToIndex:4] isEqualToString:@"4f4b"]) {
        //发送第二条指令
        [self sendsTwo];
    }else if ([string isEqualToString:@"54494d454f4b"] ){
        //TIMEOK，已开闸
        NSLog(@"已打开--%@",string);
        errString = @"已打开";
    }else if([string isEqual:@"4e554c4c"] || [string isEqual:@"4552524f52"]){ //车牌为NULL, 车牌不对
        
        if (connCount<3) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self sends];
            });
            return;
        }
        [self cancelPeripheralConnection];
        errString = @"请重试";
    }else{
        [self cancelPeripheralConnection];
        //未知错误
        errString = @"请重试";
    }
    
    if ([self.delegate respondsToSelector:@selector(didOpenGatesWithError:)]) {
        [self.delegate didOpenGatesWithError:errString];
    }
        
    
    
    
    
    
    /*
    
    
    
    
    BOOL bOK = NO;
    //车闸4f4b正确回调   错误 4552524f52  4e554c4c空车牌
    if ([[string substringToIndex:4]isEqualToString:@"4f4b"]) { //OK
        //发送第二条指令
        [self sendsTwo];
        
    }else if ([string isEqual:@"54494d454f4b"]){
        //TIMEOK
        [manager stopScan];
        [manager cancelPeripheralConnection:currPeripheral];
    } else if([string isEqual:@"4e554c4c"] || //空车牌
             [string isEqual:@"4552524f52"]) //车牌不对
    {
        connCount++;
        [manager stopScan];
        [manager cancelPeripheralConnection:currPeripheral];
        NSLog(@"bleop 455............connCount=%ld", (long)connCount);
        
        if(connCount<3) [manager scanForPeripheralsWithServices:nil options:nil];
        
    } else {
        [manager stopScan];
        [manager cancelPeripheralConnection:currPeripheral];
        NSLog(@"bleop didUpdateValueForCharacteristic else");
    }
    
    if ([self.delegatePeripheralProperValue respondsToSelector:@selector(didUpdateValueForChtc:)]) {
        [self.delegatePeripheralProperValue didUpdateValueForChtc:dataString];
        bUIMayShow = bOK;
    }
        
    */
    

    
}

-(void)sends{
    connCount++;
    if(currPeripheral==nil) {
        //[self performSelector:@selector(sends) withObject:nil afterDelay:.5];
        return; //fixfix 20150919
    }
    CBPeripheral *p = currPeripheral;
    p.delegate=self;
    NSString *carNumId = [currCarDict valueForKey:@"License_plate_id"];//获取id;
    NSString *carNumber = [currCarDict valueForKey:@"License_plate_number"];
    
    NSData *d =[self getData:carNumber carId:carNumId];
    NSLog(@"bleop sends: bytes=%@ cbp.name=%@ cbcharacer=%@",d, currPeripheral.name, currCharacteristic);
    [p writeValue:d forCharacteristic:currCharacteristic type:CBCharacteristicWriteWithResponse];
}

/**
 *  发送给蓝牙的开闸命令(data)
 *
 *  @param carNumber 车牌号
 *  @param idString  车牌号ID
 *
 *  @return NSData data数据
 */
-(NSData *)getData:(NSString *)carNumber carId:(NSString *)idString{
    
    //获取省份对应的代号
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"shengfen" ofType:@"plist"];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    int sfNumber = [[dic objectForKey:[carNumber substringToIndex:1]] intValue];//
    
    Byte content[17];
    for (int t=0; t<17; t++) {
        content[t] = 0x00;
    }
    content[0] = 0x80;//命令字
    content[1] = 0x0e;//包长度
    //车牌
    content[2] = sfNumber;
    for (int i = 0; i<carNumber.length -1; i++) {
        
        NSString *carCardChar = [carNumber substringWithRange:NSMakeRange(i+1, 1)];
        //NSLog(@"车牌:%@ ,a:%d",carCardChar,[carCardChar characterAtIndex:0]);
        content[3+i] = [carCardChar characterAtIndex:0];
    }
    //车牌ID
    NSData *pdata =  [self operationNumber:idString];
    Byte * byte = (Byte *)[pdata bytes];
    for (int n=0; n<pdata.length; n++) {
        content[n +9] = byte[n];
    }
    //授权号(01车牌开，02id开，03车牌+id开)
    int types =  [GlobalTool getOpenGateTypeFro:carNumber];
    content[15] = types == 0?3:types;
    //校验码
    for (int j= 0;  j<16; j++) {
        content[16] =  content[16]^content[j];
    }
    
    NSData *data  =[NSData dataWithBytes:&content length:sizeof(content)];
    NSLog(@"first  send data %@",data);
    return data;
}
/**
 *  把号码字符串转成data，采用压缩字节方式
 *
 *  @param number 数字字符串(此为车牌id号)
 *
 *  @return data
 */
-(NSData *)operationNumber:(NSString *)number{
    
    //长度<12,前面补0
    if (number.length < 12) {
        NSString *temp = @"";
        for (int j=0; j<12-number.length; j++) {
            temp = [NSString stringWithFormat:@"%@%@",temp,@"0"];
        }
        number = [NSString stringWithFormat:@"%@%@",temp,number];
    }else{
        number = [number substringWithRange:NSMakeRange(number.length -12, 12)];//从后往前取12个长度
    }
    
    //号码压缩字节处理，
    Byte num[number.length/2];
    for (int i=0; i<number.length/2; i++) {
        NSString *s = [number substringWithRange:NSMakeRange(i*2, 1)];
        NSString *s2 = [number substringWithRange:NSMakeRange(i*2+1, 1)];
        int a = [s intValue]*16 + [s2 intValue];//拼接
        num[i] = a;
    }
    NSData *data = [NSData dataWithBytes:&num length:sizeof(num)];
    return data;
    
}

/**
 *  92指令
 */
-(void)sendsTwo{
    Byte sends[17];
    for (int i=0; i<17; i++) {
        sends[i] = 0;
    }
    sends[0] = 0x92;
    sends[1] = 0x0e;
    for (int k=2; k<16; k++) {
        sends[k] = 0xff;
    }
    
    for (int j= 0;  j<16; j++) {
        sends[16] =  sends[16]^sends[j];
    }
    NSData *data = [NSData dataWithBytes:&sends length:sizeof(sends)];
    CBPeripheral *p = currPeripheral;
    p.delegate=self;
    [p writeValue:data forCharacteristic:currCharacteristic type:CBCharacteristicWriteWithResponse];
}

#pragma mark --
//初始化中心
-(void)initCentralManager{
    peripheralArray = [[NSMutableArray alloc] init];
    manager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
    sString=@"<6e400001 b5a3f393 e0a9e50e 24dcca9e>";
    cString=@"<6e400002 b5a3f393 e0a9e50e 24dcca9e>";
    connCount = 0;
    bUIMayShow = YES;
    isAcceptData = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uiDisappear) name:BLEBOOL object:nil];
}

-(void)uiDisappear{ //fixfix1,20150920
    bUIMayShow = YES;
    NSLog(@"bleop uiDisappear bUIMayShow = %d", bUIMayShow);
}
-(void)startScan{
    NSLog(@"bleop all car array:%@",_allCarArray);
    [manager stopScan];
    
    [self clear];
    [manager scanForPeripheralsWithServices:nil options:nil];
}
//-清空
-(void)clear{
    if ([UIDevice currentDevice].systemVersion.floatValue >7.0 ) {
        for (int i = 0; i<peripheralArray.count; i++) {
            CBPeripheral *p =[peripheralArray objectAtIndex:i];
            if (p.state !=CBPeripheralStateConnected) {
                [peripheralArray removeObjectAtIndex:i];
            }
        }
    }else{
        for (int i= 0; i<peripheralArray.count; i++) {
            CBPeripheral *p = [peripheralArray objectAtIndex:i];
            if (p.state != CBPeripheralStateConnected) {
                [peripheralArray removeObjectAtIndex:i];
            }
        }
    }
}
//连接外设
-(void)connectPeripheral{
    if(currPeripheral!=nil) [manager connectPeripheral:currPeripheral options:nil];

}

//断开连接
-(void)cancelPeripheralConnection{
    if(currPeripheral!=nil){
        
        [manager cancelPeripheralConnection:currPeripheral];
        currPeripheral = nil;
    }
}

#pragma mark -- 80 0e+车牌+id+授权+校验 (2)
-(NSData *)byte:(NSString *)carNum carNumId:(NSString *)numId{
    //
    NSLog(@"carNum:%@---carNumId:%@",carNum,numId);
    
    NSMutableArray *allArray = [[NSMutableArray alloc]init];
    NSMutableArray *carArray = [[NSMutableArray alloc]init];
    
    [allArray addObject:@"128"];
    [allArray addObject:@"14"];
    
    for (int i =0; i<carNum.length; i++) {
        NSString *str =[carNum substringWithRange:NSMakeRange(i, 1)];
        [carArray addObject:str];
    }
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"shengfen" ofType:@"plist"];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    NSString *str1 = [dic objectForKey:carArray[0]];
    //arr[0] = str1;
    [allArray addObject:str1];
    
    // 小写转大写
    for ( int i=1; i<carArray.count; i++) {
        Byte by[1];
        unichar cc = [carArray[i] characterAtIndex:0];
        by[0] = cc;
        NSString *str =[NSString stringWithFormat:@"%d",by[0]];
        if (str.intValue >=97) {
            NSString *str2 =carArray[i];
            carArray[i] = str2.uppercaseString;
        }
    }
    
    for (int i = 1; i<carArray.count; i++) {
        Byte by[1];
        unichar cc = [carArray[i] characterAtIndex:0];
        by[0] = cc;
        NSString *str =[NSString stringWithFormat:@"%d",by[0]];
        NSLog(@"s:%@",str);
        [allArray addObject:str];
    }
    //NSMutableArray *array = [[NSMutableArray alloc]init];
    
    NSString *phone1;
    if (numId.length <12) {
        NSString *string = @"";
        for (int i=0; i<12-numId.length; i++) {
            string  = [NSString stringWithFormat:@"%@%@",string,@"0"];
        }
        phone1 =[NSString stringWithFormat:@"%@%@",string,numId];
    }else{
        phone1 = [numId substringWithRange:NSMakeRange(numId.length - 12, 12)];
    }
    
    for (int i =0; i<6; i++) {
        NSString *str = [phone1 substringWithRange:NSMakeRange(i*2, 2)];
        //        [array addObject:str];
        NSString *str1 = [NSString stringWithFormat:@"%lu",strtoul([str UTF8String], 0, 16)];
        [allArray addObject:str1];
    }
    
    [allArray addObject:carNum];
    Byte byte[17];
    for (int i = 0; i<16; i++) {
        NSString *str = [NSString stringWithFormat:@"%@",allArray[i]];
        //NSLog(@"str.intValue:%d",str.intValue);
        byte[i] = str.intValue;
    }
    
    //授权号(01车牌开，02id开，03车牌+id开)
    int types =  [GlobalTool getOpenGateTypeFro:carNum];
    byte[15] = types == 0?3:types;
    NSLog(@"--Auto:------------------%d",types);
    byte[16] =0;
    for(int i= 0;  i<16; i++) byte[16] =  byte[16]^byte[i];
    
    NSData *d=[NSData dataWithBytes:&byte length:17];
    NSLog(@"data :%@",d);
    return d;
}


@end
