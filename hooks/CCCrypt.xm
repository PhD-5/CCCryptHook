#import <substrate.h>
#import <CommonCrypto/CommonCryptor.h>
#import "SocketClass.h"

CCCryptorStatus (*original_CCCrypt)(
                        CCOperation op,         /* kCCEncrypt, etc. */
                        CCAlgorithm alg,        /* kCCAlgorithmAES128, etc. */
                        CCOptions options,      /* kCCOptionPKCS7Padding, etc. */
                        const void *key,
                        size_t keyLength,
                        const void *iv,         /* optional initialization vector */
                        const void *dataIn,     /* optional per op and alg */
                        size_t dataInLength,
                        void *dataOut,          /* data RETURNED here */
                        size_t dataOutAvailable,
                        size_t *dataOutMoved);

CCCryptorStatus replaced_CCCrypt(
                                 CCOperation op,         /* kCCEncrypt, etc. */
                                 CCAlgorithm alg,        /* kCCAlgorithmAES128, etc. */
                                 CCOptions options,      /* kCCOptionPKCS7Padding, etc. */
                                 const void *key,
                                 size_t keyLength,
                                 const void *iv,         /* optional initialization vector */
                                 const void *dataIn,     /* optional per op and alg */
                                 size_t dataInLength,
                                 void *dataOut,          /* data RETURNED here */
                                 size_t dataOutAvailable,
                                 size_t *dataOutMoved)
{
    SocketClass *socket = [[SocketClass alloc] init];

    // parse key datain and dataout
    /*
    NSData *keyData = [NSData dataWithBytes:key length:keyLength];
    NSString *keyStr = [[NSString alloc] initWithData:keyData encoding:NSUTF8StringEncoding]; 
    
    NSData *datainData = [NSData dataWithBytes:dataIn length:dataInLength];
    NSString *datainStr = [[NSString alloc] initWithData:datainData encoding:NSUTF8StringEncoding];
    
    CCCryptorStatus result = original_CCCrypt(op,alg,options,key,keyLength,iv,dataIn,dataInLength,dataOut,dataOutAvailable,dataOutMoved);
    
    NSData *dataoutData = [NSData dataWithBytes:dataOut length:dataOutAvailable];
    NSString *dataoutStr = [[NSString alloc] initWithData:dataoutData encoding:NSUTF8StringEncoding];
    
    NSString *string = [[NSString alloc] initWithFormat:@"op:%u alg:%u key:%@ inlen:%lu outlen:%lu datain:%@ dataout:%@ return:%d",
                        op,alg,keyStr,dataInLength,dataOutAvailable,datainStr,dataoutStr,result];
    [socket SendSocket:string];
     */
    NSData *keyData = [NSData dataWithBytes:key length:keyLength];
    NSString *keyStr = [[NSString alloc] initWithData:keyData encoding:NSUTF8StringEncoding]; 
    
    NSMutableDictionary *mDict = [[NSMutableDictionary alloc] init];
    [mDict setObject:@"CCCrypt" forKey:@"function"];
    [mDict setObject:[NSNumber numberWithInt:op] forKey:@"op"];
    [mDict setObject:[NSNumber numberWithInt:alg] forKey:@"alg"];
    [mDict setObject:[NSNumber numberWithInt:options] forKey:@"options"];
    [mDict setObject:keyStr forKey:@"key"];
    
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:mDict options:0 error:nil];  
    NSString * myString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];  
    
    [socket SendSocket:myString];
    
    CCCryptorStatus result = original_CCCrypt(op,alg,options,key,keyLength,iv,dataIn,dataInLength,dataOut,dataOutAvailable,dataOutMoved);

    return result;
}


%ctor {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    MSHookFunction((void *) CCCrypt,(void *)  replaced_CCCrypt, (void **) &original_CCCrypt);
    [pool drain];
}