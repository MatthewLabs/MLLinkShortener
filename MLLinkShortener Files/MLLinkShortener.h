//
//  MLLinkShortener.h
//  MLLinkShortener
//
//  Created by Matteo Del Vecchio on 30/06/13.
//  Copyright (c) 2012 Matthew Labs. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (MLLinkEncoding)
-(NSString *)encodeLink;
@end


typedef enum MLLinkShortenerOptions
{
	MLLinkShortenerBitly = 0,
	MLLinkShortenerGoogl,
	MLLinkShortenerIsGd,
	MLLinkShortenerLinkyy,
	MLLinkShortenerVGd
} MLLinkShortenerOption;


typedef void (^MLLinkShortenerSuccessBlock)(NSURL *link);
typedef void (^MLLinkShortenerFailureBlock)(NSError *error);


@interface MLLinkShortener : NSObject <NSURLConnectionDataDelegate>

+(MLLinkShortener *)prepareLink:(NSString *)link usingShortner:(MLLinkShortenerOption)shortener;
-(id)initWithLink:(NSString *)link usingShortener:(MLLinkShortenerOption)shortener;

-(void)shortLinkWithOptions:(NSDictionary *)options success:(MLLinkShortenerSuccessBlock)successBlock failure:(MLLinkShortenerFailureBlock)failureBlock;

@end
