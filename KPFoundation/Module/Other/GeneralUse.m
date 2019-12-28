//
//  GeneralUse.m
//  ZYYObjcLib
//
//  Created by zyyuann on 2017/4/19.
//  Copyright © 2017年 ZYY. All rights reserved.
//

#import <KPFoundation/GeneralUse.h>

#import <KPFoundation/MultiLanguage.h>

@implementation GeneralUse

#pragma mark - JSON处理
// 将NSDictionary或NSArray 转换为 JSON       type=1，表示返回NSString；type=2，表示返回NSData
+ (id)TransformToJson:(id)transData BackType:(NSInteger)type{
    if (!transData) {
        return nil;
    }
    if ([transData isKindOfClass:[NSString class]]) {
        if (type == 1) {
            return transData;
        }
    }else if ([transData isKindOfClass:[NSData class]]){
        if (type == 2) {
            return transData;
        }
    }else if ([transData isKindOfClass:[NSArray class]] || [transData isKindOfClass:[NSDictionary class]]){
        NSError *error = nil;
        NSData* jsonData =[NSJSONSerialization dataWithJSONObject:transData
                                                          options:0
                                                            error:&error];
        if (error)
            return nil;
        
        if (type == 2)
            return jsonData;
        else if (type == 1){
            NSString *JsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            return JsonStr;
        }
    }
    
    return nil;
}

// 将JSON 转换为 NSDictionary或NSArray
+ (id)TransformToObj:(id)jsonData{
    if (!jsonData)
        return nil;
    
    NSData *j_data = nil;
    if ([jsonData isKindOfClass:[NSString class]]) {
        j_data = [jsonData dataUsingEncoding:NSUTF8StringEncoding];
    }else if ([jsonData isKindOfClass:[NSData class]]){
        j_data = jsonData;
    }
    if (!j_data) {
        return nil;
    }
    NSError *error = nil;
    id transData =[NSJSONSerialization JSONObjectWithData:j_data options:NSJSONReadingMutableLeaves error:&error];
    if (error)
        return nil;
    
    return transData;
}

// 对 字典化 Json 规范化：过滤NULL、NSNumber
+ (id)StandardToJson:(id)oldJson{
    if (!oldJson)
        return nil;
    
    if ([oldJson isKindOfClass:[NSDictionary class]])
    {
        NSMutableDictionary *newDicJson = [[NSMutableDictionary alloc]init];
        NSArray *allKey = [oldJson allKeys];
        for (NSInteger i = 0; allKey && i < [allKey count]; i++) {
            id backData = [self StandardToJson:[oldJson objectForKey:[allKey objectAtIndex:i]]];
            if (backData)
                [newDicJson setValue:backData forKey:[allKey objectAtIndex:i]];
            
        }
        return [NSDictionary dictionaryWithDictionary:newDicJson];
    }
    else if([oldJson isKindOfClass:[NSArray class]])
    {
        NSMutableArray *newArrJson = [[NSMutableArray alloc]init];
        for (NSInteger i = 0; oldJson && i < [oldJson count]; i++) {
            id backData = [self StandardToJson:[oldJson objectAtIndex:i]];
            if (backData)
                [newArrJson addObject:backData];
            
        }
        return [NSArray arrayWithArray:newArrJson];
    }
    else if ([oldJson isKindOfClass:[NSNumber class]])
    {
        return [NSString stringWithFormat:@"%@",oldJson];
    }
    else if ([oldJson isKindOfClass:[NSNull class]])
    {
        return @"";
    }else{
        return oldJson;
    }
}

#pragma mark - 检测版本
+ (BOOL)VersionA:(NSString*)versionA GreaterThanVersionB:(NSString*)versionB{
    if (!(versionA && versionB))
        return NO;
    
    NSArray *arrayA = [versionA componentsSeparatedByString: @"."];
    NSArray *arrayB = [versionB componentsSeparatedByString: @"."];
    
    NSInteger countA = [arrayA count];
    NSInteger countB = [arrayB count];
    
    NSInteger size = countA<countB?countA:countB;
    for (NSInteger i=0; i<size; i++) {
        NSInteger a = [arrayA[i] integerValue];
        NSInteger b = [arrayB[i] integerValue];
        if (a < b) {
            return NO;
        }else if(a > b){
            return YES;
        }
    }
    if (countA > countB) {
        return YES;
    }
    return NO;
}

+ (BOOL)IsContainString:(NSString *)orgStr SubString:(NSString *)subStr Fuzzy:(BOOL)isFuzzy{
    if (!(subStr && orgStr)) {
        return NO;
    }
    if (isFuzzy) {
        orgStr = [orgStr lowercaseString];
        subStr = [subStr lowercaseString];
    }
    return [orgStr rangeOfString:subStr].location != NSNotFound;
}

#pragma mark - 把int转nsstring，并按照fillZero补充0
+ (NSString *)StringFromNSUInteger:(NSInteger)numb FillZero:(NSUInteger)fillZero{
    NSString *zeroStr = @"";
    while (fillZero >= 1) {
        if (numb / fillZero) {
            return [NSString stringWithFormat:@"%@%ld" ,zeroStr ,numb];
        }else{
            fillZero = fillZero / 10;
            zeroStr = [zeroStr stringByAppendingString:@"0"];
        }
    }
    return [NSString stringWithFormat:@"%ld" ,numb];
}

#pragma mark - 价格转换
+ (NSString *)StrmethodComma:(NSString *)moneyString FloatingNumber:(int64_t)fillZero{
    return [self StrmethodComma:moneyString FloatingNumber:fillZero KeepPoint:NO Need45:YES];
}
+ (NSString *)StrmethodComma:(NSString *)numbStr FloatingNumber:(int64_t)fillZero KeepPoint:(BOOL)isKeep Need45:(BOOL)isNeed45{
    if (!(numbStr && [numbStr length])) {
        return nil;
    }
    
    if ([numbStr isEqualToString:@"-."]) {
        numbStr = @"-0.";
        
    }else if ([numbStr isEqualToString:@"."]){
        numbStr = @"0.";
        
    }else if ([numbStr hasPrefix:@"00"]) {
        numbStr = [numbStr stringByReplacingOccurrencesOfString:@"00" withString:@"0"];
        
    }else if ([numbStr hasPrefix:@"-00"]) {
        numbStr = [numbStr stringByReplacingOccurrencesOfString:@"-00" withString:@"-0"];
        
    }
    
    numbStr = [numbStr stringByReplacingOccurrencesOfString:@"," withString:@""];
    if (!(numbStr && [numbStr length])) {
        return nil;
    }
    
    NSString *sign = nil;
    if ([numbStr hasPrefix:@"-"] || [numbStr hasPrefix:@"+"]) {
        sign = [numbStr substringToIndex:1];
        numbStr = [numbStr substringFromIndex:1];
    }
    if (!(numbStr && [numbStr length])) {
        if (sign && isKeep) {
            return sign;
        }
        
        return nil;
    }
    
    // 判断是否有小数点
    NSString *point = nil;
    if ([numbStr containsString:@"."]) {
        point = @".";
    }
    
    // 先四舍五入
    if (isNeed45) {
        NSDecimalNumberHandler *roundUp = [NSDecimalNumberHandler
                                           decimalNumberHandlerWithRoundingMode:NSRoundBankers
                                           scale:fillZero
                                           raiseOnExactness:NO
                                           raiseOnOverflow:NO
                                           raiseOnUnderflow:NO
                                           raiseOnDivideByZero:YES];
        
        NSDecimalNumber *yy = [[NSDecimalNumber decimalNumberWithString:numbStr] decimalNumberByRoundingAccordingToBehavior:roundUp];
        numbStr = yy.stringValue;
    }
    
    NSArray *arr1 = [numbStr componentsSeparatedByString:@"."];
    NSString *pointLast = nil;
    NSString *pointFront = nil;
    
    if ([arr1 count] == 2) {
        pointFront = arr1[0];
        pointLast = arr1[1];
        
        if ([pointLast length]) {
            
            point = nil;
        }
        
    }else if ([arr1 count] == 1){
        pointFront = arr1[0];
    }
    
    // 是否需要保存小数点和小数点后的0（isNeed45 为NO）
    if (!isKeep) {
        if (!pointLast.integerValue) {
            pointLast = nil;
        }
    }
    
    NSInteger commaNum = ([pointFront length] - 1)/3;
    // 防止整数部分不存在 commanum计算错误
    if ([pointFront isEqualToString:@""]) {
        commaNum = 0;
    }
    NSMutableArray *arr = [NSMutableArray array];
    for (NSInteger i = 0; i < commaNum + 1; i++) {
        NSInteger index = [pointFront length] - (i+1)*3;
        NSInteger leng = 3;
        if(index < 0)
        {
            leng = 3 + index;
            index = 0;
        }
        NSRange range = {index,leng};
        NSString *stq = [pointFront substringWithRange:range];
        if (stq) {
            [arr addObject:stq];
        }
    }
    
    NSMutableArray *arr2 = [NSMutableArray array];
    for (NSInteger i = [arr count] - 1; i >= 0; i--) {
        
        [arr2 addObject:arr[i]];
    }
    
    NSString *commaString = [arr2 componentsJoinedByString:@","];
    if (pointLast && [pointLast length]) {
        commaString = [NSString stringWithFormat:@"%@.%@" ,[arr2 componentsJoinedByString:@","] ,pointLast];
    }else if (point && isKeep) {
        commaString = [commaString stringByAppendingString:point];
    }
    
    if (sign){
        if (commaString.doubleValue > 0 || isKeep) {
            commaString = [sign stringByAppendingString:commaString];
        }
    }
    
    return commaString;
}

+ (NSString *)StrmethodAbbreviation:(NSString *)moneyString FloatingNumber:(int64_t)fillZero{
    
    LanguageType languageType = [MultiLanguage Share].languageType;
    
    BOOL isEnglish = NO;
    BOOL isHans = YES;
    if (languageType == LanguageTypeSimpleChinese) {//中文，包括简体跟繁体
        isHans = YES;
    }else if (languageType == LanguageTypeTraditionalChinese){
        isHans = NO;
    }else{
        isEnglish = YES;
    }
    double num;
    short scale;
    double moneyNum = moneyString.doubleValue;
    BOOL minus = moneyNum<0;
    if(minus){
        moneyNum = -moneyNum;
    }
    NSString * meta;
    if(!isEnglish){
        if(moneyNum<100000){
            num = moneyNum;
            scale = fillZero;
            meta = @"";
            
        }else if (moneyNum<100000000){
            num = moneyNum/10000.0f;
            scale = 2;
            meta = isHans?@"万":@"萬";
        }else{
            num = moneyNum/100000000.0f;
            scale = 2;
            meta = isHans?@"亿":@"億";
        }
    }else{
        if(moneyNum<10000){
            num = moneyNum;
            scale = fillZero;
            meta = @"";
            
        }else if (moneyNum<1000000){
            num = moneyNum/1000.0f;
            scale = 2;
            meta = @"k";
        }else if(moneyNum<1000000000.0f){
            num = moneyNum/1000000.0f;
            scale = 2;
            meta = @"m";
        }else{
            num = moneyNum/1000000000.0f;
            scale = 2;
            meta = @"b";
        }
    }
    
    
    NSString * numbStr;
    NSDecimalNumberHandler *roundUp = [NSDecimalNumberHandler
                                       decimalNumberHandlerWithRoundingMode:NSRoundBankers
                                       scale:scale
                                       raiseOnExactness:NO
                                       raiseOnOverflow:NO
                                       raiseOnUnderflow:NO
                                       raiseOnDivideByZero:YES];
    
    NSDecimalNumber *yy = [[NSDecimalNumber decimalNumberWithString:[@(num)stringValue]] decimalNumberByRoundingAccordingToBehavior:roundUp];
    numbStr = yy.stringValue;
    if(minus){
        numbStr = [@"-"stringByAppendingString:numbStr];
    }
    NSArray *arr1 = [numbStr componentsSeparatedByString:@"."];
    if(arr1.count==2&&[arr1.lastObject integerValue]==0){
        numbStr = arr1.firstObject;
    }
    return [numbStr stringByAppendingFormat:@"%@",meta];
}

+ (NSString *)DigitUppercase:(NSString *)numstr{
    BOOL is_fs = NO;
    double numberals = [numstr doubleValue];
    if (numberals == -0) {
        numberals = 0;
    }
    
    if (numberals < 0) {
        numberals = -numberals;
        is_fs = YES;
    }
    
    if (numberals == 0) {
        return @"零元";
    }
    
    NSArray *numberchar = @[@"零",@"壹",@"贰",@"叁",@"肆",@"伍",@"陆",@"柒",@"捌",@"玖"];
    NSArray *inunitchar = @[@"",@"拾",@"佰",@"仟"];
    NSArray *unitname = @[@"",@"万",@"亿",@"万亿"];
    //金额乘以100转换成字符串（去除圆角分数值）
    NSString *valstr=[NSString stringWithFormat:@"%.2f",numberals];
    NSString *prefix;
    NSString *suffix;
    if (valstr.length<=2) {
        prefix=@"零元";
        if (valstr.length==0) {
            suffix=@"零角零分";
        }
        else if (valstr.length==1)
        {
            suffix=[NSString stringWithFormat:@"%@分",[numberchar objectAtIndex:[valstr intValue]]];
        }
        else
        {
            NSString *head=[valstr substringToIndex:1];
            NSString *foot=[valstr substringFromIndex:1];
            suffix = [NSString stringWithFormat:@"%@角%@分",[numberchar objectAtIndex:[head intValue]],[numberchar  objectAtIndex:[foot intValue]]];
        }
    }
    else
    {
        prefix=@"";
        suffix=@"";
        NSInteger flag = valstr.length - 2;
        NSString *head=[valstr substringToIndex:flag - 1];
        NSString *foot=[valstr substringFromIndex:flag];
        if (head.length>13) {
            return @"数值太大(最大支持13位整数)";
        }
        //处理整数部分
        NSMutableArray *ch=[[NSMutableArray alloc]init];
        for (int i = 0; i < head.length; i++) {
            NSString * str=[NSString stringWithFormat:@"%x",[head characterAtIndex:i]-'0'];
            [ch addObject:str];
        }
        int zeronum=0;
        
        for (int i=0; i<ch.count; i++) {
            int index=(ch.count -i-1)%4;//取段内位置
            NSInteger indexloc=(ch.count -i-1)/4;//取段位置
            if ([[ch objectAtIndex:i]isEqualToString:@"0"]) {
                zeronum++;
            }
            else
            {
                if (zeronum!=0) {
                    if (index!=3) {
                        prefix=[prefix stringByAppendingString:@"零"];
                    }
                    zeronum=0;
                }
                prefix=[prefix stringByAppendingString:[numberchar objectAtIndex:[[ch objectAtIndex:i]intValue]]];
                prefix=[prefix stringByAppendingString:[inunitchar objectAtIndex:index]];
            }
            if (index ==0 && zeronum<4) {
                prefix=[prefix stringByAppendingString:[unitname objectAtIndex:indexloc]];
            }
        }
        prefix =[prefix stringByAppendingString:@"元"];
        //处理小数位
        if ([foot isEqualToString:@"00"]) {
            suffix =[suffix stringByAppendingString:@"整"];
        }
        else if ([foot hasPrefix:@"0"])
        {
            NSString *footch=[NSString stringWithFormat:@"%x",[foot characterAtIndex:1]-'0'];
            suffix=[NSString stringWithFormat:@"%@分",[numberchar objectAtIndex:[footch intValue] ]];
        }
        else
        {
            NSString *headch=[NSString stringWithFormat:@"%x",[foot characterAtIndex:0]-'0'];
            NSString *footch=[NSString stringWithFormat:@"%x",[foot characterAtIndex:1]-'0'];
            suffix=[NSString stringWithFormat:@"%@角%@分",[numberchar objectAtIndex:[headch intValue]],[numberchar  objectAtIndex:[footch intValue]]];
        }
    }
    
    if ([prefix isEqualToString:@"元"]) {
        prefix = @"";
        
        if ([suffix isEqualToString:@"整"]) {
            suffix = @"";
        }
    }
    
    suffix = [suffix stringByReplacingOccurrencesOfString:@"零分" withString:@""];
    
    if (is_fs) {
        prefix = [@"负" stringByAppendingString:prefix];
    }
    
    return [prefix stringByAppendingString:suffix];
}

+ (NSString *)getCnMoneyByString:(NSString*)string
{
    // 设置数据格式
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    
    // NSLocale的意义是将货币信息、标点符号、书写顺序等进行包装，如果app仅用于中国区应用，为了保证当用户修改语言环境时app显示语言一致，则需要设置NSLocal（不常用）
    numberFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    
    // 全拼格式
    [numberFormatter setNumberStyle:NSNumberFormatterSpellOutStyle];
    
    // 小数点后最少位数
    [numberFormatter setMinimumFractionDigits:2];
    
    // 小数点后最多位数
    [numberFormatter setMaximumFractionDigits:6];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehaviorDefault];
    
    NSString *formattedNumberString = [numberFormatter stringFromNumber:[NSNumber numberWithDouble:[string doubleValue]]];
    
    //通过NSNumberFormatter转换为大写的数字格式 eg:一千二百三十四
    //替换大写数字转为金额
    
    formattedNumberString = [formattedNumberString stringByReplacingOccurrencesOfString:@"一" withString:@"壹"];
    
    formattedNumberString = [formattedNumberString stringByReplacingOccurrencesOfString:@"二" withString:@"贰"];
    
    formattedNumberString = [formattedNumberString stringByReplacingOccurrencesOfString:@"三" withString:@"叁"];
    
    formattedNumberString = [formattedNumberString stringByReplacingOccurrencesOfString:@"四" withString:@"肆"];
    
    formattedNumberString = [formattedNumberString stringByReplacingOccurrencesOfString:@"五" withString:@"伍"];
    
    formattedNumberString = [formattedNumberString stringByReplacingOccurrencesOfString:@"六" withString:@"陆"];
    
    formattedNumberString = [formattedNumberString stringByReplacingOccurrencesOfString:@"七" withString:@"柒"];
    
    formattedNumberString = [formattedNumberString stringByReplacingOccurrencesOfString:@"八" withString:@"捌"];
    
    formattedNumberString = [formattedNumberString stringByReplacingOccurrencesOfString:@"九" withString:@"玖"];
    
    formattedNumberString = [formattedNumberString stringByReplacingOccurrencesOfString:@"〇" withString:@"零"];
    
    formattedNumberString = [formattedNumberString stringByReplacingOccurrencesOfString:@"千" withString:@"仟"];
    
    formattedNumberString = [formattedNumberString stringByReplacingOccurrencesOfString:@"百" withString:@"佰"];
    
    formattedNumberString = [formattedNumberString stringByReplacingOccurrencesOfString:@"十" withString:@"拾"];
    
    // 对小数点后部分单独处理
    
    // rangeOfString 前面的参数是要被搜索的字符串，后面的是要搜索的字符
    
    if ([formattedNumberString rangeOfString:@"点"].length>0)
        
    {
        
        // 将“点”分割的字符串转换成数组，这个数组有两个元素，分别是小数点前和小数点后
        
        NSArray* arr = [formattedNumberString componentsSeparatedByString:@"点"];
        
        // 如果对一不可变对象复制，copy是指针复制（浅拷贝）和mutableCopy就是对象复制（深拷贝）。如果是对可变对象复制，都是深拷贝，但是copy返回的对象是不可变的。
        
        // 这里指的是深拷贝
        
        NSMutableString* lastStr = [[arr lastObject] mutableCopy];
        
        NSLog(@"---%@---长度%ld", lastStr, lastStr.length);
        
        if (lastStr.length>=2)
            
        {
            
            // 在最后加上“分”
            
            [lastStr insertString:@"分" atIndex:lastStr.length];
            
        }
        
        if (![[lastStr substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"零"])
            
        {
            
            // 在小数点后第一位后边加上“角”
            
            [lastStr insertString:@"角" atIndex:1];
            
        }
        
        // 在小数点左边加上“元”
        
        formattedNumberString = [[arr firstObject] stringByAppendingFormat:@"元%@",lastStr];
        
    }
    
    else // 如果没有小数点
        
    {
        
        formattedNumberString = [formattedNumberString stringByAppendingString:@"元"];
        
    }
    
    return formattedNumberString;
    
}

@end
