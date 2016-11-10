#import <substrate.h>
#import <CommonCrypto/CommonCryptor.h>
#import "SocketClass.h"

CCCryptorStatus (*original_CCCryptorCreate)(
                                            CCOperation op,             /* kCCEncrypt, etc. */
                                            CCAlgorithm alg,            /* kCCAlgorithmDES, etc. */
                                            CCOptions options,          /* kCCOptionPKCS7Padding, etc. */
                                            const void *key,            /* raw key material */
                                            size_t keyLength,	
                                            const void *iv,             /* optional initialization vector */
                                            CCCryptorRef *cryptorRef);

CCCryptorStatus replaced_CCCryptorCreate(
                                          CCOperation op,             /* kCCEncrypt, etc. */
                                          CCAlgorithm alg,            /* kCCAlgorithmDES, etc. */
                                          CCOptions options,          /* kCCOptionPKCS7Padding, etc. */
                                          const void *key,            /* raw key material */
                                          size_t keyLength,	
                                          const void *iv,             /* optional initialization vector */
                                          CCCryptorRef *cryptorRef)
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
    [mDict setObject:@"CCCryptorCreate" forKey:@"function"];
    [mDict setObject:[NSNumber numberWithInt:op] forKey:@"op"];
    [mDict setObject:[NSNumber numberWithInt:alg] forKey:@"alg"];
    [mDict setObject:[NSNumber numberWithInt:options] forKey:@"options"];
    [mDict setObject:keyStr forKey:@"key"];
    
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:mDict options:0 error:nil];  
    NSString * myString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];  
    
    [socket SendSocket:myString];
    
    CCCryptorStatus result = original_CCCryptorCreate(op,alg,options,key,keyLength,iv,cryptorRef);

    return result;
}


%ctor {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    MSHookFunction((void *) CCCryptorCreate,(void *)  replaced_CCCryptorCreate, (void **) &original_CCCryptorCreate);
    [pool drain];
}