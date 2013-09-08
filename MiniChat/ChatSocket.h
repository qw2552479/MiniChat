//
//  ChatSocket.h
//  MiniChat
//
//  Created by aatc on 8/24/13.
//  Copyright (c) 2013 nchu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AsyncSocket.h"
#import "NotificationName.h"

#define SOCKET_SERVER_PATH @"172.16.15.7"
#define MINI_CHAT_HTTP_SERVER @"http://172.16.15.7/miniChat"

@protocol ClientConnectServerSuccess <NSObject>

- (void)sentSuccessInfoToClient:(NSData *)data;

@end

@interface ChatSocket : NSObject

@property (nonatomic, retain) AsyncSocket *asynSocket;

@property (nonatomic, retain) id<ClientConnectServerSuccess>degelate;

+ (ChatSocket *)shareChatSocket;
- (BOOL)connectMiniChatSocketServer;
@end
