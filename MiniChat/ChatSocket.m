//
//  ChatSocket.m
//  MiniChat
//
//  Created by aatc on 8/24/13.
//  Copyright (c) 2013 nchu. All rights reserved.
//

#import "ChatSocket.h"
#import "AsyncSocket.h"
#import "MainViewController.h"
#import "UserInfo.h"
#import "ASIFormDataRequest.h"

@implementation ChatSocket

+ (ChatSocket *)shareChatSocket
{
    static ChatSocket *chatSocket = nil;
    
    if (!chatSocket) {
        chatSocket = [[ChatSocket alloc] init];
    }
    return chatSocket;
}

- (id)init
{
    if ( (self = [super init]) ) {
        self.asynSocket = [[AsyncSocket alloc] initWithDelegate:self];
    }
    return self;
}
//连接服务器
- (BOOL)connectMiniChatSocketServer
{
    NSError *error = nil;
    BOOL re =[self.asynSocket connectToHost:SOCKET_SERVER_PATH onPort:10001 error:&error];
    
    if (!re || error != nil) {
        NSLog(@"connectMiniChatSocketServer-socket error:%@", [error description]);
        
    }
    else {
        [self.asynSocket readDataWithTimeout:-1 tag:0];
        [[NSNotificationCenter defaultCenter] postNotificationName:NSNC_SocketDidConnectToHost object:nil userInfo:nil];
    }
    
    return re;
}

#pragma mark AsynSocketDelegate

- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err
{

    NSLog(@"willDisconnectWithError");
    
}

- (void)onSocketDidDisconnect:(AsyncSocket *)sock
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NSNC_SocketDidDisconnect object:nil userInfo:nil];
    NSLog(@"onSocketDidDisconnect");
}

- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    NSLog(@"didConnectToHost");
}

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData*)data withTag:(long)tag
{    
    NSDictionary *dicS = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    NSString *actionString = [dicS objectForKey:@"action"];
    //S-LOGIN-2表示服务器发给客户端 需要立即传递userID
    if ([actionString isEqualToString:@"S-LOGIN-2"]) {
        //要上传的数据
        NSString *userID = [MainViewController sharedMainViewController].loginUser.userID;
        
        NSMutableDictionary *dicC = [NSMutableDictionary dictionary];
        [dicC setObject:@"C-LOGIN-2" forKey:@"action"];
        [dicC setObject:userID forKey:@"userID"];
        
        NSData *data2 = [NSJSONSerialization dataWithJSONObject:dicC options:NSJSONWritingPrettyPrinted error:nil];
        [self.asynSocket writeData:data2 withTimeout:-1 tag:0];
    }
    //登录成功
    if ([actionString isEqualToString:@"S-LOGIN-SUCESS"]) {
        //委托发送
        [self.degelate sentSuccessInfoToClient:data];
    }
    //登录失败
    if ([actionString isEqualToString:@"S-LOGIN-FAIL"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NSNC_S_LOGIN_FAIL object:dicS userInfo:nil];
    }
    //更新在线列表
    if ([actionString isEqualToString:@"S-UPDATE-ONLINE-LIST"]) {
        if ([[dicS objectForKey:@"type"] isEqualToString:@"OFF-LINE"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:NSNC_S_UPDATE_OFFLINE_LIST object:dicS userInfo:nil];
        }
        if ([[dicS objectForKey:@"type"] isEqualToString:@"ON-LINE"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:NSNC_S_UPDATE_ONLINE_LIST object:dicS userInfo:nil];
        }
        
    }
    //某人要求加好友消息
    if ([actionString isEqualToString:@"S-C-ASK-FRIEND-TO"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NSNC_S_C_ASK_FRIEND_TO object:dicS userInfo:nil];
    }
    //S-C-ASK-FRIEND-RES-YES – 对方同意加为好友请求
    if ([actionString isEqualToString:@"S-C-ASK-FRIEND-RES-YES"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NSNC_S_C_ASK_FRIEND_RES_YES object:dicS userInfo:nil];
    }
    //S-C-ASK-FRIEND-RES-NO  － 对方拒绝 加为好友请求
    if ([actionString isEqualToString:@"S-C-ASK-FRIEND-RES-NO"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NSNC_S_C_ASK_FRIEND_RES_NO object:dicS userInfo:nil];
    }
    //收到好友消息C-S-ASK-TALKING
    if ([actionString isEqualToString:@"C-S-ASK-TALKING"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NSNC_C_S_ASK_TALKING object:dicS userInfo:nil];
    }
    
    //动作错误
    if ([actionString isEqualToString:@"S-ACTION-ERROR"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NSNC_S_ACTION_ERROR object:data userInfo:nil];
    }

    [self.asynSocket readDataWithTimeout:-1 tag:0];
}

- (void)onSocket:(AsyncSocket *)sock didReadPartialDataOfLength:(CFIndex)partialLength tag:(long)tag
{
    NSLog(@"%ld", partialLength);
}

- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    
}

#pragma mark dealloc
- (void)dealloc
{
    self.asynSocket = nil;
    self.degelate = nil;
    [super dealloc];
}

@end
